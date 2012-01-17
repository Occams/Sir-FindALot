module StatFindExtension
  def stats_by_weekday_and_hour(year, week, hour)
    wkBegin = (Date.commercial year, week, 1).beginning_of_day
    wkEnd = (Date.commercial year, week, 7).end_of_day
    stats = self.stat_by(
      wkBegin,
      wkEnd,
      ["sum(stats.lots_taken)/count(stats.lots_taken) as taken", "sum(stats.lots_total)/count(stats.lots_total) as total", "stats.created_at", "-1 as weekday"],
      [:created_at_year, :created_at_month, :created_at_day],
      {:created_at_hour => hour}
    )
    stats.each do |stat|
      stat.weekday = (stat.created_at.wday+6)%7
    end
  end
  
  def stats_by_month_and_hour(year, hour)
    wkBegin = DateTime.new year, 1, 1, 0, 0, 0
    self.stat_by(
      wkBegin,
      wkBegin.end_of_year,
      ["sum(stats.lots_taken)/count(stats.lots_taken) as taken", "sum(stats.lots_total)/count(stats.lots_total) as total, created_at_month"],
      [:created_at_year, :created_at_month],
      {:created_at_hour => hour}
    )
  end


  def stats_by_hour(year, month, day)
    wkBegin = DateTime.new year, month, day, 0 , 0, 0
    self.stat_by(
      wkBegin,
      wkBegin.end_of_day,
      ["sum(stats.lots_taken)/count(stats.lots_taken) as taken", "sum(stats.lots_total)/count(stats.lots_total) as total, created_at_hour"],
      [:created_at_year, :created_at_month, :created_at_day, :created_at_hour]
    )
  end
  
  def stat_by(datet_start, datet_end, select, groupby, conditions = {})
    self.find(:all, :group => groupby, :select => select, :conditions => {:created_at => datet_start..datet_end}.merge(conditions))
  end
  
end
