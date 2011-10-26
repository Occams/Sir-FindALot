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
		if(!navigator.geolocation) {
			$("#geolocate").detach();
		} else {
			// Below does not work if the html does not lie on a host...
			/*
			$( "#geolocate" ).bind( "click", function(event, ui) {
				if (navigator.geolocation) {
				  navigator.geolocation.getCurrentPosition(Geolocate.success, Geolocate.error);
				} else {
				  Geolocation.error("Not Supported!");
				}
			});
			*/

			// Instead of doing the above, fake the geolocation
			$( "#geolocate" ).bind( "click", function(event, ui) {
				$.mobile.changePage($("#two"));

				// Insert the fake data
				$("#two ul").html(' \
				<li><a href="#three"> \
					<h3>Uni Passau Tiefgarage</h3>  \
					<p><strong></strong></p>  \
					<span class="ui-li-count" style="color:green;">90%</span> \
				</a></li> \
				<li><a href="#three">  \
						<h3>Zentralgarage Exerzierplatz</h3>  \
						<p><strong></strong></p>  \
						<span class="ui-li-count" style="color:orange;">20%</span> \
				</a></li>  \
				<li><a href="#three">  \
						<h3>Stadgalerie</h3>  \
						<p><strong></strong></p>  \
						<span class="ui-li-count" style="color:red;">5%</span> \
				</a></li>').listview('refresh');
				return false;
			});
		}
	},
	success: function(position) {
		alert(position.coords.latitude + " | " + position.coords.longitude);
	},
	error: function(msg) {
		$("#geolocate").html("failed");
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
	}
};

$(function() {
	Geolocate.init();
	Search.init();
});
