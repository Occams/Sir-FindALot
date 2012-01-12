var Parkingarea = {
	container : x$('#lot div[data-type="page-content"]'),
  fill: function(data) {
    console.log(data);
    this.fillDetailPage(data);
    this.fillMapPage(data);
  },
  
  fillDetailPage: function(data) {
  },
  
  fillMapPage: function(data) {
		
		// If there's more then one level display links
		if (data.parkingplanes.length > 1) {
			this.container.html(this._generate_level_links(data.parkingplanes));
		} else {
			this.container.html(this._generate_map(data.parkingplanes[0]))
		}
  }
	,
	
	_generate_level_links : function (planes,id) {
    var html = '';

    for (var i in planes) {
     var plane = planes[i];
	    html += '<li><a href="" fake-active="yes">';
	    html += '<div class="occupancy"><div class="level"></div><div class="mask"></div></div>';
	    html += '<span class="link-list-title">' + plane['name'] + '</span></a></li>';
    }

    return '<ul class="link-list" id="levels">' + html + '</ul>';
  },
	
	_generate_map : function (plane) {
		var maxX = 0, maxY = 0, html="";
		
		// Determine maximum values
		for (var i in plane.concretes) {
			var c = plane.concretes[i];
			maxX = c.x > maxX ? c.x : maxX;
			maxY = c.y > maxY ? c.y : maxY;
		}
		
		var width = this.container.width();
		
		html += "MaxX: "+maxX+" MaxY:"+maxY+" width:"+width;
		
		return html;
	}
}
