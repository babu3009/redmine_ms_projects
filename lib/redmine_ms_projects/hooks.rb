module RedmineMsProjects
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_sidebar_planning_bottom,
              :partial => 'hooks/redmine_ms_projects/view_issues_sidebar_planning_bottom'
  end
end

