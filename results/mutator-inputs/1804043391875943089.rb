class TeamsController < ApplicationController
  def new
    @parent = Object.const_get(session[:team_type]).find(params[:id])
  end
end
