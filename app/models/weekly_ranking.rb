class WeeklyRanking < ActiveRecord::Base
  def self.save_rankings_for_week(week_number)
    positions = ['QB', 'RB', 'WR', 'TE', 'DEF']
    positions.each do |position|
      players = FFNerd.weekly_rankings(position, week_number)
      players.each do |player|
        hash = player.marshal_dump
        player_model = WeeklyRanking.new()
        player_model.attributes = hash.reject{|k,v| !player_model.attributes.keys.member?(k.to_s)}
        existing_record = player_model.class.find_by(player_id: player_model.player_id, week: week_number)
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