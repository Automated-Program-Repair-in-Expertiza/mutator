class QuestionnairesController < ApplicationController
  def update_quiz
    @questionnaire = Questionnaire.find(params[:id])
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid] if @questionnaire.nil?
    if params['save']
      @questionnaire.update_attributes(questionnaire_params)

      for qid in params[:question].keys
        @question = Question.find(qid)
        @question.txt = params[:question][qid.to_sym][:txt]
        @question.save

        @quiz_question_choices = QuizQuestionChoice.where(question_id: qid)
        i = 1
        for quiz_question_choice in @quiz_question_choices
          if @question.type == "MultipleChoiceCheckbox"
            if params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s]
              quiz_question_choice.update_attributes(iscorrect: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:iscorrect], txt: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:txt])
            else
              quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][quiz_question_choice.id.to_s][:txt])
            end
          end
          if @question.type == "MultipleChoiceRadio"
            if params[:quiz_question_choices][@question.id.to_s][@question.type][:correctindex] == i.to_s
              quiz_question_choice.update_attributes(iscorrect: '1', txt: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:txt])
            else
              quiz_question_choice.update_attributes(iscorrect: '0', txt: params[:quiz_question_choices][@question.id.to_s][@question.type][i.to_s][:txt])
            end
          end
          if @question.type == "TrueFalse"
            if params[:quiz_question_choices][@question.id.to_s][@question.type][1.to_s][:iscorrect] == "True" # the statement is correct
              if quiz_question_choice.txt == "True"
                quiz_question_choice.update_attributes(iscorrect: '1') # the statement is correct so "True" is the right answer
              else
                quiz_question_choice.update_attributes(iscorrect: '0')
              end
            else # the statement is not correct
              if quiz_question_choice.txt == "True"
                quiz_question_choice.update_attributes(iscorrect: '0')
              else
                quiz_question_choice.update_attributes(iscorrect: '1') # the statement is not correct so "False" is the right answer
              end
            end
          end

          i += 1
        end
      end
    end
    redirect_to controller: 'submitted_content', action: 'view', id: params[:pid]
  end
end
