class StatisticsClass
  barH : 150
  weekdays: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
  hours: ['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24']
  fill: (container,areaID) ->
    test1 = [{"created_at":"2012-01-18T00:30:00Z","taken":12,"total":96,"weekday":1},
            {"created_at":"2012-01-18T00:30:00Z","taken":47,"total":96,"weekday":2},
            {"created_at":"2012-01-18T00:30:00Z","taken":96,"total":96,"weekday":3},
            {"created_at":"2012-01-18T00:30:00Z","taken":78,"total":96,"weekday":4},
            {"created_at":"2012-01-18T00:30:00Z","taken":24,"total":96,"weekday":5},
            {"created_at":"2012-01-18T00:30:00Z","taken":35,"total":96,"weekday":6},
            {"created_at":"2012-01-18T00:30:00Z","taken":65,"total":96,"weekday":7}]
    test2 = [{"created_at_hour":12,"taken":10,"total":96},
            {"created_at_hour":12,"taken":12,"total":96},
            {"created_at_hour":12,"taken":13,"total":96},
            {"created_at_hour":12,"taken":24,"total":96},
            {"created_at_hour":12,"taken":14,"total":96},
            {"created_at_hour":12,"taken":17,"total":96},
            {"created_at_hour":12,"taken":12,"total":96},
            {"created_at_hour":12,"taken":47,"total":96},
            {"created_at_hour":12,"taken":68,"total":96},
            {"created_at_hour":12,"taken":50,"total":96},
            {"created_at_hour":12,"taken":80,"total":96},
            {"created_at_hour":12,"taken":85,"total":96},
            {"created_at_hour":12,"taken":96,"total":96},
            {"created_at_hour":12,"taken":96,"total":96},
            {"created_at_hour":12,"taken":90,"total":96},
            {"created_at_hour":12,"taken":92,"total":96},
            {"created_at_hour":12,"taken":50,"total":96},
            {"created_at_hour":12,"taken":67,"total":96},
            {"created_at_hour":12,"taken":43,"total":96},
            {"created_at_hour":12,"taken":25,"total":96},
            {"created_at_hour":12,"taken":29,"total":96},
            {"created_at_hour":12,"taken":32,"total":96},
            {"created_at_hour":12,"taken":15,"total":96},
            {"created_at_hour":12,"taken":7,"total":96}]        
   
    container.html (@_genStatistic(test1,"Weekly Statistic",@weekdays) + @_genStatistic(test2,"Hourly Statistic",@hours))
    
  _genStatistic: (data,header,legend) ->
    html= '<div class="statistic">'
    html+="<div class=\"statistic_header\">#{header}</div>"
    html+='<div class="bars">'
    
    for i of data
      d = data[i]
      height = (parseInt(d.taken) / parseInt(d.total)) * @barH
      html+='<div class="bar_c">'
      html+="<div class=\"bar\" style=\"height:#{height}px;\"><div class=\"bar_value\">#{d.taken}</div></div>"
      html+="<div class=\"bar_text\">#{legend[i]}</div>"
      html+='</div>'
      
    html+='</div></div>'
    html

  window.Statistics = new StatisticsClass
