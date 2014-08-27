class PlayerScoresController < ApplicationController

  def index
    if (params[:draft_id])
      draft = Draft.find_by id: params[:draft_id]
      @draft_id = params[:draft_id]
      @league = League.find_by id: draft.league_id
      @recent_picks = DraftPick.where(draft_id: params[:draft_id]).order("pick_number desc").limit(20)
      @recent_picks.each do |pick|
        pick.display_name = (PlayerScore.find_by(player_id: pick.player_id) || Defense.find_by(player_id: pick.player_id) || Kicker.find_by(player_id: pick.player_id)).display_name
      end
      @rbs = PlayerScore.where({scoring_settings_id: @league.scoring_settings_id, position: "RB"}).order("fantasy_points desc").limit(48)
      @rbs = DraftPick.filter_taken(@rbs, draft.id)
      @wrs = PlayerScore.where({scoring_settings_id: @league.scoring_settings_id, position: "WR"}).order("fantasy_points desc").limit(48)
      @wrs = DraftPick.filter_taken(@wrs, draft.id)
      @tes = PlayerScore.where({scoring_settings_id: @league.scoring_settings_id, position: "TE"}).order("fantasy_points desc").limit(18)
      @tes = DraftPick.filter_taken(@tes, draft.id)
      @qbs = PlayerScore.where({scoring_settings_id: @league.scoring_settings_id, position: "QB"}).order("fantasy_points desc").limit(26)
      @qbs = DraftPick.filter_taken(@qbs, draft.id)
      @defenses = Defense.order("fantasy_points desc").limit(14)
      @defenses = DraftPick.filter_taken(@defenses, draft.id)

      @kickers = Kicker.order("fantasy_points desc").limit(14)
      @kickers = DraftPick.filter_taken(@kickers, draft.id)

      @top_values = PlayerScore.get_top(20, 0, @rbs, @wrs, @qbs, @tes, @defenses, @kickers)
      @next_values = PlayerScore.get_top(20, 24, @rbs, @wrs, @qbs, @tes, @defenses, @kickers)
    end
  end

  def show
    @player = PlayerScore.find_by_player_id(params[:player_id], params[:scoring_settings_id])
  end

end