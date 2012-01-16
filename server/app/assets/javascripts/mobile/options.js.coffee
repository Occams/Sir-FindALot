Options =

  geo_slide: null
  purge_btn: null
  init: ->
    @geo_slide = x$("auto_geo_slide")
    @purge_btn = x$("#purge_data")
    auto = eval(localStorage.getItem("auto_geo"))
    if auto
      @geo_slide.find("div.slide").addClass "selected"
    else
      @geo_slide.find("div.slide").removeClass "selected"
    @geo_slide.find("label").fastbutton (e) ->
      label = x$(@element)
      slide = label.attr("rel")
      if label.hasClass("disable")
        console.log "Disabled auto geolocation"
        localStorage.setItem "auto_geo", "false"
      else if label.hasClass("enable")
        console.log "Enabled auto geolocation"
        localStorage.setItem "auto_geo", "true"
      x$("#" + slide).toggleClass "selected"

    @purge_btn.fastbutton (e) ->
      localStorage.clear()
      console.log "Cleared localstorage"
      Page._showModal "Purge Data", "I'm pleased to announce that all collected data has been purged successfully."
      
if typeof exports isnt "undefined"
  exports.Options = Options
else
  window.Options = Options