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

var Geolocate = {
  init: function() {
    $("#foo").bind("pageshow", function() {
      Geolocate.setLoading(true);
      setTimeout(Geolocate.success, 3000);
    }).trigger("pageshow");
    
    $("#geolocate").bind('click', function() {$("#foo").trigger("pageshow");});
  },
  setLoading: function(enable) {
    Geolocate.loadingStatus = 1;
    if(enable) {
      Geolocate.interval = setInterval(function() {
        $("#geolocate .ui-btn-text").html("Locating" + Geolocate.multiply(".", Geolocate.loadingStatus, "&#160;", 3));
        Geolocate.loadingStatus += 1;
        Geolocate.loadingStatus %= 4;
      },500);
    } else {
      clearInterval(Geolocate.interval);
    }
  },
  multiply: function(str, count, filler, filluptill) {
    d = "";
    for(i = 0; i < count; i++) d+=str;
    for(; i < filluptill; i++) d+=filler;
    return d;
  },
  success: function(position) {
    Geolocate.setLoading(false);
    $("#geolocate .ui-btn-text").html("Relocate");
    $(".speech-a").empty().html('I found some parking lots near you! If you are not satisfied with the results try again by tapping the <b>Relocate</b> button or issue a <b>custom search</b> further down.');
    Search.showResults('<li><a href="#three">Uni Passau Tiefgarage</a></li><li><a href="#three">Uni Passau Tiefgarage</a></li><li><a href="#three">Uni Passau Tiefgarage</a></li>');
  },
  error: function(msg) {
    $("#geolocate .ui-btn-text").html("failed");
  }
};

var Search = {
  data: ["Amberg","Ansbach","Aschaffenburg","Augsburg","Bamberg","Bayreuth","Coburg","Erlangen","Fürth","Hof","Ingolstadt","Kaufbeuren","Kempten (Allgäu)","Landshut","Memmingen","München Landeshauptstadt","Nürnberg","Passau","Regensburg","Rosenheim","Schwabach","Schweinfurt","Straubing","Weiden in der Oberpfalz","Würzburg"],
  init: function() {
    $("#search").bind("change", function(event, ui) {
      $.mobile.changePage($("#two"));
      $("#two ul").empty();
      var needle = "^"+$("#search").val().toLowerCase();
      $.each(Search.data, function(i, el) {
        if(el.toLowerCase().match(needle) != null) {
          availability = Math.floor(Math.random()*100);
          $("#two ul").append('<li><a href="#three"><h3>' + el + ' Tiefgarage</h3><p><strong></strong></p><span class="ui-li-count" style="color:#'+Color.transition(0x00FF00, 0xFF0000 ,availability/100).toString(16) +';">' + availability + '%</span></a></li>');
        }
      });
      $("#two ul").listview('refresh');
    });
  },
  
  showResults: function(data) {
    $("#fastresults").html(data).listview('refresh');
  }
};

$(function() {
  Geolocate.init();
  Search.init();
});
