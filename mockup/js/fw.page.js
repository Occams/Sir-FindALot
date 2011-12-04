$ = x$;

// type is one of [slideinfromleft, slideouttoleft, slideinfromright, slideouttoright]
$.fn.css3Slide = function(slideType) {
	this.each(function() {
		var el = $(this);
		el.removeClass($.fn.css3Slide.types).addClass($.fn.css3Slide.typesToClass[slideType]);
	});
}

$.fn.fastbutton = function(handler) {
	this.each(function() {
		new MBP.fastButton(this, handler);
	});
}

$.fn.rAttr = function (attr) {
	this.each(function(el) {
		el.removeAttribute(attr);
	});
}

$.fn.show = function() {
	
	console.log('Show: ' + this.attr('id'));
	
	// Show element
	this.css({display : 'box', display : '-moz-box', display : '-webkit-box'});
	
	// Update IScroll4 object
	var scrollID = $(this).find('.scroller')[0].getAttribute('id');
	
	// IScroll4 doc recommends using setTimeout
	setTimeout(function () { Page.scrollers[scrollID].refresh() }, 0);
	
	// Scroll to top
	Page.scrollers[scrollID].scrollTo(0, 0, 0);
	return this;
}

$.fn.hide = function() {
	console.log('Hide: ' + this.attr('id'));
	
	this.setStyle("display","none");
	return this;
}

$.fn.dimensions = function() {
  element = this[0];
  var display = this.getStyle('display');
  
  if (display && display !== 'none') {
    return { width: element.offsetWidth, height: element.offsetHeight };
  }
  
  // All *Width and *Height properties give 0 on elements with
  // `display: none`, so show the element temporarily.
  /*
  var style = element.style;
  var originalStyles = {
    visibility: style.visibility,
    position:   style.position,
    display:    style.display
  };
  
  var newStyles = {
    visibility: 'hidden',
    display:    'block'
  };

  // Switching `fixed` to `absolute` causes issues in Safari.
  if (originalStyles.position !== 'fixed')
    newStyles.position = 'absolute';
  
  Element.setStyle(element, newStyles);
  */
  var dimensions = {
    width:  element.offsetWidth,
    height: element.offsetHeight
  };
  /*
  Element.setStyle(element, originalStyles);
  */

  return dimensions;
}

$.fn.width = function() {
	return this.dimensions().width;
}

$.fn.height = function() {
	return this.dimensions().height;
}

$.fn.css3Slide.types = "slide in out reverse";
$.fn.css3Slide.typesToClass = {"slideinfromleft":"slide in reverse", "slideouttoleft":"slide out", "slideinfromright":"slide in", "slideouttoright":"slide out reverse"};

String.prototype.idify = function() { return (this.indexOf("#")>-1)?this.substring(this.indexOf("#")+1, this.length):this; };
String.prototype.hashify = function() { return (this[0]=="#")?this:"#"+this; };


