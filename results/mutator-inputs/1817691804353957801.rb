class QuestionnairesController < ApplicationController
  def save_all_questions
    questionnaire_id = params[:id] unless params[:id].nil?
    if params['save']
      params[:question].each_pair do |k, v|
        @question = Question.find(k)
        # example of 'v' value
        # {"seq"=>"1.0", "txt"=>"WOW", "weight"=>"1", "size"=>"50,3", "max_label"=>"Strong agree", "min_label"=>"Not agree"}
        v.each_pair do |key, value|
          @question.send(key + '=', value) if @question.send(key) != value
        end
        begin
          @question.save
          flash[:success] = 'All questions has been successfully saved!'
        rescue
          flash[:error] = $ERROR_INFO
        end
      end
    end

    export if params['export']
    import if params['import']

    if params['view_advice']
      redirect_to controller: 'advice', action: 'edit_advice', id: params[:id]
    else
      redirect_to edit_questionnaire_path(questionnaire_id.to_sym)
    end
  end
end
