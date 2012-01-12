var Parkingarea = {
	width : null,
	
	fill : function (data) {
		console.log(data);
		this.fillLevelPage(data);
		this.fillDetailPage(data);
		
		// Initially show first map
		this.fillMapPage(data.parkingplanes[0]);
	},
	
	fillDetailPage : function (data) {
		var container = x$('#lot_details div[data-type="page-content"]');
	},
	
	fillLevelPage : function (data) {
		var container = x$('#lot_levels div[data-type="page-content"]');
		
		// generate level links
		var html = '';
		for (var i in data.parkingplanes) {
			var plane = data.parkingplanes[i];
			html += '<li><a href="'+plane.id+'" fake-active="yes">';
			html += '<div class="occupancy"><div class="level"></div><div class="mask"></div></div>';
			html += '<span class="link-list-title">' + plane['name'] + '</span></a></li>';
		}
		
		// fill container
		container.html('<ul class="link-list" id="levels">' + html + '</ul>');
		
		x$('#levels').fastbutton(function (e) {
			Page.show('lot_map');
			e.preventDefault();
			return false;
		});
	},
	
	fillMapPage : function (plane) {
		var container = x$('#lot_map div[data-type="page-content"]'),
		maxX = 0,
		maxY = 0,
		html = "";
		
		// Determine maximum values
		for (var i in plane.concretes) {
			var c = plane.concretes[i];
			maxX = c.x > maxX ? c.x : maxX;
			maxY = c.y > maxY ? c.y : maxY;
		}
		
		html += "MaxX: " + maxX + " MaxY:" + maxY + " width:" + this.width;
		// fill container
		container.html('<ul class="link-list" id="levels">' + html + '</ul>');
	},
	
	update : function () {},
	
	_generate_map : function (plane) {
		
		return html;
	}
}
