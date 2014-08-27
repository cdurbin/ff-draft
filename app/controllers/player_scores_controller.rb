class PlayerScoresController < ApplicationController

  def index
    if (params[:draft_id])
      draft = Draft.find_by id: params[:draft_id]
      @draft_id = params[:draft_id]
      @league = League.find_by id: draft.league_id
      @recent_picks = DraftPick.where(draft_id: params[:draft_id]).order("pick_number desc").limit(24)
      @recent_picks.each do |pick|
        pick.display_name = (PlayerScore.find_by(player_id: pick.player_id) || Defense.find_by(player_id: pick.player_id) || Kicker.find_by(player_id: pick.player_id)).display_name
      end
      @rbs = PlayerScore.where({scoring_settings_id: @league.scoring_settings_id, position: "RB"}).order("fantasy_points desc")
      @rbs = DraftPick.filter_taken(@rbs, draft.id).first(32)
      @wrs = PlayerScore.where({scoring_settings_id: @league.scoring_settings_id, position: "WR"}).order("fantasy_points desc")
      @wrs = DraftPick.filter_taken(@wrs, draft.id).first(32)
      @tes = PlayerScore.where({scoring_settings_id: @league.scoring_settings_id, position: "TE"}).order("fantasy_points desc")
      @tes = DraftPick.filter_taken(@tes, draft.id).first(16)
      @qbs = PlayerScore.where({scoring_settings_id: @league.scoring_settings_id, position: "QB"}).order("fantasy_points desc")
      @qbs = DraftPick.filter_taken(@qbs, draft.id).first(16)
      @defenses = Defense.order("fantasy_points desc")
      @defenses = DraftPick.filter_taken(@defenses, draft.id).first(14)

      @kickers = Kicker.order("fantasy_points desc")
      @kickers = DraftPick.filter_taken(@kickers, draft.id).first(14)

      @top_values = PlayerScore.get_top(24, 0, @rbs, @wrs, @qbs, @tes, @defenses, @kickers)
      @next_values = PlayerScore.get_top(24, 24, @rbs, @wrs, @qbs, @tes, @defenses, @kickers)
    end
  end

  def show
    @player = PlayerScore.find_by_player_id(params[:player_id], params[:scoring_settings_id])
  end

end