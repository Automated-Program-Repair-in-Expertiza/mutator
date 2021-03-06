class AssignmentsController < ApplicationController
  def action_allowed?
    if params[:action] == 'edit' || params[:action] == 'update'
      assignment = Assignment.find(params[:id])
      return true if ['Super-Administrator', 'Administrator'].include? current_role_name
      return true if assignment.instructor_id == current_user.id
      return true if TaMapping.exists?(ta_id: current_user.id, course_id: assignment.course_id) && (TaMapping.where(course_id: assignment.course_id).include?TaMapping.where(ta_id: current_user.id, course_id: assignment.course_id).first)
      return true if assignment.course_id && Course.find(assignment.course_id).instructor_id == current_user.id
      return false
    else
      ['Super-Administrator',
       'Administrator',
       'Instructor',
       'Teaching Assistant'].include? current_role_name
    end
  end
end
