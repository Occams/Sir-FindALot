var Parkingarea = {
	width : null,
	plane : null, // reference to currently displayed plane
	data : null,
	cellH : 20,
	
	fill : function (data) {
		console.log(data);
		this.data = data;
		this.plane = data.parkingplanes[0];
		this.fillLevelPage(data);
		this.fillDetailPage(data);
		
		// Initially show first map
		this.fillMapPage(data.parkingplanes[0]);
	},
	
	fillDetailPage : function (data) {
		var container = x$('#lot_details div[data-type="page-content"]');
		
		// Set header
		x$('#lot_details header').html(data.name + ' - Details');
	},
	
	fillLevelPage : function (data) {
		var container = x$('#lot_levels div[data-type="page-content"]');
		
		// Set header
		x$('#lot_levels header').html(data.name + ' - Levels');
		
		// generate level links
		var html = '',
		occupancy = [];
		for (var i in data.parkingplanes) {
			var plane = data.parkingplanes[i];
			html += '<li><a href="' + plane.id + '" fake-active="yes">';
			html += '<div class="occupancy"><div class="level"></div><div class="mask"></div></div>';
			html += '<span class="link-list-title">' + plane['name'] + '</span>';
			html += '<span class="occupancy-text">'+plane['lots_taken']+'/'+plane['lots_total']+'</span></a></li>';
			
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
		var container = x$('#lot_map div[data-type="page-content"]');
		// Set header
		x$('#lot_map header').html(this.data.name + ' - Map');
		
		maxX = 0,
		minX = Number.MAX_VALUE,
		maxY = 0,
		minY = Number.MAX_VALUE,
		html = "";
		
		// Determine maximum values
		for (var i in plane.concretes) {
			var c = plane.concretes[i];
			maxX = c.x > maxX ? c.x : maxX;
			maxY = c.y > maxY ? c.y : maxY;
			minY = c.y < minY ? c.y : minY;
			minX = c.x < minX ? c.x : minX;
		}
		
		for (var i in plane.lots) {
			var l = plane.lots[i];
			maxX = l.x > maxX ? l.x : maxX;
			maxY = l.y > maxY ? l.y : maxY;
			minY = l.y < minY ? l.y : minY;
			minX = l.x < minX ? l.x : minX;
		}
		
		var padding = 10;
		var width = Math.floor((this.width - 2 * padding) / (maxX - minX + 1));
		
		for (var i in plane.concretes) {
			var c = plane.concretes[i];
			html += this._genCell(c, (c.x - minX) * width + padding, (c.y - minY) * this.cellH + padding,width, ['concrete', c.category]);
		}
		
		for (var i in plane.lots) {
			var l = plane.lots[i];
			html += this._genCell(l, (l.x - minX) * width + padding, (l.y - minY) * this.cellH + padding,width, ['lot', l.category, l.taken ? 'occupied' : 'free']);
		}
		
		console.log("<p>MaxX: " + maxX + " MaxY:" + maxY + " width:" + this.width + "MinX: " + minX + " MinY:" + minY + "</p>");
		
		// fill container
		container.html('<div class="map">' + html + '</div>');
		
		// Set container height
		x$('.map').setStyle('height', this.cellH * (maxY - minY + 1) + 2 * padding +'px');
		
		// IScroll update, TODO: test if needed
		x$('#lot_map').fire('update', {
			onlyIScroll : true,
			toTop : true
		});
	},
	
	update : function () {
		this.fillMapPage(this.plane);
	},
	
	_genCell : function (c, left, top, width,classA) {
		var classes = "",
		style = 'left:' + left + 'px; top:' + top + 'px; width:' + width + 'px;';
		
		for (var i in classA) {
			classes += classA[i] + " ";
		}
		return '<div class="' + classes + '" style="' + style + '"></div>';
	},
	
	_getPlane : function (data, id) {
		
		for (var i in data.parkingplanes) {
			if (data.parkingplanes[i].id == id)
				return data.parkingplanes[i];
		}
		
		return null;
	}
}
