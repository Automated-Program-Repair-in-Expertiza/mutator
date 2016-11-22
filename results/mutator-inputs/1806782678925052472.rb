class SignUpSheetController < ApplicationController
  def are_needed_authorizations_present?
    @participant = Participant.where('user_id = ? and parent_id = ?', session[:user].id, params[:assignment_id]).first
    authorization = Participant.get_authorization(@participant.can_submit, @participant.can_review, @participant.can_take_quiz)
    if authorization == 'reader' or authorization == 'submitter' or authorization == 'reviewer'
      return false
    else
      return true
    end
  end
end
