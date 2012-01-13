//= require jquery
//= require jquery_ujs


class Slideshow
  constructor: (id, links) ->
    _this = this
    @links = $(links)
    @box = $(id)
    
    @links.find("a").click (e) ->
      href = $(this).attr("href")
      href = href.substring(href.lastIndexOf("#"), href.length)
      _this.show(href, this)
    
    @links.find("a").first().trigger("click")
      
  show: (id, link) ->
    @links.find("a").removeClass "active"
    @box.find(".slide").removeClass "active"
    $(id).addClass "active"
    $(link).addClass "active"

window.Slideshow = Slideshow

$( ->
  new Slideshow("#slides", "#slides-links")
)
