var Search = {
	LOGSIZE : 20,
	
	doSearch : function (needle, geolocation, target, callback, error) {
		data = {
			'needle' : needle,
			'geolocation' : geolocation,
			'history' : LocalStorage.get("history", [])
		};
		
		_this = this;
		
		x$().xhr("/searches.json", {
			method : 'POST',
			data : "search=" + JSON.stringify(data),
			async : true,
			callback : function () {
				_this.callback(this.responseText, target);
				if (callback != null)
					callback();
			},
			error : function () {
				if (error != null)
					error();
			}
		});
	},
	
	log : function (rampid) {
		hist = LocalStorage.get("history", [])
			hist.push({
				date : Date.now(),
				id : rampid
			})
			
			// Only hold the newest 20 searches
			hist.sort(function (a, b) {
				return b.date - a.date;
			});
		LocalStorage.put("history", hist.slice(0, Search.LOGSIZE))
	},
	
	callback : function (response, target) {
		var data = JSON.parse(response);
		x$(target).html(Search._generate_link_list_search_results(data, 'search_results'));
		
		// Fade in of geolocation results. No animation without timeout? */
		setTimeout(function (e) {
			x$(target).find('.link-list a').setStyle('opacity', '1');
			x$(target).find('.link-list').setStyle('opacity', '1');
		}, 50);
		
		// Display occupancy animation
		var occupancy = [];
		for (var i in data) {
			var area = data[i];
			occupancy[i] = area['lots_taken'] / area['lots_total'];
		}
		
		setTimeout(function (e) {
			x$(target).find('.mask').each(function (el, i) {
				x$(el).setStyle('width', (100 - occupancy[i] * 100) + '%');
			})
		}, 300);
		
		x$('.link-list a').fastbutton(function (e) {
			Page._displayLoadingAnimation();
			x$().xhr(this.element.getAttribute('href'), {
				callback : Page._parkingAreaLoaded,
				error : Page._hideLoadingAnimation
			});
			e.preventDefault();
			return false;
		});
	},
	
	_generate_link_list_search_results : function (data, id) {

		if (data.length == 0) {
			return '<p id="empty_result">Sorry, i was not able to find what you are looking for.</p>';
		} else {
			var html = '';
			for (var i in data) {
				var single = data[i];
        var distance = Position.distance(single.longitude,single.latitude);
        var d = Math.round(distance*100)/100+' km';
        
        if (distance < 1) {
          d = Math.round(distance*1000)+' m';
        }
        var title = (distance ? ('<span style="color:green">('+d+')</span>') : '(N/A)')+' - ' + single['name'];
				html += '<li><a href="/parkingramps/' + single['id'] + '.json" fake-active="yes">';
				html += '<div class="occupancy"><div class="level"></div><div class="mask"></div></div>';
				html += '<span class="link-list-title">' + title + '</span>';
				html += '<span class="occupancy-text">' + single['lots_taken'] + '/' + single['lots_total'] + '</span></a></li>';
			}
			
			return '<ul class="link-list" id="' + id + '">' + html + '</ul>';
		}
	}
};
