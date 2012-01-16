class ParkingareaClass
  width: null
  plane: null
  data: null
  cellH: 20
  fill: (data) ->
    @data = data
    @plane = data.parkingplanes[0]
    @fillLevelPage()
    @fillDetailPage()
    @fillMapPage(@plane)

  fillDetailPage: ->
    container = x$("#lot_details div[data-type=\"page-content\"]")
    x$("#lot_details header").html @data.name + " - Details"
    html = ""
    html += @_genDetailsHeader("Type")
    html += @_genDetailsContent("This parking area is a " + @data.category + " and features a total of " + @data.parkingplanes.length + " parking levels. Currently there are " + (@data.lots_total - @data.lots_taken) + " free lots available.")
    html += @_genDetailsHeader("Address")
    html += @_genDetailsContent(@data.info_address)
    html += @_genDetailsHeader("Opening Hours")
    html += @_genDetailsContent(@data.info_openinghours)
    html += @_genDetailsHeader("Pricing")
    html += @_genDetailsContent(@data.info_pricing)
    html += @_genDetailsHeader("Current status")
    html += @_genDetailsContent(@data.info_status)
    html += @_genDetailsHeader("Geolocation")
    html += @_genDetailsContent("Longitude: " + @data.longitude + " - Latitude: " + @data.latitude)
    html += @_genDetailsHeader("Time of creation")
    html += @_genDetailsContent(@data.created_at)
    html += @_genDetailsHeader("Last update")
    html += @_genDetailsContent(@data.updated_at)
    container.html html

  _genDetailsHeader: (header) ->
    "<h1 class=\"details-header\">:: " + header + "</h1>"

  _genDetailsContent: (content) ->
    "<p class=\"details-content\">" + content + "</p>"

  fillLevelPage: ->
    container = x$("#lot_levels #levels_container")
    x$("#lot_levels header").html @data.name + " - Levels"
    html = ""
    occupancy = []
    for i of @data.parkingplanes
      plane = @data.parkingplanes[i]
      star = (if (plane.id is @data.best_level) then "star_level" else "")
      html += "<li class=\"" + star + "\"><a href=\"" + plane.id + "\" fake-active=\"yes\">"
      html += "<div class=\"occupancy\"><div class=\"level\"></div><div class=\"mask\"></div></div>"
      html += "<span class=\"link-list-title\">" + plane["name"] + "</span>"
      html += "<span class=\"occupancy-text\">" + plane["lots_taken"] + "/" + plane["lots_total"] + "</span></a></li>"
      occupancy[i] = plane["lots_taken"] / plane["lots_total"]
      
    container.html "<ul class=\"link-list\" id=\"levels\">" + html + "</ul>"
    
    setTimeout (() ->
      x$("#levels").find(".mask").each (el, i) ->
        x$(el).setStyle "width", (100 - occupancy[i] * 100) + "%"
    ), 300
    
    x$("#levels a").fastbutton (e) =>
      id = `this.element.getAttribute("href")`
      plane = @_getPlane(parseInt(id));
      @fillMapPage(plane)
      Page.show "lot_map"
      e.preventDefault()
      false

  fillMapPage: (plane) ->
    container = x$("#lot_map #map_container")
    x$("#lot_map header").html(@data.name + " - " + plane.name)
    maxX = 0
    minX = Number.MAX_VALUE
    maxY = 0
    minY = Number.MAX_VALUE
    html = ""

    for i of plane.concretes
      c = plane.concretes[i]
      maxX = (if c.x > maxX then c.x else maxX)
      maxY = (if c.y > maxY then c.y else maxY)
      minY = (if c.y < minY then c.y else minY)
      minX = (if c.x < minX then c.x else minX)
    for i of plane.lots
      l = plane.lots[i]
      maxX = (if l.x > maxX then l.x else maxX)
      maxY = (if l.y > maxY then l.y else maxY)
      minY = (if l.y < minY then l.y else minY)
      minX = (if l.x < minX then l.x else minX)
    padding = 10
    width = Math.floor((@width - 2 * padding) / (maxX - minX + 1))
    for i of plane.concretes
      c = plane.concretes[i]
      html += @_genCell(c, (c.x - minX) * width + padding, (c.y - minY) * @cellH + padding, width, [ "concrete", c.category ])
    for i of plane.lots
      l = plane.lots[i]
      classes = [ "lot", l.category, (if l.taken then "occupied" else "free") ]
      classes.push "star"  if @_containsLot(l, plane.best_lots)
      html += @_genCell(l, (l.x - minX) * width + padding, (l.y - minY) * @cellH + padding, width, classes)
    container.html "<div class=\"map\">" + html + "</div>"
    x$(".map").setStyle "height", @cellH * (maxY - minY + 1) + 2 * padding + "px"

  _containsLot: (l, bestlots) ->
    for i of bestlots
      return true  if l.id is bestlots[i].id
    false

  update: ->
    @fillMapPage(@plane) if @plane

  _genCell: (c, left, top, width, classA) ->
    classes = ""
    style = "left:" + left + "px; top:" + top + "px; width:" + width + "px;"
    for i of classA
      classes += classA[i] + " "
    "<div class=\"" + classes + "\" style=\"" + style + "\"></div>"

  _getPlane: (id) ->
    for i in @data.parkingplanes
      return i if i.id is id
    null
    
  window.Parkingarea = new ParkingareaClass
