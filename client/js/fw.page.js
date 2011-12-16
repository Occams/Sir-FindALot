x$.ready(function () {
		// Feature detection
		if (!supportsFeatures()) {
			window.location='upgrade.html';
		} else {		
			Page.init();
		}
		// MBP.hideUrlBar(); // Not working?
	});
	
// Seems like some browser do not support domready
window.onload = function() {
		if (!supportsFeatures()) {
			window.location='upgrade.html';
		}
};

var supportsFeatures = function() {
	return Modernizr.flexbox
};

(function () {

	$ = x$; // JQuery-like syntax
	
	// Detect capabilities
	var vendor = (/webkit/i).test(navigator.appVersion) ? 'webkit' : (/firefox/i).test(navigator.userAgent) ? 'Moz' : 'opera' in window ? 'O' : '',

		// Browser capabilities
		isAndroid = (/android/gi).test(navigator.appVersion),
		isIDevice = (/iphone|ipad/gi).test(navigator.appVersion),
		isPlaybook = (/playbook/gi).test(navigator.appVersion),
		isTouchPad = (/hp-tablet/gi).test(navigator.appVersion),
		hasTouch = 'ontouchstart' in window && !isTouchPad;

	// Events
	RESIZE_EV = 'onorientationchange' in window ? 'orientationchange' : 'resize',
	START_EV = hasTouch ? 'touchstart' : 'mousedown',
	MOVE_EV = hasTouch ? 'touchmove' : 'mousemove',
	END_EV = hasTouch ? 'touchend' : 'mouseup',
	CANCEL_EV = hasTouch ? 'touchcancel' : 'mouseup';


	// type is one of [slideinfromleft, slideouttoleft, slideinfromright, slideouttoright]
	$.fn.css3Slide = function (slideType) {
		this.each(function () {
			$(this).removeClass($.fn.css3Slide.types).addClass($.fn.css3Slide.typesToClass[slideType]);
		});
	}

	$.fn.css3Slide.types = "slide in out reverse";
	$.fn.css3Slide.typesToClass = {
		"slideinfromleft": "slide in reverse",
		"slideouttoleft": "slide out",
		"slideinfromright": "slide in",
		"slideouttoright": "slide out reverse"
	};

	$.fn.fastbutton = function (handler) {
		this.each(function () {
			new MBP.fastButton(this, handler);
		});
		
		return this;
	}

	// Convenience remove Attribute helper
	$.fn.rAttr = function (attr) {
		this.each(function (el) {
			el.removeAttribute(attr);
		});
		
		return this;
	}

	$.fn.show = function () {

		console.log('Show: ' + this.attr('id'));

		// Show element
		this.css({
			display: 'block',
			display: 'box',
			display: '-' + vendor + '-box'
		});

		// Update IScroll4 object
		var scrollID = $(this).find('.scroller')[0].getAttribute('id');

		// IScroll4 doc recommends using setTimeout
		setTimeout(function () {
			console.log('Refresh of scroll area: '+scrollID);
			Page.scrollers[scrollID].refresh();
		}, 0);

		// Scroll to top
		Page.scrollers[scrollID].scrollTo(0, 0, 0);
		return this;
	}

	$.fn.hide = function () {
		console.log('Hide: ' + this.attr('id'));

		this.setStyle("display", "none");
		return this;
	}

	$.fn.dimensions = function () {
		var element = this[0],
			display = this.getStyle('display');

		if (display && display !== 'none') {
			return {
				width: element.offsetWidth,
				height: element.offsetHeight
			};
		}

		// All *Width and *Height properties give 0 on elements with
		// `display: none`, so show the element temporarily.
		var style = element.style;
		var originalStyles = {
			visibility: style.visibility,
			position: style.position,
			display: style.display
		};

		var newStyles = {
			visibility: 'hidden',
			display: 'block'
		};

		// Switching `fixed` to `absolute` causes issues in Safari.
		if (originalStyles.position !== 'fixed') newStyles.position = 'absolute';

		Element.setStyle(element, newStyles);

		var dimensions = {
			width: element.offsetWidth,
			height: element.offsetHeight
		};

		Element.setStyle(element, originalStyles);

		return dimensions;
	}

	$.fn.width = function () {
		return this.dimensions().width;
	}

	$.fn.height = function () {
		return this.dimensions().height;
	}

	String.prototype.idify = function () {
		return (this.indexOf("#") > -1) ? this.substring(this.indexOf("#") + 1, this.length) : this;
	};
	String.prototype.hashify = function () {
		return (this[0] == "#") ? this : "#" + this;
	};


	var Page = {
		pages: null,
		//Holds all pages initially present in #viewport
		footer: null,
		//Holds the references to all footer elements
		viewport: null,
		// Holds #viewport
		gFooter: null,
		//Holds a reference to the global footer
		gHeader: null,
		//Holds a reference to the global header
		id_page_hash: {},
		//Hash from page id to page element
		id_pagenum_hash: {},
		// Hash from page id to page num
		current_page: null,
		// Holds the current page id
		home: null,
		// Holds home page
		scrollers: {},
		// Hash from scroller container id to IScroll object
		lock: false,

		init: function () {
			this.pages = $("#viewport div[data-type=page]");
			this.footer = $("#viewport footer");
			this.viewport = $('#viewport');
			this.gHeader = $("#global-header");
			this.gFooter = $("#global-footer");

			this.pages.each(function (el, i) {
				Page.id_page_hash[el.getAttribute("id")] = el;
				Page.id_pagenum_hash[el.getAttribute("id")] = i;
			});

			// iScroll 4 initialization
			$('.scroller').each(function (el) {
				var id = el.getAttribute("id");
				Page.scrollers[id] = new iScroll(id, {
					hScroll: false,
					onBeforeScrollStart: Page._makeIScrollFriendly
				});
			});
			

			// Show the first page or an explicitly declared home page initially
			hash = window.location.hash.idify();
			var startpage = this.pages.has('div[home=yes]')[0];
			this.home = startpage ? startpage : this.pages[0];
			this.show(this._isPage(hash) ? hash : startpage.getAttribute("id"));

			// Attach event handlers to account for androids :active css bug
			this._registerFakeActive();
			
			// Initialize modal window
			this._initModal();

			// TODO: Input handler
			$('#geolocation_search_form').submit(function (e) {
				var loading = $('#loading');
				
				// Show orange loading animation
				loading.removeClass('green').addClass('orange');
				loading.setStyle('display','-'+vendor+'-box');
				
				// Disable input
				$('#geolocation_search').attr('disabled','disabled');
				
				// Fake response delay
				setTimeout(function(e) {
					$('#loading').hide();
					$('#geolocation_search').rAttr('disabled');
					Page.show('search'); },1500);
				
				return false;
			});

			// Faq Accordions
			$('.faq h1').fastbutton(function (e) {
				Page._accordionHandler(this.element);
			});

			// Switch handlers
			this._registerSwitchHandler();
			
			// Start Geolocation
			if (navigator.geolocation) {
				navigator.geolocation.getCurrentPosition(this._geoPosition, this._geoError);
			} else {
				Page._showModal('No Geolocation', 'Sorry, your browser does not support geolocation.');
			}
			
			window.addEventListener(RESIZE_EV, function(e) {
				// Update IScroll (Still does not work as expected on orientation change)
				setTimeout(Page._updateIScroll, 50);
			});

		},
		
		_registerSwitchHandler : function() {
			$('.switch label').fastbutton(function (e) {
				var el = $(this.element), slide = $(this.element).attr('rel');
				$('#'+slide).toggleClass('selected');
			});
		},
		
		_initModal: function () {

			// Modal test link
			$('#show_modal').fastbutton(function (e) {
				Page._showModal('Offline', 'Sir FindALot is very sad and lonely. You have been disconnected from the interwebz.');
			});

			$('#modal_close').fastbutton(function (e) {
				Page._closeModal();

				// Prevent hash/page change
				e.preventDefault();
				return false;
			});
		},

		_showModal: function (heading, text) {
			var modal = $('#modal');

			Page._fadeOverlay();
			
			$('#modal h1').html(':: ' + heading);
			$('#modal p').html(text);

			modal.css({
				display: '-' + vendor + '-box'
			});
		},
		
		_fadeOverlay: function() {
			var fade = $('#fade');
			fade.setStyle('z-index', '1000');
			fade.setStyle('opacity', '0.8');
		},
		
		_removeFadeOverlay: function() {
			var fade = $('#fade');
			fade.setStyle('z-index', '0');
			fade.setStyle('opacity', '0');
		},

		_closeModal: function () {
			$('#modal').hide();
			Page._removeFadeOverlay();
		},

		_accordionHandler: function (el) {
			var id = $(el).attr('id');
			var target = $('.faq p[rel=' + id + ']');
			var toggle = target.hasClass('open');

			// Close already open elements
			$('.faq .open').removeClass('open');

			// Open the new element
			if (!toggle) { target.addClass('open'); $(el).addClass('open'); }

			// Update IScroll, height changed during animation
			setTimeout(Page._updateIScroll, 500);
		},

		_updateIScroll: function () {
			// Update IScroll4 object
			console.log(Page.current_page);
			var scrollID = $(Page.current_page.hashify()).find('.scroller')[0].getAttribute('id');
			// IScroll4 doc recommends using setTimeout
			setTimeout(function () {
				console.log('Refresh of scroll area: '+scrollID);
				Page.scrollers[scrollID].refresh();
			}, 0);
		},

		
		_generate_link_list: function (links,id){
			var html='';
			
			for (var title in links) {
				html+='<li><a href="'+links[title]+'" fake-active="yes">';
				html+='<div class="occupancy"><div class="level"></div><div class="mask"></div></div>';
				html+='<span class="link-list-title">'+title+'</span></a></li>';
			}
			
			return '<ul class="link-list" id="'+id+'">'+html+'</ul>';
		},
		
		_geoPosition: function (position) {

			// Fake response delay
			setTimeout(function (e) {
				var geo = $('#geolocation_search'), form = $('#geolocation_search_form');

				// Hide loading animation
				$('#loading').setStyle('display', 'none');

				// Enable input field and change placeholder text
				geo.attr('placeholder', 'Touch to enter custom query...');
				geo.rAttr('disabled');
				form.removeClass('green').addClass('orange');
				
				// Fake response result
				var links = {'Uni Passau Tiefgarage' : '#lot' , 'Uni Regen Tiefgarage' : '#lot', 'Zentralgarage' : '#lot', 'John\'s Garage' : '#lot'}
				form.after(Page._generate_link_list(links, 'geo_results'));
				
				// Display occupancy animation
				var occupancy = [0.3,0.7,1,0.6,0.1];
				
				setTimeout(function (e) {
				$('#geo_results .mask').each(function (el,i) {
					$(el).setStyle('width',(100- occupancy[i]*100)+'%');
				})},100);
				
				// Update link-list event handlers
				$('.link-list a').fastbutton(function(e) {
					Page._displayLoadingAnimation();
					var id = this.element.getAttribute('href').idify();
					
					// Fake response delay
					setTimeout(function(e) {
						Page._hideLoadingAnimation();
						Page.show(id);
					},2000);
				});
				
				// Fade in of geolocation results. No animation without timeout? */
				setTimeout(function (e) {
					$('#geo_results a').setStyle('opacity', '1');
					$('#geo_results').setStyle('opacity', '1');
				}, 25);

				// DOM change, update IScroll
				Page._updateIScroll();

			}, 2000);
		},
		
		_displayLoadingAnimation: function(e) {
			// Display loading animation
					Page._fadeOverlay();
					$('#loading_overlay').css({
							display: 'box',
							display: '-' + vendor + '-box'
					});
		},
		
		_hideLoadingAnimation: function(e) {
			$('#loading_overlay').hide();
			Page._removeFadeOverlay();
		},

		_geoError: function (position) {
			Page._showModal('Geolocation', 'Sorry, I encountered an error while trying to geolocate you. You may still issue a custom search.');
			var geo = $('#geolocation_search'), form = $('#geolocation_search_form');

				// Hide loading animation
				$('#loading').setStyle('display', 'none');

				// Enable input field and change placeholder text
				geo.attr('placeholder', 'Touch to enter custom query...');
				geo.rAttr('disabled');
				form.removeClass('green').addClass('orange');
		},

		_makeIScrollFriendly: function (e) {
			// Prevent IScroll on certain elements etc.
			var target = e.target;

			// bubble up
			while (target.nodeType != 1) target = target.parentNode;

			if (target.tagName != 'SELECT' && target.tagName != 'INPUT' && target.tagName != 'TEXTAREA') {
				e.preventDefault();
				return false;
			}
		},

		show: function (id) {
			if (id == "") id = Page.home; // If hashchange to no hash show first page
			if (!this._isPage(id)) return;
			if (!this._lock()) return;

			if (this.current_page == null) { // If you set the page for the first time...
				this.current_page = id;
				this._updatePageInfos(id);
				this._getPage(id).show();
				this._unlock();
			} else if (id != this.current_page) {
				to = this._getPage(id).show(); // Show the new page so that it can be animated
				from = this._getPage(this.current_page); // Show the current page so that it can be animated
				
				// Determine slide directions
				slideLeft = this._getPageNum(id) > this._getPageNum(this.current_page);
				to.css3Slide(slideLeft ? "slideinfromright" : "slideinfromleft");
				from.css3Slide(slideLeft ? "slideouttoleft" : "slideouttoright");

				this.current_page = id; // Update the current page
				this._updatePageInfos(id); // Update footer and header
				setTimeout(function (e) {
					Page._getPage(Page.current_page).fire("pageshow");
					window.location.hash = Page.current_page.hashify(); // Needed for browser history
					Page._unlock();

					// Hide old page
					from.hide();
				}, 775); // Workaround because event on transtionend does not work properly
			} else {
				this._unlock();
			}
		},

		_updatePageInfos: function (id) {
			page = this._getPage(id);
			this.gHeader.html(page.find("header")[0].innerHTML);
			this.gFooter.html(page.find("footer")[0].innerHTML);

			// Update: Attach event handlers to account for androids :active css bug
			this._registerFakeActive();

			// No callout on navigation links
			this.gFooter.find("a").addClass('nocallout');
			
			// Fastbutton update for toolbar links
			this.gFooter.find("a").fastbutton(function (event) {
				Page.show(this.element.getAttribute("href").idify());
				event.preventDefault();
				return false;
			});
		},

		_registerFakeActive: function () {

			if (isAndroid) {
				$("a[fake-active=yes], .faq h1[fake-active=yes], div[fake-active=yes]").on("touchstart", function (e) {
					$(this).addClass("fake-active");
				}).on(END_EV, function () {
					$(this).removeClass("fake-active");
				}).on(CANCEL_EV, function () { // sometimes Android fires a touchcancel event rather than a touchend. Handle this too.
					$(this).removeClass("fake-active");
				});
			}
		},

		_getPage: function (id) {
			return $(this.id_page_hash[id]);
		},

		_getPageNum: function (id) {
			return this.id_pagenum_hash[id];
		},

		_isPage: function (id) {
			return this.id_page_hash[id] != null;
		},

		_finishedAnimation: function (event) {

		},

		_lock: function () {
			if (Page.lock) return false;
			Page.lock = true;
			return true;
		},

		_unlock: function () {
			Page.lock = false;
		},

	};

	window.onhashchange = function (event) {
		event.preventDefault();
		Page.show(window.location.hash.idify());
		return false;
	};
	
	if (typeof exports !== 'undefined') exports.Page = Page;
	else window.Page = Page;

})();