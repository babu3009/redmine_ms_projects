require 'redmine'
require_dependency "redmine_ms_projects/hooks"

Redmine::Plugin.register :redmine_ms_projects do
  name 'Redmine Ms Projects plugin'
  author 'suer / y.yoshida'
  description 'MS Project Importer for Redmine'
  version '0.1.2'
  url 'https://github.com/yoshidayo/redmine_ms_projects'
  author_url 'http://www.ibs.inte.co.jp/'

  project_module :msproject do
    permission :msprojects, {:msprojects => [:index]}, :public => true
  end
  #menu :project_menu, :msprojects, { :controller => 'msprojects', :action => 'index' }, :caption => :msproject, :param => :project_id

end
