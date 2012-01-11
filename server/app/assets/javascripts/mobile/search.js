var Search = {
  parentContainer:null,
  cb:null,

  doSearch: function(needle, geolocation, parentContainer, cb) {
    data = {
      'needle': needle,
      'geolocation': geolocation
    };
    
    this.parentContainer = parentContainer;
    this.cb = cb;
    
    x$().xhr("/searches.json", {method:'POST', data: JSON.stringify(data), async: true, callback: Search.callback});
  },
  
  callback: function() {
    eval('var data = ' + this.responseText);
    console.log(Search.parentContainer);
    x$(Search.parentContainer).html(Search._generate_link_list_search_results(data, 'search_results'));
    
    // Display occupancy animation
    var occupancy = [0.3, 0.7, 1, 0.6, 0.1];

    setTimeout(function (e) {
	    x$(Search.parentContainer).find('.mask').each(function (el, i) {
		    x$(el).setStyle('width', (100 - occupancy[i] * 100) + '%');
	    })
    }, 100);

    // Fade in of geolocation results. No animation without timeout? */
    setTimeout(function (e) {
	    x$(Search.parentContainer).find('.link-list a').setStyle('opacity', '1');
	    x$(Search.parentContainer).find('.link-list').setStyle('opacity', '1');
    }, 25);
    
    
    x$('.link-list a').fastbutton(function (e) {
      Page._displayLoadingAnimation();
      x$().xhr(this.element.getAttribute('href'), Page._parkingrampLoaded);
      e.preventDefault();
      return false;
    });
    if(Search.cb != null) Search.cb();
  },
  
  _generate_link_list_search_results : function (data, id) {
    var html = '';

    for (var i in data) {
     var single = data[i];
	    html += '<li><a href="/parkingramps/' + single['id'] + '.json" fake-active="yes">';
	    html += '<div class="occupancy"><div class="level"></div><div class="mask"></div></div>';
	    html += '<span class="link-list-title">' + single['name'] + '</span></a></li>';
    }

    return '<ul class="link-list" id="' + id + '">' + html + '</ul>';
  },
};
