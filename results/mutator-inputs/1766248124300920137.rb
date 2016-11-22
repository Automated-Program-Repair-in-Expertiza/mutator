class SignUpTopic < ActiveRecord::Base
  def self.reassign_topic(session_user_id, assignment_id, topic_id)
    # find whether assignment is team assignment
    assignment = Assignment.find(assignment_id)

    # making sure that the drop date deadline hasn't passed
    dropDate = AssignmentDueDate.where(parent_id: assignment.id, deadline_type_id: '6').first
    if !dropDate.nil? && dropDate.due_at < Time.now
      # flash[:error] = "You cannot drop this topic because the drop deadline has passed."
    else
      # if team assignment find the creator id from teamusers table and teams
      # ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
      # to treat all assignments as team assignments
      # users_team will contain the team id of the team to which the user belongs
      users_team = SignedUpTeam.find_team_users(assignment_id, session_user_id)
      signup_record = SignedUpTeam.where(topic_id: topic_id, team_id:  users_team[0].t_id).first
      assignment = Assignment.find(assignment_id)
      # if a confirmed slot is deleted then push the first waiting list member to confirmed slot if someone is on the waitlist
      unless assignment.is_intelligent?
        if signup_record.is_waitlisted == false
          # find the first wait listed user if exists
          first_waitlisted_user = SignedUpTeam.where(topic_id: topic_id, is_waitlisted:  true).first

          unless first_waitlisted_user.nil?
            # As this user is going to be allocated a confirmed topic, all of his waitlisted topic signups should be purged
            ### Bad policy!  Should be changed! (once users are allowed to specify waitlist priorities) -efg
            first_waitlisted_user.is_waitlisted = false
            first_waitlisted_user.save

            # ACS Removed the if condition (and corresponding else) which differentiate assignments as team and individual assignments
            # to treat all assignments as team assignments
            Waitlist.cancel_all_waitlists(first_waitlisted_user.team_id, assignment_id)
            end
        end
      end
      signup_record.destroy unless signup_record.nil?
      end # end condition for 'drop deadline' check
  end
end
