class PlayersController < ApplicationController

  def show
    @top_values = Players.get_top(20)
    @rbs = RunningBack.order("fantasy_points desc").limit(48)
    @wrs = WideReceiver.order("fantasy_points desc").limit(48)
    @qbs = Quarterback.order("fantasy_points desc").limit(26)
    @tes = TightEnd.order("fantasy_points desc").limit(18)
    @defenses = Defense.order("fantasy_points desc").limit(14)
    @kickers = Kicker.order("fantasy_points desc").limit(14)
  end
end