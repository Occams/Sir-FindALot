var Color = {
  transition: function(c1, c2, pos) {
    r1 = (c1&0xFF0000)>>16;
    g1 = (c1&0x00FF00)>>8;
    b1 = c1&0x0000FF;
    
    r2 = (c2&0xFF0000)>>16;
    g2 = (c2&0x00FF00)>>8;
    b2 = c2&0x0000FF;

    r = Math.floor(r1*pos+r2*(1-pos));
    g = Math.floor(g1*pos+g2*(1-pos));
    b = Math.floor(b1*pos+b2*(1-pos));
    return (r<<16)|(g<<8)|b;
  }
};

var ProgressBar = {
  speed: 600,
  easing: "linear",

  init: function(el) {
    el = $(el).empty().append("<div class=\"ui-progressbar-value ui-btn-corner-all\"></div>");
    el.addClass("ui-progressbar ui-btn-corner-all").show();
    
    slider = el.find(".ui-progressbar-value");
    slider.moveLeft = function() { slider.animate({left:"0%"}, ProgressBar.speed, ProgressBar.easing, slider.moveRight); };
    slider.moveRight = function() { slider.animate({left:"80%"}, ProgressBar.speed, ProgressBar.easing, slider.moveLeft); };
    slider.moveLeft();
  },
  
  stop: function(el) {
    el = $(el).hide();
    el.find(".ui-progressbar-value").stop();
  }
}



var Geolocate = {
  geolocateButton:null,
  geolocateAbortButton:null,
  geolocate:true,

  init: function() {
    this.geolocateButton = $("#geolocate");
    this.geolocateAbortButton = $("#abort_geolocate");
  
    // Bind geolocate button click
    this.geolocateButton.bind('click', function(event, ui) {
      Geolocate.start();
    });
    
    
    // Hide abort button
    this.geolocateAbortButton.hide().bind('click', function(event, ui) {
      Geolocate.stop();
    });
    
    
    // Page show start geolocating
    $("#foo").bind("pageshow", function() {
      Geolocate.start();
    });
  },
  
  start: function() {
    ProgressBar.init("#progressbar");
    Geolocate.geolocateButton.hide();
    Geolocate.geolocateAbortButton.show();
    Geolocate.geolocate = setTimeout(Geolocate.success, 3000);
  },
  
  stop: function() {
    ProgressBar.stop("#progressbar");
    Geolocate.geolocateButton.show();
    Geolocate.geolocateAbortButton.hide();
    clearTimeout(Geolocate.geolocate);
  },
  
  success: function(position) {
    Geolocate.stop();
    $.mobile.changePage("#two");
    $("#two ul").html(Utility.createList(["Parkplatz Universität", "Innstadt", "Einkaufszentrum"])).listview("refresh");
  },
  error: function(msg) {
    $("#geolocate .ui-btn-text").html("failed");
  }
};

var Search = {
  init: function() {
    $("#search").bind("change", function(event, ui) {
      $.mobile.changePage($("#two"));
      $.mobile.changePage("#two");
      $("#two ul").html(Utility.createList(["Parkplatz Universität", "Innstadt", "Einkaufszentrum"])).listview("refresh");
    });
  },
  
  showResults: function(data) {
    $("#fastresults").html(data).listview('refresh');
  }
};

var Utility = {
  createList: function(arr) {
    str = "";
    $.each(arr, function(i, el) { str+= "<li><a href=\"#three\">"+el+"</a></li>"; });
    return str;
  }
};

$(function() {
  Geolocate.init();
  Search.init();
});
