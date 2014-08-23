class PlayerScore < ActiveRecord::Base
  def self.save_scores(scoring_settings_id)
    ss = ScoringSetting.find_by id: scoring_settings_id
    # positions = [RunningBack, WideReceiver, Quarterback, TightEnd, Defense, Kicker]
    rbs = RunningBack.where.not(fumbles: nil)
    rbs.each do |rb|
      fp = 0
      fp = fp + ss.rush_yards * rb.rush_yards
      fp = fp + ss.rush_td * rb.rush_td
      fp = fp + ss.fumbles_lost * rb.fumbles
      fp = fp + ss.rec * rb.rec
      fp = fp + ss.rec_yards * rb.rec_yards
      fp = fp + ss.rec_td * rb.rec_td
      # fp = fp + ss.return_yards * rb.return_yards
      # fp = fp + ss.misc_td * rb.misc_td
      # fp = fp + ss.misc_2pc * rb.misc_2pc
      ps = PlayerScore.find_by({player_id: rb.player_id, scoring_settings_id: ss.id}) || PlayerScore.new({
            player_id: rb.player_id,
            display_name: rb.display_name,
            scoring_settings_id: ss.id,
            fantasy_points: fp,
            position: "RB"
          })
      ps.save
    end
  end
end