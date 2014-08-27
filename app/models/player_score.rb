require 'pry'

class PlayerScore < ActiveRecord::Base
  attr_accessor :value_above_nominal

  NUM_TO_CONSIDER = 24
  def self.save_scores(scoring_settings_id)
    ss = ScoringSetting.find_by id: scoring_settings_id
    rbs = RunningBack.where.not(fumbles: nil)
    score_flexes(rbs, 'RB', ss)
    wrs = WideReceiver.where.not(fumbles: nil)
    score_flexes(wrs, 'WR', ss)
    tes = TightEnd.where.not(fumbles: nil)
    score_flexes(tes, 'TE', ss)
    qbs = Quarterback.where.not(passing_td: nil)
    score_qbs(qbs, ss)
  end

  def self.get_top(num, offset, rbs, wrs, qbs, tes, defenses, kickers)
      # multiplier = 1.778
      # rbs = RunningBack.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # wrs = WideReceiver.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # qbs = Quarterback.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # tes = TightEnd.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # defenses = Defense.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # kickers = Kicker.order("overall_rank asc").limit(NUM_TO_CONSIDER)

      # rbs = RunningBack.order("fantasy_points desc")
      # wrs = WideReceiver.order("fantasy_points desc")
      # qbs = Quarterback.order("fantasy_points desc")
      # tes = TightEnd.order("fantasy_points desc")
      # defenses = Defense.order("fantasy_points desc")
      # kickers = Kicker.order("fantasy_points desc")

      all_lists = [rbs, wrs, qbs, tes, defenses, kickers]
      new_list = []
      all_lists.each do |position_list|
        comparison = nil
        num_to_skip = nil
        i = 0
        while (!comparison)
          player = position_list[i]
          if (player.overall_rank > offset && !num_to_skip)
            num_to_skip = i
          end
          if (player.overall_rank > NUM_TO_CONSIDER + offset)
            comparison = player.fantasy_points
            if (num_to_skip != i)
              position_list = position_list.slice(num_to_skip..i)
            else
              position_list = []
            end
          end
          i = i+1
        end
        position_list.each do |new_player|
          new_player.value_above_nominal = new_player.fantasy_points - comparison
        end
        new_list.push(position_list)
      end
      all_players = new_list.flatten
      all_players.sort!{|a, b| b.value_above_nominal <=> a.value_above_nominal}
      all_players.first(num)
  end

  def self.save_rankings(scoring_settings_id)
    rbs = PlayerScore.where({scoring_settings_id: scoring_settings_id, position: "RB"}).order("fantasy_points desc")
    wrs = PlayerScore.where({scoring_settings_id: scoring_settings_id, position: "WR"}).order("fantasy_points desc")
    tes = PlayerScore.where({scoring_settings_id: scoring_settings_id, position: "TE"}).order("fantasy_points desc")
    qbs = PlayerScore.where({scoring_settings_id: scoring_settings_id, position: "QB"}).order("fantasy_points desc")
    # defenses = Defense.order("fantasy_points desc")
    # kickers = Kicker.order("fantasy_points desc")

    last_rb = rbs.at(29)
    last_wr = wrs.at(29)
    last_te = tes.at(11)
    # last_defense = defenses.at(11)
    # last_kicker = kickers.at(11)
    last_qb = qbs.at(11)

    # [rbs, last_rb, wrs, last_wr, qbs, last_qb, tes, last_te, defenses, last_defense, kickers, last_kicker].each do |players, nominal_player|
    [[rbs, last_rb], [wrs, last_wr], [qbs, last_qb], [tes, last_te]].each do |positions_array|
      players = positions_array.at(0)
      nominal_player = positions_array.at(1)
      players.each do |player|
        player.value_above_nominal = player.fantasy_points - nominal_player.fantasy_points
      end
    end
    # all_players = [rbs, wrs, qbs, tes, defenses, kickers].flatten
    all_players = [rbs, wrs, qbs, tes].flatten
    all_players.sort!{|a, b| b.value_above_nominal <=> a.value_above_nominal}
    i = 1
    all_players.each do |player|
      player.overall_rank = i
      player.save
      i = i + 1
    end

  end
  private

  def self.score_flexes(players, position, ss)
    players.each do |flex|
      fp = 0
      fp = fp + ss.rush_yards * flex.rush_yards
      fp = fp + ss.rush_td * flex.rush_td
      fp = fp + ss.fumbles_lost * flex.fumbles
      fp = fp + ss.rec * flex.rec
      fp = fp + ss.rec_yards * flex.rec_yards
      fp = fp + ss.rec_td * flex.rec_td
      # fp = fp + ss.return_yards * flex.return_yards
      # fp = fp + ss.misc_td * flex.misc_td
      # fp = fp + ss.misc_2pc * flex.misc_2pc
      ps = PlayerScore.find_by({player_id: flex.player_id, scoring_settings_id: ss.id}) || PlayerScore.new({
        player_id: flex.player_id,
        display_name: flex.display_name,
        scoring_settings_id: ss.id,
        fantasy_points: fp,
        position: position,
        overall_rank: flex.overall_rank
        })
      ps.save
    end
  end

  def self.score_qbs(players, ss)
    players.each do |qb|
      fp = 0
      fp = fp + ss.rush_yards * qb.rush_yards
      fp = fp + ss.rush_td * qb.rush_td
      fp = fp + ss.int_thrown * qb.passing_int
      # fp = fp + ss.completions * qb.completions
      fp = fp + ss.passing_yards * qb.passing_yards
      fp = fp + ss.passing_td * qb.passing_td
      # fp = fp + ss.return_yards * qb.return_yards
      # fp = fp + ss.misc_td * qb.misc_td
      # fp = fp + ss.misc_2pc * qb.misc_2pc
      ps = PlayerScore.find_by({player_id: qb.player_id, scoring_settings_id: ss.id}) || PlayerScore.new({
        player_id: qb.player_id,
        display_name: qb.display_name,
        scoring_settings_id: ss.id,
        fantasy_points: fp,
        position: 'QB',
        overall_rank: qb.overall_rank
        })
      ps.save
    end
  end
end