class VmQuestionResponse
  def get_number_of_comments_greater_than_10_words
    first_time = true

    @list_of_reviews.each do |review|
      answers = Answer.where(response_id: review.response_id)
      answers.each do |answer|
        @list_of_rows.each do |row|
          if row.question_id == answer.question_id && answer.comments.split.size > 10
            row.countofcomments = row.countofcomments + 1
          end
        end
      end
    end
  end
end
