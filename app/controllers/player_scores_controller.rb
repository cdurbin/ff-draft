class PlayerScoresController < ApplicationController

  def index
    if (params[:league_id])

      # @top_values = PlayerScore.get_top(20, 48)
      # @next_values = PlayerScore.get_top(20, 72)
      league = League.find_by id: params[:league_id]
      @rbs = PlayerScore.where({scoring_settings_id: league.scoring_settings_id, position: "RB"}).order("fantasy_points desc").limit(48)
      # @wrs = PlayerScore.find_by({player_id: params[:player_id], scoring_settings_id: params[:scoring_settings_id]}, position: "WR").order("fantasy_points desc").limit(48)
      # @qbs = PlayerScore.find_by({player_id: params[:player_id], scoring_settings_id: params[:scoring_settings_id]}, position: "QB").order("fantasy_points desc").limit(26)
      # @tes = PlayerScore.find_by({player_id: params[:player_id], scoring_settings_id: params[:scoring_settings_id]}, position: "TE").order("fantasy_points desc").limit(18)
      # @defenses = PlayerScore.find_by({player_id: params[:player_id], scoring_settings_id: params[:scoring_settings_id]}, position: "DEF").order("fantasy_points desc").limit(14)
      # @kickers = PlayerScore.find_by({player_id: params[:player_id], scoring_settings_id: params[:scoring_settings_id]}, position: "K").order("fantasy_points desc").limit(14)
    end
  end

  def show
    @player = PlayerScore.find_by_player_id(params[:player_id], params[:score_id])
  end

  # def create
  #   PlayerScore
  # end

end