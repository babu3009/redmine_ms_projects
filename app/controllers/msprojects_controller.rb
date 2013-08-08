# encoding: utf-8
require 'tempfile'
class MsprojectsController < ApplicationController
  unloadable
  before_filter :find_project, :only => [:index, :select, :add]
  before_filter :list_issues, :only => [:index, :select, :add]

  helper :msprojects
  include MsprojectsHelper

  menu_item :msprojects, :only => :index
  #menu :project_menu, :msprojects, { :controller => 'msprojects', :action => 'index' }, :caption => :msproject, :param => :project_id

  def index
    xml = ""
    @tasks = []
    @added_tasks = []
  end

  def select
    begin
      tmpfile = Tempfile.new(params[:file][:msproject].original_filename)
      xml = params[:file][:msproject].read
      xml.force_encoding("utf-8")
      tmpfile.write(xml)
      tmpfile.close
      $tmpfile = {} if $tmpfile.nil?
      $tmpfile[params[:file][:msproject].original_filename] = tmpfile
    rescue Exception => ex
      flash[:error] = l(:file_read_error) + ex.to_s
      redirect_to :action => 'index', :project_id => @project.identifier
      return
    end
    begin
      @tasks = parse_ms_project(xml, @issues)
    rescue Exception => ex
      flash[:error] = l(:file_read_error) + ex.to_s
      redirect_to :action => 'index', :project_id => @project.identifier
      return
    end
    @resources = find_resources(xml)
    #params[:file][:msproject].close
    @members = @project.members.collect {|m| User.find_by_id m.user_id }
    @trackers = @project.trackers
    session[:msp_tmp_filename] = params[:file][:msproject].original_filename
  end

  def add
    @tasks = []
    @added_tasks = []
    @updated_tasks = []
    @saved_task_table = {}
    xml = ''
    begin
      open($tmpfile[session[:msp_tmp_filename]].path) do |f|
        xml = f.read
      end
    rescue Exception => ex
      flash[:error] = l(:file_read_error) + ex.to_s
      return
    end
    tasks = parse_ms_project(xml, @issues)
    params[:checked_items].each do |i|
      @tasks << tasks.select{|t| t.task_id == i}[0]
    end
    @tasks.each_with_index do |t, i|
      if t.create?
        issue = Issue.new({:subject => t.name})
      else
        issue = find_issue t.name, @issues
      end
      issue.project = @project
      issue.tracker_id = params[:trackers][params[:checked_items][i].to_i]
      assigned_id = params[:assigns][params[:checked_items][i].to_i]
      unless assigned_id.blank?
        issue.assigned_to_id = params[:assigns][params[:checked_items][i].to_i]
      end
      issue.author = User.current
      issue.start_date = t.start_date
      issue.due_date = t.finish_date
      issue.updated_on = t.create_date
      issue.created_on = t.create_date
      parent = search_parent_issue(t, @tasks)
      unless parent.nil?
        issue.parent_issue_id = parent.id
      end

      if t.create? and issue.save
        @added_tasks << issue
        @saved_task_table[t.outline_number] = issue
      elsif issue.save
        @updated_tasks << issue
        @saved_task_table[t.outline_number] = issue
      end
    end

    #flash[:notice] = []
    #flash[:notice] << l(:msp_read_message, :d => @added_tasks.size)
    #flash[:notice] << " "
    #flash[:notice] << l(:msp_update_message, :d => @updated_tasks.size)
    flash[:notice] = ''
    flash[:notice] += @added_tasks.size.to_s
    flash[:notice] += l(:msp_read_message)
    flash[:notice] += ' '
    flash[:notice] += @updated_tasks.size.to_s
    flash[:notice] += l(:msp_update_message)
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  end

  def list_issues
    @issues = Issue.find :all, :conditions => ['project_id = ?', @project.id]
  end

  def find_issue name, issues
    issues.each do |issue|
      return issue if issue.subject == name
    end
    nil
  end

  def search_parent_issue(task, tasks)
    parent_number = task.outline_number.split(".")[0..-2].join(".")
    parent_task = nil
    @saved_task_table.each do |number, issue|
      if parent_number == number
        return issue
      end
    end
    nil
  end
end