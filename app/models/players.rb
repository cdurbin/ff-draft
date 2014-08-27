require 'pry'
class Players
  class << self

    NUM_TO_CONSIDER = 24

    def save_players
      positions.each do |pos|
        # Uncomment this to hit the API
        players = FFNerd.draft_projections(pos)
        save_by_position(pos, players)
      end

      # Uncomment this to hit the API
      players = FFNerd.standard_draft_rankings()
      save_rankings(players)
    end

    def find_by_player_id(id)
      player = nil
      positions.each do |pos|
        model = get_class_for_position(pos)
        player = model.class.find_by player_id: id

        break if player
      end
      player
    end




    # def get_top(num)
    #   multiplier = 1.778
    #   rbs = RunningBack.order("fantasy_points desc").limit((multiplier* 4).ceil)
    #   wrs = WideReceiver.order("fantasy_points desc").limit((multiplier* 4).ceil)
    #   qbs = Quarterback.order("fantasy_points desc").limit((multiplier* 2).ceil)
    #   tes = TightEnd.order("fantasy_points desc").limit((multiplier* 1.5).ceil)
    #   # defenses = Defense.order("fantasy_points desc").limit((multiplier* 1).ceil)
    #   # kickers = Kicker.order("fantasy_points desc").limit((multiplier* 1).ceil)
    #   defenses = []
    #   kickers = []

    #   all_lists = [rbs, wrs, qbs, tes, defenses, kickers]
    #   all_lists.each do |position_list|
    #     position_list.each do |player|
    #       player.value_above_nominal = player.fantasy_points - position_list.last.fantasy_points
    #     end
    #   end
    #   all_players = all_lists.flatten
    #   all_players.sort!{|a, b| b.value_above_nominal <=> a.value_above_nominal}
    #   all_players.first(num)
    # end

    def get_top(num, offset)
      # multiplier = 1.778
      # rbs = RunningBack.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # wrs = WideReceiver.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # qbs = Quarterback.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # tes = TightEnd.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # defenses = Defense.order("overall_rank asc").limit(NUM_TO_CONSIDER)
      # kickers = Kicker.order("overall_rank asc").limit(NUM_TO_CONSIDER)

      rbs = RunningBack.order("fantasy_points desc")
      wrs = WideReceiver.order("fantasy_points desc")
      qbs = Quarterback.order("fantasy_points desc")
      tes = TightEnd.order("fantasy_points desc")
      defenses = Defense.order("fantasy_points desc")
      kickers = Kicker.order("fantasy_points desc")

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

    def save_by_position(pos, players)
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

    def save_rankings(players)
      players.each do |player|
        hash = player.marshal_dump
        player_model = get_class_for_position(player.position)
        player_model.attributes = hash.reject{|k,v| !player_model.attributes.keys.member?(k.to_s)}
        existing_record = player_model.class.find_by_player_id player_model.player_id
        if existing_record
          existing_record.attributes = existing_record.attributes.merge(player_model.attributes.reject{|k,v| k.to_s == 'created_at' || v == nil})
          existing_record.save
        else
          puts "New player: #{player.display_name}"
          player_model.save
        end
      end
    end
  end
end