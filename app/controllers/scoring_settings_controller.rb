class ScoringSettingsController < ApplicationController
  def create
    scoring_settings = ScoringSetting.new({name: params[:name],
      passing_yards: params[:passing_yards],
      int_thrown: params[:int_thrown],
      passing_td: params[:passing_td],
      misc_2pc: params[:misc_2pc],
      rush_yards: params[:rush_yards],
      rush_td: params[:rush_td],
      fumbles_lost: params[:fumbles_lost],
      rec: params[:rec],
      rec_yards: params[:rec_yards],
      rec_td: params[:rec_td],
      return_yards: params[:return_yards],
      misc_td: params[:misc_td]})
    scoring_settings.save!
    render text: scoring_settings.id
  end

  def show
    @scoring_settings = ScoringSettings.find_by id: params[:id]
  end

end