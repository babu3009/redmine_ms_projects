# encoding: utf-8
require "rexml/document"
module MsprojectsHelper

  def parse_ms_project xml, issues
    tasks = []
    doc = REXML::Document.new xml
    doc.elements.each('//Task') do |task_tag|
      task = MspTask.new
      task.task_id = task_tag.elements['ID'].text
      task.wbs = task_tag.elements['WBS'].text
      task.outline_number = task_tag.elements['OutlineNumber'].text
      task.outline_level = task_tag.elements['OutlineLevel'].text.to_i
      name = task_tag.elements['Name']
      task.name = name.text.force_encoding("utf-8") if name
      date = Date.new
      start_date = task_tag.elements['Start']
      task.start_date = start_date.text.split('T')[0] if start_date
      finish_date = task_tag.elements['Finish']
      task.finish_date = finish_date.text.split('T')[0] if finish_date
      create_date = task_tag.elements['CreateDate']
      date_time = create_date.text.split('T') if create_date
      task.create_date = date_time[0] + ' ' + date_time[1] if date_time
      task.create = name ? !(has_task(name.text, issues)) : true
      tasks << task
    end
    tasks
  end rescue raise 'parse error'


  def find_resources xml
    resources = []
    doc = REXML::Document.new xml
    doc.elements.each('//Resource') do |resource_tag|
      resource = MspResource.new
      id = resource_tag.elements['ID']
      resource.id = id if id
      name = resource_tag.elements['Name']
      resource.name = name.text if name
      resources << resource
    end
    resources
  end

  private
  def has_task name, issues
    issues.each do |issue|
      return true if issue.subject == name
    end
    false
  end

end
