//= require jquery-ui

$( ->
  $.fn.overlay = (enable) ->
    for el in this
      overlay = $(el).find(".overlay")
      
      if not enable
        overlay.remove()
      else
        if not overlay? or overlay.length is 0
          overlay = $("<div class=\"overlay\"></div>").appendTo($(el));
        
        $(el).css "position", (if $(el).css("position") is "absolute" then "absolute" else "relative")
        overlay.show().css("opacity", 0.5)
        overlay
        
    this
)