var Page = {
	pages: null, //Holds all pages initially present in #viewport
	footer: null, //Holds the references to all footer elements
	viewport: null, // Holds #viewport
	gFooter: null, //Holds a reference to the global footer
	gHeader: null, //Holds a reference to the global header
	id_page_hash: {}, //Hash from page id to page element
	id_pagenum_hash: {}, // Hash from page id to page num
	window_width: 0, // Holds the current width of the window
	current_page: null, // Holds the current page id
	scrollers: {},
	lock:false, 
	

	init: function() {
		this.pages = $("#viewport div[data-type=page]");
		this.footer = $("#viewport footer");
		this.viewport = $('#viewport');
		this.pages.each(function(el, i) {
			Page.id_page_hash[el.getAttribute("id")] = el;
			Page.id_pagenum_hash[el.getAttribute("id")] = i;
		});
		this.gHeader = $("#global-header");
		this.gFooter = $("#global-footer");
		
		hash = window.location.hash;
		
		// iScroll 4 lite
		$('.scroller').each(function(el,i) {
			var id = el.getAttribute("id");
			
			Page.scrollers[id] = new iScroll(id,{ hScroll: false, onBeforeScrollStart: Page._makeIScrollFriendly});
		});
		
		// Show the first page initially
		this.show(this._isPage(hash) ? hash : this.pages[0].getAttribute("id"));
		
		this.window_width = window.innerWidth;
		
		// Attach event handlers to account for androids :active css bug
		this._registerFakeActive();
		
		// Adjust layout based on orientation
		window.addEventListener('orientationchange' in window ? 'orientationchange' : 'resize', function (e) {
		
		});
		
		
		// Modal test
		$('#show_modal').click(function (e) {
			Page._showModal(':: Offline', 'Sir FindALot is very sad and lonely. You have been disconnected from the interwebz.');
		});
		
		$('#modal_close').touchstart(function (e) {
			Page._closeModal();
		});
		
		$('#modal_close').click(function (e) {
			Page._closeModal();
		});
		
		$(".link-list a").fastbutton(function(event) {
			Page.show(this.element.getAttribute("href").idify());
			event.preventDefault();
			return false;
		});
		
		// Gelocation
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(this._geoPosition,this._geoError);
		} else {
			Page._showModal(':: No Geolocation', 'Sorry, your browser does not support geolocation.');
		}
		
	},
	
	_geoPosition: function(position) {
	
		// Fake response delay
		setTimeout(function(e) {
			var geo = $('#geolocation_search');
			$('#loading').setStyle('display','none');
			geo.setStyle('-webkit-animation-name', 'pulse_orange');
			geo.setStyle('-moz-animation-name', 'pulse_orange');
			geo.setStyle('animation-name', 'pulse_orange');
			
			geo.attr('placeholder', 'Touch to enter custom query...');
			geo.rAttr('disabled');
			
			$('#geolocation_container').after('<ul class="link-list" id="geo_results">'+
					'<li><a href="#page2" fake-active="yes">Uni Passau Tiefgarage</a></li>'+
					'<li><a href="#page2" fake-active="yes">Uni Regen Tiefgarage</a></li>' +
					'<li><a href="#page2" fake-active="yes">Uni Zwiesel Tiefgarage</a></li>' +
				'</ul>');
			$('#geo_results a').setStyle('opacity','0');
			setTimeout(function(e) {$('#geo_results a').setStyle('opacity','1');},100);
		}, 3000);
	},
	
	_geoError: function(position) {
		Page._showModal(':: Geolocation', 'Sorry, Sir FindAlot encountered an error while trying to geolocate you.');
	},
	
	_showModal: function (heading, text) {
		var modal = $('#modal');
		var fade = $('#fade');
		
		$('#modal h1').html(heading);
		$('#modal p').html(text);
		
		fade.setStyle('z-index', '1000');
		fade.setStyle('opacity', '0.8');
		modal.css({display : '-webkit-box'});
	},
	
	_closeModal: function () {
		var modal = $('#modal');
		var fade = $('#fade');
		
		fade.setStyle('z-index', '0');
		fade.setStyle('opacity', '0');
		modal.css({display : 'none'});
	},
	
	_makeIScrollFriendly: function (e) {
			// Prevent IScroll on form elements etc.
			var target = e.target;
			
			// bubble up
			while (target.nodeType != 1) target = target.parentNode;

			if (target.tagName != 'SELECT' && target.tagName != 'INPUT' && target.tagName != 'TEXTAREA') {
				e.preventDefault();
			}
	},
	
	layout: function() {
	
	},
	
	show: function(id) {
		if(id=="") id = this.pages[0].id; // If hashchange to no hash show first page
		if(!this._isPage(id)) return;
		if(!this._lock()) return;
	
		if(this.current_page == null) { // If you set the page for the first time...
			this.current_page = id;
			this._updatePageInfos(id);
			this._getPage(id).show();
			this._unlock();
		} else if(id != this.current_page) {
			to = this._getPage(id).show(); // Show the new page so that it can be animated
			from = this._getPage(this.current_page); // Show the current page so that it can be animated
			
			slideLeft = this._getPageNum(id) > this._getPageNum(this.current_page);
			to.css3Slide(slideLeft?"slideinfromright":"slideinfromleft");
			from.css3Slide(slideLeft?"slideouttoleft":"slideouttoright");
			
			this.current_page = id; // Update the current page
			this._updatePageInfos(id);
			
			setTimeout(function (e) {
					Page._getPage(Page.current_page).fire("pageshow");
					window.location.hash = Page.current_page.hashify();
					Page._unlock();
					
					// Hide old page
					from.hide();
				}, 775); // Workaround because event on transtionend does not work properly
		} else {
			this._unlock();
		}
		
		// Refresh iScroll objects because of DOM manipulation
		//for (var id in Page.scrollers)
		//setTimeout(function () { Page.scrollers[id].refresh() }, 0);
	},
	
	_updatePageInfos: function(id) {
		page = this._getPage(id);
		this.gHeader.html(page.find("header")[0].innerHTML);
		this.gFooter.html(page.find("footer")[0].innerHTML);
		
		// Update: Attach event handlers to account for androids :active css bug
		this._registerFakeActive();
		
		// Fastbutton update for toolbar links
		this.gFooter.find("a").fastbutton(function(event) {
			Page.show(this.element.getAttribute("href").idify());
			event.preventDefault();
			return false;
		});
		
		
		$("a[href*='#']").click(Page._stopHash);
	},
	
	_registerFakeActive: function() {
	
		if (navigator.userAgent.toLowerCase().indexOf("android") > -1) {
			$("a[fake-active=yes]").on("touchstart", function () {
        $(this).addClass("fake-active");
				}).on("touchend", function() {
        $(this).removeClass("fake-active");
				}).on("touchcancel", function() {
        // sometimes Android fires a touchcancel event rather than a touchend. Handle this too.
        $(this).removeClass("fake-active");
				});
		}
	},
	
	_getPage: function(id) {
		return $(this.id_page_hash[id]);
	},
	
	_getPageNum: function(id) {
		return this.id_pagenum_hash[id];
	},
	
	_isPage: function(id) {
		return this.id_page_hash[id] != null;
	},
	
	_finishedAnimation: function(event) {
	
	},
	
	_lock: function() {
		if(Page.lock) return false;
		//console.log("lock granted");
		Page.lock = true;
		return true;
	},
	
	_unlock: function() {
		//console.log("lock undone");
		Page.lock = false;
	},
	
	_stopHash: function() {
		Page.show(this.getAttribute("href").idify());
		return false;
	}
};

window.onhashchange = function(event) {
	event.preventDefault();
	//console.log(window.location.hash.idify());
	Page.show(window.location.hash.idify());
	return false;
};

$.ready(function() {
	Page.init();
});
