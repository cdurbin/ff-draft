class LeaguesController < ApplicationController
  def create
    raise "Missing league name" if !params[:name]
    raise "Missing scoring settings id" if !params[:scoring_settings_id]
    league = League.new({name: params[:name], scoring_settings_id: params[:scoring_settings_id]})
    league.save!
    render text: league.id
  end
end