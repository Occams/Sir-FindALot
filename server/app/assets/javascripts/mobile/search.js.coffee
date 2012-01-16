Search =
  LOGSIZE: 20
  
  doSearch: (needle, geolocation, target, callback, error) ->
    data =
      needle: needle
      geolocation: geolocation
      history: LocalStorage.get("history", [])

    _this = this
    x$().xhr "/searches.json",
      method: "POST"
      data: "search=" + JSON.stringify(data)
      async: true
      callback: ->
        _this.callback @responseText, target
        callback()  if callback?

      error: ->
        error()  if error?

  log: (rampid) ->
    hist = LocalStorage.get("history", [])
    hist.push
      date: Date.now()
      id: rampid

    hist.sort (a, b) ->
      b.date - a.date

    LocalStorage.put "history", hist.slice(0, Search.LOGSIZE)

  callback: (response, target) ->
    data = JSON.parse(response)
    x$(target).html Search._generate_link_list_search_results(data, "search_results")
    
    occupancy = []
    for i of data
      area = data[i]
      occupancy[i] = area["lots_taken"] / area["lots_total"]
    setTimeout ((e) ->
      x$(target).find(".mask").each (el, i) ->
        x$(el).setStyle "width", (100 - occupancy[i] * 100) + "%"
    ), 350
    x$(".link-list a").fastbutton (e) ->
      Page._displayLoadingAnimation()
      x$().xhr @element.getAttribute("href"),
        callback: Page._parkingAreaLoaded
        error: Page._hideLoadingAnimation

      e.preventDefault()
      false

  _generate_link_list_search_results: (data, id) ->
    if data.length is 0
      "<p id=\"empty_result\">Sorry, i was not able to find what you are looking for.</p>"
    else
      html = ""
      for i of data
        single = data[i]
        distance = Position.distance(single.longitude, single.latitude)
        d = Math.round(distance * 100) / 100 + " km"
        d = Math.round(distance * 1000) + " m"  if distance < 1
        title = (if distance then ("<span style=\"color:green\">(" + d + ")</span>") else "(N/A)") + " - " + single["name"]
        html += "<li><a href=\"/parkingramps/" + single["id"] + ".json\" fake-active=\"yes\">"
        html += "<div class=\"occupancy\"><div class=\"level\"></div><div class=\"mask\"></div></div>"
        html += "<span class=\"link-list-title\">" + title + "</span>"
        html += "<span class=\"occupancy-text\">" + single["lots_taken"] + "/" + single["lots_total"] + "</span></a></li>"
      "<ul class=\"link-list\" id=\"" + id + "\">" + html + "</ul>"
      
if typeof exports isnt "undefined"
  exports.Search = Search
else
  window.Search = Search