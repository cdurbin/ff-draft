require "#{ENV['RAILS_ROOT']}/config/environment"

unless ARGV[0]
  puts "Missing week number"
  exit (-1)
end

week = ARGV[0]

File.open("data/Salaries-Week#{week}.csv").each do |line|
  line.delete!("\"")
  line.delete!("\$")
  pos, name, avg, games_played, matchup, salary_thousands, salary_remainder = line.split(',')
  salary = salary_thousands.to_i * 1000 + salary_remainder.to_i
  players = WeeklyRanking.find(:all, :conditions => ["name like ? AND week = ?", "#{name}%", week])
  if (players.length > 1)
    puts "Error found multiple players for #{name}"
  elsif (players.length == 1)
    puts "Found #{name}"
    player = players.first
    player.salary = salary
    player.save!
  else
    puts "Could not find #{name}"
  end
end