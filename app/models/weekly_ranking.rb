require 'pry'

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

  def self.best_average_points_per_dollar(week_number)
    players = WeeklyRanking.where('week = ? AND salary > 0', week_number)
    players.sort!{|a, b| b.ppr / b.salary <=> a.ppr / a.salary}
    players.each do |player|
      Rails.logger.info "#{player.position}: #{player.name}: #{(player.ppr / player.salary * 6667).to_i}"
    end
  end

  def self.best_floor_points_per_dollar(week_number)
    players = WeeklyRanking.where('week = ? AND salary > 0', week_number)
    players.sort!{|a, b| b.ppr_low / b.salary <=> a.ppr_low / a.salary}
    players.each do |player|
      Rails.logger.info "#{player.position}: #{player.name}: #{(player.ppr_low / player.salary * 6667).to_i}"
    end
  end

  def self.best_ceiling_points_per_dollar(week_number)
    players = WeeklyRanking.where('week = ? AND salary > 0', week_number)
    players.sort!{|a, b| b.ppr_high / b.salary <=> a.ppr_high / a.salary}
    players.each do |player|
      Rails.logger.info "#{player.position}: #{player.name}: #{(player.ppr_high / player.salary * 6667).to_i}"
    end
  end

  def self.find_best_team(week_number)
    players = WeeklyRanking.where('week = ? and salary > 0 and ppr > 0', week_number)
    players.sort!{|a, b| b.ppr / b.salary <=> a.ppr / a.salary}
    team = DailyTeam.new
    players.each do |player|
      # Add player to team if position is not already filled
      if (player.position == 'QB')
        team.qb = player unless team.qb
      elsif (player.position == 'RB')
        team.rb1 = player unless team.rb1
        team.rb2 = player unless (team.rb1.player_id == player.player_id || team.rb2)
      elsif (player.position == 'WR')
        if (!team.wr1)
          team.wr1 = player
        elsif (!team.wr2)
          team.wr2 = player
        elsif (!team.wr3)
          team.wr3 = player
        end
      elsif (player.position == 'TE')
        team.te = player unless team.te
      elsif (player.position == 'DEF')
        team.defense = player unless team.defense
      end
    end
    puts "Team with salary #{team.total_salary} is #{team.pretty_print}"

    # worst_points_per_dollar = team.get_lowest_points_per_dollar
    # puts "Worst performer: #{worst_points_per_dollar.name} #{worst_points_per_dollar.position}"
    # players_position = WeeklyRanking.where('week = ? and salary > 0 and ppr > 0 and position = ?', week_number, worst_points_per_dollar.position)
    # players_position.sort!{|a, b| b.ppr_high / b.salary <=> a.ppr_high / a.salary}

  end

  def self.pick_optimal_lineup(week_number)
    qb_list = eliminate_players(week_number, 'QB')
    rb1_list = eliminate_players(week_number, 'RB')
    rb2_list = eliminate_players(week_number, 'RB')
    wr1_list = eliminate_players(week_number, 'WR')
    wr2_list = eliminate_players(week_number, 'WR')
    wr3_list = eliminate_players(week_number, 'WR')
    te_list = eliminate_players(week_number, 'TE')
    def_list = eliminate_players(week_number, 'DEF')
    max_score = 0
    allowed_salary = 55500

    best_team = DailyTeam.new
    qb_list.each do |qb|
      my_salary = qb.salary
      my_points = qb.ppr
      rb1_list.each do |rb1|
        my_salary = qb.salary + rb1.salary
        my_points = qb.ppr + rb1.ppr
        rb2_list.each do |rb2|
          if (rb1.player_id != rb2.player_id)
            my_salary = qb.salary + rb1.salary + rb2.salary
            my_points = qb.ppr + rb1.ppr + rb2.ppr
            wr1_list.each do |wr1|
              my_salary = qb.salary + rb1.salary + rb2.salary + wr1.salary
              my_points = qb.ppr + rb1.ppr + rb2.ppr + wr1.ppr
              wr2_list.each do |wr2|
                if (wr1.player_id != wr2.player_id)
                  my_salary = qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary
                  my_points = qb.ppr + rb1.ppr + rb2.ppr + wr1.ppr + wr2.ppr
                  wr3_list.each do |wr3|
                    if (wr1.player_id != wr3.player_id && wr2.player_id != wr3.player_id)
                      my_salary = qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary + wr3.salary
                      my_points = qb.ppr + rb1.ppr + rb2.ppr + wr1.ppr + wr2.ppr + wr3.ppr
                      te_list.each do |te|
                        my_salary = qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary + wr3.salary + te.salary
                        my_points = qb.ppr + rb1.ppr + rb2.ppr + wr1.salary + wr2.salary + wr3.salary + te.ppr
                        def_list.each do |defense|
                          my_points = my_points + defense.ppr
                          my_salary = my_salary + defense.salary
                          if (my_salary <= allowed_salary && my_points > max_score)
                            max_score = my_points
                            best_team.qb = qb
                            best_team.rb1 = rb1
                            best_team.rb2 = rb2
                            best_team.wr1 = wr1
                            best_team.wr2 = wr2
                            best_team.wr3 = wr3
                            best_team.te = te
                            best_team.defense = defense
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    puts "Best Team: #{best_team.pretty_print}"
  end

  def self.eliminate_players(week_number, pos)
    players = WeeklyRanking.where('week = ? and salary > 0 and ppr > 0 and position = ?', week_number, pos)
    puts "#{pos} List size = #{players.length}"
    filtered_player_list = []
    players.each do |player|
      skip = false
      players.each do |player_compare|
        if ((player.salary > player_compare.salary && player.ppr <= player_compare.ppr) ||
          (player.salary >= player_compare.salary && player.ppr < player_compare.ppr))
          # more expensive and fewer points
          # puts "Throwing out : #{player.name}"
          skip = true
          break
        end
      end
      filtered_player_list.push(player) unless skip
    end
    puts "Final #{pos} list: #{filtered_player_list.length}"
    filtered_player_list.each do |player|
      puts "#{player.name}: #{player.salary} #{player.ppr}"
    end
    filtered_player_list
  end

  def self.eliminate_players_orig(week_number)
    # Shrink the lists for each position
    all_pos = ['QB', 'RB', 'WR', 'TE', 'DEF']
    all_pos.each do |pos|
      players = WeeklyRanking.where('week = ? and salary > 0 and ppr > 0 and position = ?', week_number, pos)
      puts "#{pos} List size = #{players.length}"
      filtered_player_list = []
      players.each do |player|
        skip = false
        players.each do |player_compare|
          if ((player.salary > player_compare.salary && player.ppr <= player_compare.ppr) ||
            (player.salary >= player_compare.salary && player.ppr < player_compare.ppr))
            # more expensive and fewer points
            # puts "Throwing out : #{player.name}"
            skip = true
            break
          end
        end
        filtered_player_list.push(player) unless skip
      end
      puts "Final #{pos} list: #{filtered_player_list.length}"
      filtered_player_list.each do |player|
        puts "#{player.name}: #{player.salary} #{player.ppr}"
      end
    end
    nil
  end
end