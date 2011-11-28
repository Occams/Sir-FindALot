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

$.fn.show = function() {
	this.setStyle("display","block");
	return this;
}

$.fn.hide = function() {
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
		
		// Show pages temporarily (iScroll needs to know the actual dimensions of the wrapper)
		$('div[data-type=page]').css({visibility:'hidden', display:'block'});
		
		$('.scroller').each(function(el,i) {
			var id = el.getAttribute("id");
			
			Page.scrollers[id] = new iScroll(id,{ hScroll: false, vScrollbar: false, hScrollbar:false,});
			
			//$(el).touchmove(function (e) {
			//	e.preventDefault();
			//	return false;
			//});
		});
		
		// Hide them again
		$('div[data-type=page]').css({visibility:'visible', display:'none'});
		
		// TODO: Fallback page if pages[0] == null
		// Show the first page initially
		this.show(this._isPage(hash) ? hash : this.pages[0].getAttribute("id"));
		
		this.window_width = window.innerWidth;
		this.layout();
		
		// Attach event handlers to account for androids :active css bug
		this._registerFakeActive();
		
		
		// On DOM manipulation call
		// setTimeout(function () { scroller1.refresh() }, 0);
		
		// Adjust layout based on orientation
		//window.addEventListener('orientationchange' in window ? 'orientationchange' : 'resize', function (e) {
		//	Page.layout();
		//});
	},
	
	layout: function() {
		//this.footer.setStyle("width", this.window_width);
		
		// set height of #viewport to avoid sliding "glitches"
		//this.viewport.setStyle('height',(window.innerHeight - this.gFooter.height() - this.gHeader.height())+'px');
		//console.log('Set viewport height to: '+$('#'+this.current_page).height());
	},
	
	show: function(id) {
		if(id=="") id = this.pages[0].id; // If hashchange to no hash show first page
		if(!this._isPage(id)) return;
		if(!this._lock()) return;
	
		if(this.current_page == null) { // If you set the page for the first time...
			this.current_page = id;
			this._getPage(id).show();
			this._updatePageInfos(id);
			this._unlock();
		} else if(id != this.current_page) {
			//this.pages.hide(); // Hide all animation pages
			to = this._getPage(id).show(); // Show the new page so that it can be animated
			from = this._getPage(this.current_page).show(); // Show the current page so that it can be animated
		
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
				}, 1025); // Workaround because event on transtionend does not work properly
		} else {
			this._unlock();
		}
		
		// Refresh iScroll objects because of DOM manipulation
		for (var id in Page.scrollers)
			setTimeout(function () { Page.scrollers[id].refresh() }, 0);
	},
	
	_updatePageInfos: function(id) {
		page = this._getPage(id);
		this.gHeader.html(page.find("header")[0].innerHTML);
		this.gFooter.html(page.find("footer")[0].innerHTML);
		
		// Update: Attach event handlers to account for androids :active css bug
		this._registerFakeActive();
		
		//Toolbar width
		//els = this.gFooter.find(".toolbar li");
		//this.gFooter.find(".toolbar").setStyle("width", els.length*($(els[0]).width()+3));
		
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
		// Hide all unused pages so that scrolling works just right...
		//Page.pages.each(function(el, i) {
		//	if(el.getAttribute("id") != Page.current_page) $(el).hide();
		//});
	},
	
	_lock: function() {
		if(Page.lock) return false;
		console.log("lock granted");
		Page.lock = true;
		return true;
	},
	
	_unlock: function() {
		console.log("lock undone");
		Page.lock = false;
	},
	
	_stopHash: function() {
		Page.show(this.getAttribute("href").idify());
		return false;
	}
};

window.onhashchange = function(event) {
	event.preventDefault();
	console.log(window.location.hash.idify());
	Page.show(window.location.hash.idify());
	return false;
};

$.ready(function() {
	Page.init();
	
	$(".link-list a").fastbutton(function(event) {
		Page.show(this.element.getAttribute("href").idify());
		event.preventDefault();
		return false;
	});
});
