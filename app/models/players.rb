require 'pry'
class Players
  class << self

    NUM_TO_CONSIDER = 18

    def save_players
      positions.each do |pos|
        save_by_position(pos)
      end
    end

    # def retrieve_players
    #   unless @@all_players
    #     qbs = Quarterback.all
    #     rbs = Runningback.all
    #     wrs = WideReceiver.all
    #     tes = TightEnd.all
    #     defenses = Defense.all
    #     kickers = Kicker.all
    #     @@all_players = [qbs.flatten, rbs.flatten, wrs.flatten, tes.flatten, defenses.flatten, kickers.flatten]
    #   end
    #   @@all_players
    # end

    # FINAL ROSTER: 2 QBs 4 RBs 4 WRs 1.5TEs 1 DEF 1 K
    # Total = 13.5

    # 18 / 13.5 = 1.333
    # 24 / 13.5 = 1.778


    def get_top(num)
      multiplier = 1.778
      rbs = RunningBack.order("fantasy_points desc").limit((multiplier* 4).ceil)
      wrs = WideReceiver.order("fantasy_points desc").limit((multiplier* 4).ceil)
      qbs = Quarterback.order("fantasy_points desc").limit((multiplier* 2).ceil)
      tes = TightEnd.order("fantasy_points desc").limit((multiplier* 1.5).ceil)
      # defenses = Defense.order("fantasy_points desc").limit((multiplier* 1).ceil)
      # kickers = Kicker.order("fantasy_points desc").limit((multiplier* 1).ceil)
      defenses = []
      kickers = []

      all_lists = [rbs, wrs, qbs, tes, defenses, kickers]
      all_lists.each do |position_list|
        position_list.each do |player|
          player.value_above_nominal = player.fantasy_points - position_list.last.fantasy_points
        end
      end
      all_players = all_lists.flatten
      all_players.sort!{|a, b| b.value_above_nominal <=> a.value_above_nominal}
      all_players.first(num)
    end



    private

    def positions
      ['QB', 'RB', 'WR', 'TE', 'DEF', 'K']
    end

    def get_class_for_position(pos)
      pclass = nil
      case pos
      when 'QB'
        pclass = Quarterback.new
      when 'RB'
        pclass = RunningBack.new
      when 'WR'
        pclass = WideReceiver.new
      when 'TE'
        pclass = TightEnd.new
      when 'DEF'
        pclass = Defense.new
      when 'K'
        pclass = Kicker.new
      end
      pclass
    end

    def save_by_position(pos)
      # Uncomment this to hit the API
      # players = FFNerd.draft_projections(pos)
      players.each do |player|
        hash = player.marshal_dump
        player_model = get_class_for_position(pos)
        player_model.attributes = hash.reject{|k,v| !player_model.attributes.keys.member?(k.to_s)}
        begin
          player_model.save
        rescue => e
          if (e.message.include? "PRIMARY KEY must be unique")
            existing_record = player_model.class.find_by_player_id player_model.player_id
            existing_record.attributes = player_model.attributes.reject{|k,v| k.to_s == 'created_at'}
            existing_record.save
          end
        end
      end
    end
  end
end