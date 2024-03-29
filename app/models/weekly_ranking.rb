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
  end

  def self.pick_optimal_lineup(week_number, field, max_score = 0, rb1_list = nil, rb2_list = nil, wr1_list = nil, wr2_list = nil, wr3_list = nil, best_team = nil)
    orig_max_score = max_score
    qb_list = eliminate_players(week_number, 'QB', field, 1)
    rb1_list = eliminate_players(week_number, 'RB', field, 1) unless rb1_list
    rb2_list = eliminate_players(week_number, 'RB', field, 1) unless rb2_list
    wr1_list = eliminate_players(week_number, 'WR', field, 1) unless wr1_list
    wr2_list = eliminate_players(week_number, 'WR', field, 1) unless wr2_list
    wr3_list = eliminate_players(week_number, 'WR', field, 1) unless wr3_list
    te_list = eliminate_players(week_number, 'TE', field, 1)
    def_list = eliminate_players(week_number, 'DEF', field, 1)

    top_qb_points = qb_list.first.send(field.to_sym)
    top_rb_points = rb1_list.first.send(field.to_sym)
    top_wr_points = wr1_list.first.send(field.to_sym)
    second_wr_points = wr1_list.second.send(field.to_sym)
    top_te_points = te_list.first.send(field.to_sym)
    top_def_points = def_list.first.send(field.to_sym)

    # puts "Top scorer values:
    # QB: #{top_qb_points}
    # RB: #{top_rb_points}
    # WR: #{top_wr_points}
    # TE: #{top_te_points}
    # DEF: #{top_def_points}"

    allowed_salary = 55500

    best_team ||= DailyTeam.new
    qb_list.each do |qb|
      my_salary = qb.salary
      my_points = qb.send(field.to_sym)
      rb1_list.each do |rb1|
        my_salary = qb.salary + rb1.salary
        my_points = qb.send(field.to_sym) + rb1.send(field.to_sym)
        rb2_list.each do |rb2|
          if (rb1.player_id != rb2.player_id && rb2.salary <= rb1.salary)
            my_salary = qb.salary + rb1.salary + rb2.salary
            my_points = qb.send(field.to_sym) + rb1.send(field.to_sym) + rb2.send(field.to_sym)
            wr1_list.each do |wr1|
              my_salary = qb.salary + rb1.salary + rb2.salary + wr1.salary
              my_points = qb.send(field.to_sym) + rb1.send(field.to_sym) + rb2.send(field.to_sym) + wr1.send(field.to_sym)
              if (my_points + top_wr_points + second_wr_points + top_te_points + top_def_points > max_score)
                wr2_list.each do |wr2|
                  if (wr1.player_id != wr2.player_id && wr2.salary <= wr1.salary)
                    my_salary = qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary
                    if ((allowed_salary - my_salary) >= 13500)
                      my_points = qb.send(field.to_sym) + rb1.send(field.to_sym) + rb2.send(field.to_sym) + wr1.send(field.to_sym) + wr2.send(field.to_sym)
                      if (my_points + top_wr_points + top_te_points + top_def_points > max_score)
                        wr3_list.each do |wr3|
                          if (wr1.player_id != wr3.player_id && wr2.player_id != wr3.player_id && wr3.salary <= wr2.salary)
                            my_salary = qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary + wr3.salary
                            if ((allowed_salary - my_salary) >= 9000)
                              my_points = qb.send(field.to_sym) + rb1.send(field.to_sym) + rb2.send(field.to_sym) + wr1.send(field.to_sym) + wr2.send(field.to_sym) + wr3.send(field.to_sym)
                              if (my_points + top_te_points + top_def_points > max_score)
                                te_list.each do |te|
                                  my_salary = qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary + wr3.salary + te.salary
                                  if ((allowed_salary - my_salary) >= 4500)
                                    my_points = qb.send(field.to_sym) + rb1.send(field.to_sym) + rb2.send(field.to_sym) + wr1.send(field.to_sym) + wr2.send(field.to_sym) + wr3.send(field.to_sym) + te.send(field.to_sym)
                                    if (my_points + top_def_points > max_score)
                                      def_list.each do |defense|
                                        my_points = my_points + defense.send(field.to_sym)
                                        my_salary = my_salary + defense.salary
                                        if (my_salary <= allowed_salary)
                                          if (my_points > max_score)
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
                                          break
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
                end
              end
            end
          end
        end
      end
    end

    if (max_score != orig_max_score)
      puts "Best Team: #{best_team.pretty_print}"
      # Iterate through again
      rb_list = eliminate_players(week_number, 'RB', field, 2)
      wr_list = eliminate_players(week_number, 'WR', field, 3)
      pick_optimal_lineup(week_number, field, max_score, rb_list, rb_list, wr_list, wr_list, wr_list, best_team)
    else
      puts "No change in team detected"
    end
  end


  # def self.pick_optimal_lineup_2(week_number, field, max_score = 0, rb2_list = nil, wr2_list = nil, wr3_list = nil, best_team = nil)
  #   orig_max_score = max_score
  #   qb_list = eliminate_players(week_number, 'QB', field, 1)
  #   rb1_list = eliminate_players(week_number, 'RB', field, 2)
  #   rb2_list = eliminate_players(week_number, 'RB', field, 2) unless rb2_list
  #   wr1_list = eliminate_players(week_number, 'WR', field, 3)
  #   wr2_list = eliminate_players(week_number, 'WR', field, 3) unless wr2_list
  #   wr3_list = eliminate_players(week_number, 'WR', field, 3) unless wr3_list
  #   te_list = eliminate_players(week_number, 'TE', field, 1)
  #   def_list = eliminate_players(week_number, 'DEF', field, 1)

  #   top_qb_points = qb_list.first.send(field.to_sym)
  #   top_rb_points = rb1_list.first.send(field.to_sym)
  #   top_wr_points = wr1_list.first.send(field.to_sym)
  #   second_wr_points = wr1_list.second.send(field.to_sym)
  #   top_te_points = te_list.first.send(field.to_sym)
  #   top_def_points = def_list.first.send(field.to_sym)

  #   # puts "Top scorer values:
  #   # QB: #{top_qb_points}
  #   # RB: #{top_rb_points}
  #   # WR: #{top_wr_points}
  #   # TE: #{top_te_points}
  #   # DEF: #{top_def_points}"

  #   allowed_salary = 55500

  #   best_team ||= DailyTeam.new
  #   def_list.each do |defense|
  #     my_points = defense.send(field.to_sym)
  #     my_salary = defense.salary
  #     te_list.each do |te|
  #       my_points = defense.send(field.to_sym) + te.send(field.to_sym)
  #       my_salary = defense.salary + te.salary
  #       qb_list.each do |qb|
  #         my_salary = defense.salary + te.salary + qb.salary
  #         my_points = defense.send(field.to_sym) + te.send(field.to_sym) + qb.send(field.to_sym)
  #         rb1_list.each do |rb1|
  #           my_salary = defense.salary + te.salary + qb.salary + rb1.salary
  #           my_points = defense.send(field.to_sym) + te.send(field.to_sym) + qb.send(field.to_sym) + rb1.send(field.to_sym)
  #           rb2_list.each do |rb2|
  #             if (rb1.player_id != rb2.player_id && rb2.salary <= rb1.salary)
  #               my_salary = defense.salary + te.salary + qb.salary + rb1.salary + rb2.salary
  #               if ((allowed_salary - my_salary) >= 13500)
  #                 my_points = defense.send(field.to_sym) + te.send(field.to_sym) + qb.send(field.to_sym) + rb1.send(field.to_sym) + rb2.send(field.to_sym)
  #                 wr1_list.each do |wr1|
  #                   my_salary = defense.salary + te.salary + qb.salary + rb1.salary + rb2.salary + wr1.salary
  #                   if ((allowed_salary - my_salary) >= 9000)
  #                     my_points = defense.send(field.to_sym) + te.send(field.to_sym) + qb.send(field.to_sym) + rb1.send(field.to_sym) + rb2.send(field.to_sym) + wr1.send(field.to_sym)
  #                     if (my_points + top_wr_points + second_wr_points > max_score)
  #                       wr2_list.each do |wr2|
  #                         if (wr1.player_id != wr2.player_id && wr2.salary <= wr1.salary)
  #                           my_salary = defense.salary + te.salary + qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary
  #                           if ((allowed_salary - my_salary) >= 4500)
  #                             my_points = defense.send(field.to_sym) + te.send(field.to_sym) + qb.send(field.to_sym) + rb1.send(field.to_sym) + rb2.send(field.to_sym) + wr1.send(field.to_sym) + wr2.send(field.to_sym)
  #                             if (my_points + top_wr_points > max_score)
  #                               wr3_list.each do |wr3|
  #                                 if (wr1.player_id != wr3.player_id && wr2.player_id != wr3.player_id && wr3.salary <= wr2.salary)
  #                                   my_salary = defense.salary + te.salary + qb.salary + rb1.salary + rb2.salary + wr1.salary + wr2.salary + wr3.salary
  #                                   my_points = defense.send(field.to_sym) + te.send(field.to_sym) + qb.send(field.to_sym) + rb1.send(field.to_sym) + rb2.send(field.to_sym) + wr1.send(field.to_sym) + wr2.send(field.to_sym) + wr3.send(field.to_sym)
  #                                   if (my_salary <= allowed_salary)
  #                                     if (my_points > max_score)
  #                                       max_score = my_points
  #                                       best_team.qb = qb
  #                                       best_team.rb1 = rb1
  #                                       best_team.rb2 = rb2
  #                                       best_team.wr1 = wr1
  #                                       best_team.wr2 = wr2
  #                                       best_team.wr3 = wr3
  #                                       best_team.te = te
  #                                       best_team.defense = defense
  #                                     end
  #                                     break
  #                                   end
  #                                 end
  #                               end
  #                             end
  #                           end
  #                         end
  #                       end
  #                     end
  #                   end
  #                 end
  #               end
  #             end
  #           end
  #         end
  #       end
  #     end
  #   end

    # if (max_score != orig_max_score)
    #   # Iterate through again
    #   rb2_list = eliminate_players(week_number, 'RB', field, 2, [best_team.rb1, best_team.rb2])
    #   wr2_list = eliminate_players(week_number, 'WR', field, 3, [best_team.wr1, best_team.wr2, best_team.wr3])
    #   wr3_list = eliminate_players(week_number, 'WR', field, 3, [best_team.wr1, best_team.wr2, best_team.wr3])
    #   puts "Best Team: #{best_team.pretty_print}"
    #   pick_optimal_lineup(week_number, field, max_score, rb2_list, wr2_list, wr3_list, best_team)
    # else
    #   puts "No change in team detected"
    # end
  #end

  def self.eliminate_players(week_number, pos, field, num_positions, player_list = nil)
    players = WeeklyRanking.where('week = ? and salary > 0 and ppr > 0 and position = ?', week_number, pos).order(salary: :desc)
    # puts "#{pos} List size = #{players.length}"
    players = players - player_list if player_list
    # puts "#{pos} After removing players List size = #{players.length}"
    filtered_player_list = []
    players.each do |player|
      num_better = 0
      players.each do |player_compare|
        if ((player.salary > player_compare.salary && player.send(field.to_sym) <= player_compare.send(field.to_sym)) ||
          (player.salary >= player_compare.salary && player.send(field.to_sym) < player_compare.send(field.to_sym)))
          # more expensive and fewer points
          # puts "Throwing out : #{player.name}"
          num_better = num_better + 1
          break if (num_better >= num_positions)
        end
      end
      filtered_player_list.push(player) unless num_better >= num_positions
    end
    # puts "Final #{pos} list: #{filtered_player_list.length}"
    filtered_player_list = filtered_player_list + player_list if player_list
    puts "#{pos} list: #{filtered_player_list.length}"
    # filtered_player_list.each do |player|
    #   puts "#{player.name}: #{player.salary} #{player.ppr}"
    # end
    filtered_player_list
  end

end