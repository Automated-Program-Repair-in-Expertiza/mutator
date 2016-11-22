class ResponseController < ApplicationController
  def set_dropdown_or_scale
    use_dropdown = AssignmentQuestionnaire.where(assignment_id: @assignment.id, questionnaire_id: @questionnaire.id).first.dropdown
    @dropdown_or_scale = use_dropdown == true ? 'dropdown' : 'scale'
  end
end
