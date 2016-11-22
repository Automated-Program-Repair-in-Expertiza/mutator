class TeamsController < ApplicationController
  def delete
    # delete records in team, teams_users, signed_up_teams table
    @team = Team.find(params[:id])
    course = Object.const_get(session[:team_type]).find(@team.parent_id)

    @signUps = SignedUpTeam.where(team_id: @team.id)

    @teams_users = TeamsUser.where(team_id: @team.id)

    if @signUps.size == 1 and @signUps.first.is_waitlisted == false # this team hold a topic
      # if there is another team in waitlist, make this team hold this topic
      topic_id = @signUps.first.topic_id
      next_wait_listed_team = SignedUpTeam.where(topic_id: topic_id, is_waitlisted: true).first
      # if slot exist, then confirm the topic for this team and delete all waitlists for this team
      if next_wait_listed_team
        SignUpTopic.assign_to_first_waiting_team(next_wait_listed_team)
      end
    end

    @signUps.destroy_all if @signUps
    @teams_users.destroy_all if @teams_users
    @team.destroy if @team

    undo_link("The team \"#{@team.name}\" has been successfully deleted.")
    redirect_to action: 'list', id: course.id
  end
end
