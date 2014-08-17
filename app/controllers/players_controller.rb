class PlayersController < ApplicationController

  def index
    if (params[:league_id])

    else
      @top_values = Players.get_top(20, 48)
      @next_values = Players.get_top(20, 72)
      @rbs = RunningBack.order("fantasy_points desc").limit(48)
      @wrs = WideReceiver.order("fantasy_points desc").limit(48)
      @qbs = Quarterback.order("fantasy_points desc").limit(26)
      @tes = TightEnd.order("fantasy_points desc").limit(18)
      @defenses = Defense.order("fantasy_points desc").limit(14)
      @kickers = Kicker.order("fantasy_points desc").limit(14)
    end
  end

  def show
    @player = Players.find_by_player_id(params[:id])
  end

end