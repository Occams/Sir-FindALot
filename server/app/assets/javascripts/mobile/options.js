var Options = {
	geo_slide : null,
	purge_btn : null,
	
	init : function () {
		this.geo_slide = x$('auto_geo_slide');
		this.purge_btn = x$('#purge_data');
		
		// Set initial position of slide
		var auto = eval(localStorage.getItem('auto_geo'));
		if (auto) {
			this.geo_slide.find('div.slide').addClass('selected');
		} else {
			this.geo_slide.find('div.slide').removeClass('selected');
		}
		
		// Register event handlers
		this.geo_slide.find('label').fastbutton(function (e) {
			var label = x$(this.element),
			slide = label.attr('rel');
			
			if (label.hasClass('disable')) {
				console.log('Disabled auto geolocation');
				localStorage.setItem('auto_geo', 'false');
			} else if (label.hasClass('enable')) {
				console.log('Enabled auto geolocation');
				localStorage.setItem('auto_geo', 'true');
			}
			
			x$('#' + slide).toggleClass('selected');
		});
		
		this.purge_btn.fastbutton(function (e) {
			localStorage.clear();
			console.log('Cleared localstorage');
			Page._showModal('Purge Data', "I'm pleased to announce that all collected data has been purged successfully.");
		});
		
	}
};
