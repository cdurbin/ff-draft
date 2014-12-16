class DailyTeam
  attr_accessor :qb
  attr_accessor :rb1
  attr_accessor :rb2
  attr_accessor :wr1
  attr_accessor :wr2
  attr_accessor :wr3
  attr_accessor :te
  attr_accessor :defense
  attr_accessor :k

  def pretty_print
    "
    QB: #{@qb.name} #{@qb.salary}
    RB1: #{@rb1.name} #{@rb1.salary}
    RB2: #{@rb2.name} #{@rb2.salary}
    WR1: #{@wr1.name} #{@wr1.salary}
    WR2: #{@wr2.name} #{@wr2.salary}
    WR3: #{@wr3.name} #{@wr3.salary}
    TE: #{@te.name} #{@te.salary}
    DEF: #{@defense.name} #{@defense.salary}
    Total points: #{total_points.to_i}
    Points ceiling: #{total_points_high.to_i}
    Points floor: #{total_points_low.to_i}
    Total salary: #{total_salary}"
  end

  def total_salary
    @qb.salary + @rb1.salary + @rb2.salary + @wr1.salary + @wr2.salary + @wr3.salary + @te.salary + @defense.salary + 4500
  end

  def total_points
    @qb.ppr + @rb1.ppr + @rb2.ppr + @wr1.ppr + @wr2.ppr + @wr3.ppr + @te.ppr + @defense.ppr
  end

  def total_points_high
    @qb.ppr_high + @rb1.ppr_high + @rb2.ppr_high + @wr1.ppr_high + @wr2.ppr_high + @wr3.ppr_high + @te.ppr_high + @defense.ppr_high
  end

  def total_points_low
    @qb.ppr_low + @rb1.ppr_low + @rb2.ppr_low + @wr1.ppr_low + @wr2.ppr_low + @wr3.ppr_low + @te.ppr_low + @defense.ppr_low
  end
end