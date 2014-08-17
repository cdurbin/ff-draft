class LeaguesController < ApplicationController
  def create
    raise "Missing league name" if !params[:name]
    league = League.new(name: params[:name])
    league.save!
    render text: league.id
  end
end