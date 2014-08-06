require 'pry'
class Players
  class << self
    def load_players
      positions.each do |pos|
        load_by_position(pos)
      end
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

    def load_by_position(pos)
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