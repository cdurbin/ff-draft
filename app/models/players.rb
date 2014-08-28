class Players
  class << self

    NUM_TO_CONSIDER = 24

    def save_players
      positions.each do |pos|
        # Uncomment this to hit the API
        #players = FFNerd.draft_projections(pos)
        save_by_position(pos, players)
      end

      # Uncomment this to hit the API
      #players = FFNerd.standard_draft_rankings()
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