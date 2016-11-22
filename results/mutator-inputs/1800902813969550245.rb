class ReviewMappingController < ApplicationController
  def delete_reviewer
    review_response_map = ReviewResponseMap.find(params[:id])
    assignment_id = review_response_map.assignment.id
    if !Response.exists?(map_id: review_response_map.id)
      review_response_map.destroy
      flash[:success] = "The review mapping for \"" + review_response_map.reviewee.name + "\" and \"" + review_response_map.reviewer.name + "\" has been deleted."
    else
      flash[:error] = "This review has already been done. It cannot been deleted."
    end
    redirect_to action: 'list_mappings', id: assignment_id
  end
end
