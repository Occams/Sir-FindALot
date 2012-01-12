var Parkingarea = {
	width : null,
	plane : null, // reference to currently displayed plane
	data : null,
	cellH : 20,
	cellW : 20,
	
	fill : function (data) {
		console.log(data);
		this.fillLevelPage(data);
		this.fillDetailPage(data);
		
		// Initially show first map
		this.fillMapPage(data.parkingplanes[0]);
		this.plane = data.parkingplanes[0];
		this.data = data;
	},
	
	fillDetailPage : function (data) {
		var container = x$('#lot_details div[data-type="page-content"]');
	},
	
	fillLevelPage : function (data) {
		var container = x$('#lot_levels div[data-type="page-content"]');
		
		// generate level links
		var html = '',
		occupancy = [];
		for (var i in data.parkingplanes) {
			var plane = data.parkingplanes[i];
			html += '<li><a href="' + plane.id + '" fake-active="yes">';
			html += '<div class="occupancy"><div class="level"></div><div class="mask"></div>';
			html += '<span class="occupancy-text">' + plane['lots_taken'] + '/' + plane['lots_total'] + '</span></div>';
			html += '<span class="link-list-title">' + plane['name'] + '</span></a></li>';
			occupancy[i] = plane['lots_taken'] / plane['lots_total'];
		}
		
		// fill container
		container.html('<ul class="link-list" id="levels">' + html + '</ul>');
		
		// display occupancy animation
		setTimeout(function (e) {
			x$('#levels').find('.mask').each(function (el, i) {
				x$(el).setStyle('width', (100 - occupancy[i] * 100) + '%');
			})
		}, 300);
		
		x$('#levels a').fastbutton(function (e) {
			var id = this.element.getAttribute('href')
				Parkingarea.fillMapPage(Parkingarea._getPlane(Parkingarea.data, id));
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
		
		for (var i in plane.lots) {
			var l = plane.lots[i];
			maxX = l.x > maxX ? l.x : maxX;
			maxY = l.y > maxY ? l.y : maxY;
		}
		
		for (var i in plane.concretes) {
			html += this._genCell(plane.concretes[i], 'concrete', maxX, maxY);
		}
		
		for (var i in plane.lots) {
			html += this._genCell(plane.lots[i], 'lot', maxX, maxY);
		}
		
		//html += "<p>MaxX: " + maxX + " MaxY:" + maxY + " width:" + this.width + '</p>';
		// fill container
		container.html('<div class="map">' + html + '</div>');
		
		// IScroll update, TODO: test if needed
		x$('#lot_map').fire('update', {
			onlyIScroll : true,
			toTop : true
		});
	},
	
	update : function () {
		this.fillMapPage(this.plane);
	},
	
	_genCell : function (c, classID, maxX, maxY) {
		console.log(c.y);
		left = ((c.x) / maxX) * (this.width),
		width = this.width/maxX,
		top = c.y * this.cellH,
		style = 'left:' + left + 'px; top:' + (c.y * this.cellH) + 'px; width:' + width + 'px;';
		
		return '<div class="' + classID + '" style="' + style + '">' + c.id + '</div>';
	},
	
	_getPlane : function (data, id) {
		
		for (var i in data.parkingplanes) {
			if (data.parkingplanes[i].id == id)
				return data.parkingplanes[i];
		}
		
		return null;
	}
}
