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

String.prototype.idify = function() { return (this[0]=="#")?this.slice(1):this; }
String.prototype.hashify = function() { return (this[0]=="#")?this:"#"+this; };


var Page = {
	pages: null, //Holds all pages initialliy present in #pages
	footer: null, //Holds the references to all footer elements
	gFooter: null, //Holds a reference to the global footer
	gHeader: null, //Holds a reference to the global header
	id_page_hash: {}, //Hash from page.id to page element
	id_pagenum_hash: {}, // Hash from page id to page num
	window_width: 0, // Holds the current width of the window
	current_page: null, // Holds the current page id
	lock:false, 
	

	init: function() {
		this.pages = $("#pages div[data-type=page]");
		this.footer = $("#pages footer");
		this.pages.each(function(el, i) {
			Page.id_page_hash[el.getAttribute("id")] = el;
			Page.id_pagenum_hash[el.getAttribute("id")] = i;
		});
		this.gHeader = $("#global-header");
		this.gFooter = $("#global-footer");
		
		hash = window.location.hash;
		this.show(this._isPage(hash)?hash:this.pages[0].getAttribute("id")); // Show the first page initialliy
		
		this.window_width = window.innerWidth;
		this.layout();
	},
	
	layout: function() {
		this.footer.setStyle("width", this.window_width);
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
			
			setTimeout(this._finishedAnimation, 1100); // Workaround because event on transtionend does not work properly
		} else {
			this._unlock();
		}
	},
	
	_updatePageInfos: function(id) {
		page = this._getPage(id);
		this.gHeader.html(page.find("header")[0].innerHTML);
		this.gFooter.html(page.find("footer")[0].innerHTML);
		
		//Toolbar width
		els = this.gFooter.find(".toolbar li");
		this.gFooter.find(".toolbar").setStyle("width", els.length*($(els[0]).width()+3));
		
		// Fastbutton update for toolbar links
		this.gFooter.find("a").fastbutton(function(event) {
			Page.show(this.element.getAttribute("href").idify());
			event.preventDefault();
			return false;
		});
		
		
		$("a[href*='#']").click(Page._stopHash);
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
		Page.pages.each(function(el, i) {
			if(el.getAttribute("id") != Page.current_page) $(el).hide();
		});
		Page._getPage(Page.current_page).fire("pageshow");
		window.location.hash = Page.current_page.hashify();
		Page._unlock();
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
