class AdminController < ApplicationController
  def index
    @drafts = Draft.all
    @scoring_settings = ScoringSettings.all
    @leagues = Leagues.all
  end
end