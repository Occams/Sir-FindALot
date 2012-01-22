`Date.prototype.getWeek = function (dowOffset) {
	dowOffset = typeof(dowOffset) == 'int' ? dowOffset : 0; //default dowOffset to zero
	var newYear = new Date(this.getFullYear(),0,1);
	var day = newYear.getDay() - dowOffset; //the day of week the year begins on
	day = (day >= 0 ? day : day + 7);
	var daynum = Math.floor((this.getTime() - newYear.getTime() - 
	(this.getTimezoneOffset()-newYear.getTimezoneOffset())*60000)/86400000) + 1;
	var weeknum;
	//if the year starts before the middle of a week
	if(day < 4) {
		weeknum = Math.floor((daynum+day-1)/7) + 1;
		if(weeknum > 52) {
			nYear = new Date(this.getFullYear() + 1,0,1);
			nday = nYear.getDay() - dowOffset;
			nday = nday >= 0 ? nday : nday + 7;
			/*if the next year starts before the middle of
 			  the week, it is week #1 of that year*/
			weeknum = nday < 4 ? 1 : 53;
		}
	}
	else {
		weeknum = Math.floor((daynum+day-1)/7);
	}
	return weeknum;
};`


class Statistics
  barH : 150
  weekdays: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
  hours: ['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24']
  
  constructor: (container, areaID) ->
    @areaID = areaID
    container.html '<div class="statistic" id="weekly"></div><div class="statistic" id="hourly"></div>'
    @hourlyContainer = container.find("#hourly").html("Loading hourly statistics...")
    @weeklyContainer = container.find("#weekly").html("Loading weekly statistics...")
    
    # Fetch weekly statistic of previous week
    date = new Date()
    date.setDate(date.getDate() - 7)

    x$().xhr "/parkingramps/#{areaID}/stats/week/#{date.getFullYear()}/#{date.getWeek(0)}/#{date.getHours()}.json", () =>
      data = `JSON.parse(this.responseText)`
      @weeklyContainer.html(@_genStatistic(data,"Weekly Statistic",@weekdays))
      
    x$().xhr "/parkingramps/#{areaID}/stats/day/#{date.getFullYear()}/#{date.getMonth()+1}/#{date.getDate()}.json", () =>
      data = `JSON.parse(this.responseText)`
      @hourlyContainer.html(@_genStatistic(data,"Hourly Statistic",@hours))
      
  _genStatistic: (data,header,legend) ->
    html="<div class=\"statistic_header\">#{header}</div>"
    html+='<div class="bars">'
    
    if data.length is 0
      html += "Sorry, there is no data available..."
    
    for i of data
      d = data[i]
      height = (parseInt(d.taken) / parseInt(d.total)) * @barH
      html+='<div class="bar_c">'
      html+="<div class=\"bar\" style=\"height:#{height}px;\"><div class=\"bar_value\">#{d.taken}</div></div>"
      html+="<div class=\"bar_text\">#{legend[i]}</div>"
      html+='</div>'
      
    html+='</div>'
    html

window.Statistics = Statistics
