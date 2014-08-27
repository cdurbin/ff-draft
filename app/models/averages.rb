require 'pry'
class Averages

  def self.getAverage
    # positions = ['QB', 'RB', 'WR', 'TE', 'K', 'DEF']
    positions = ['RB']
    @@values = {QB: 285, RB: 158, WR: 142, TE: 103, K: 120, DEF: 114}
    positions.each do |position|
      # players = FFNerd.draft_projections(position)
      # players = [
      #   OpenStruct.new({
      #       displayName: "Jamaal Charles",
      #       fantasyPoints: "262",
      #       fumbles: "2",
      #       playerId: "145",
      #       rec: "65",
      #       recTD: "4",
      #       recYards: "587",
      #       rushAtt: "255",
      #       rushTD: "9",
      #       rushYards: "1297",
      #       team: "KC",
      #       display_name: "Jamaal Charles",
      #       fantasy_points: "262",
      #       player_id: "145",
      #       rec_td: "4",
      #       rec_yards: "587",
      #       rush_att: "255",
      #       rush_td: "9",
      #       rush_yards: "1297"
      #   }),
      #   OpenStruct.new({
      #       displayName: "LeSean McCoy",
      #       fantasyPoints: "257",
      #       fumbles: "2",
      #       playerId: "810",
      #       rec: "42",
      #       recTD: "3",
      #       recYards: "379",
      #       rushAtt: "292",
      #       rushTD: "10",
      #       rushYards: "1455",
      #       team: "PHI",
      #       display_name: "LeSean McCoy",
      #       fantasy_points: "257",
      #       player_id: "810",
      #       rec_td: "3",
      #       rec_yards: "379",
      #       rush_att: "292",
      #       rush_td: "10",
      #       rush_yards: "1455"
      #   })]

      puts players
      # players.marshal_dump
      # puts players
      # if (position == 'RB' || position == 'WR')
      #   players = players.values_at(0...30)
      # else
      #   players = players.values_at(0...12)
      # end

      ## Don't need points anymore
      # points = players.map{ |player| player.fantasy_points }
      # total_points = 0
      # points.each do |point|
      #   point = point.to_i
      #   # puts "Point is #{point}"
      #   total_points += point
      # end
      # @@values[position.to_sym] = total_points / players.length
      players.each do |player|
        puts "#{player.display_name}: #{player.fantasy_points.to_i - @@values[position.to_sym]}"
        hash = player.marshal_dump
        rb = RunningBack.new
        rb.attributes = hash.reject{|k,v| !rb.attributes.keys.member?(k.to_s) }
        begin
          rb.save
        rescue => e
          if (e.message.include? "PRIMARY KEY must be unique")
            existing_record = RunningBack.find_by_player_id rb.player_id
            existing_record.attributes = rb.attributes.reject{|k,v| k.to_s == 'created_at'}
            existing_record.save
          end
        end
      end
    end
    puts "Values = #{@@values}"
  end
end
