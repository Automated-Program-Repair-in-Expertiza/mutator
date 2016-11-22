class SignUpSheetController < ApplicationController
  def destroy
    @topic = SignUpTopic.find(params[:id])
    if @topic
      @topic.destroy
      undo_link("The topic: \"#{@topic.topic_name}\" has been successfully deleted. ")
    else
      flash[:error] = "The topic could not be deleted."
    end

    # if this assignment has staggered deadlines then destroy the dependencies as well
    if Assignment.find(params[:assignment_id])['staggered_deadline'] == true
      dependencies = TopicDependency.where(topic_id: params[:id])
      dependencies.each(&:destroy) unless dependencies.nil?
    end
    # changing the redirection url to topics tab in edit assignment view.
    redirect_to edit_assignment_path(params[:assignment_id]) + "#tabs-5"
  end
end