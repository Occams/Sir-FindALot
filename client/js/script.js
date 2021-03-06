/* Sir FindALot */

// JQuery-like syntax
(function ($) {
	
	var SERVER_HOST = 'http://10.0.0.12:3000';
	
	$.ready(function () {
		
		// Feature detection
		if (!supportsFeatures()) {
			window.location = 'upgrade.html';
		} else {
			Page.init();
		}
		// MBP.hideUrlBar(); // Not working?
	});
	
	// Seems like some browser do not support domready, redirect to upgrade.html
	window.onload = function () {
		if (!supportsFeatures()) {
			window.location = 'upgrade.html';
		} else if (!Page.initialized) {
			Page.init();
		}
	};
	
	var supportsFeatures = function () {
		var m = Modernizr;
		return m.flexbox & m.borderradius & m.boxshadow &
		m.cssanimations & m.cssgradients & m.csstransforms &
		m.csstransitions & m.fontface & m.opacity & m.textshadow & m.applicationcache;
	};
	
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
		"slideinfromleft" : "slide in reverse",
		"slideouttoleft" : "slide out",
		"slideinfromright" : "slide in",
		"slideouttoright" : "slide out reverse"
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
			display : 'block', // legacy support, may be removed because of Modernizr capability testing
			display : 'box',
			display : '-' + vendor + '-box'
		});
		
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
				width : element.offsetWidth,
				height : element.offsetHeight
			};
		}
		
		// All *Width and *Height properties return 0 on elements with
		// `display: none`, so display the element temporarily.
		var style = element.style;
		var originalStyles = {
			visibility : style.visibility,
			position : style.position,
			display : style.display
		};
		
		var newStyles = {
			visibility : 'hidden',
			display : 'block'
		};
		
		// Switching `fixed` to `absolute` causes issues in Safari.
		if (originalStyles.position !== 'fixed')
			newStyles.position = 'absolute';
		
		Element.setStyle(element, newStyles);
		
		var dimensions = {
			width : element.offsetWidth,
			height : element.offsetHeight
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
	
	$.fn.cxhr = function (method, url, success, error, data) {
		var xhr = new XMLHttpRequest();
		
		if ("withCredentials" in xhr) {
			xhr.open(method, url, true);
		} else if (typeof XDomainRequest != "undefined") {
			xhr = new XDomainRequest();
			xhr.open(method, url);
		} else {
			xhr = null;
		}
		
		xhr.onerror = error;
		xhr.onload = success;
		xhr.send(data);
		
		return xhr;
	}
	
	var Page = {
		initialized : false, // if Page.init() has alread been invoked
		pages : null,
		//Holds all pages initially present in #viewport
		footer : null,
		//Holds the references to all footer elements
		viewport : null,
		// Holds #viewport
		gFooter : null,
		//Holds a reference to the global footer
		gHeader : null,
		
		modal : null, // reference to modal window
		//Holds a reference to the global header
		id_page_hash : {},
		//Hash from page id to page element
		id_pagenum_hash : {},
		// Hash from page id to page num
		current_page : null,
		// Holds the current page id
		home : null,
		// Holds home page
		scrollers : {},
		// Hash from scroller container id to IScroll object
		lock : false,
		
		init : function () {
			this.initialized = true;
			this.pages = $("#viewport div[data-type=page]");
			this.footer = $("#viewport footer");
			this.viewport = $('#viewport');
			this.gHeader = $("#global-header");
			this.gFooter = $("#global-footer");
			this.modal = $('#modal');
			
			this.pages.each(function (el, i) {
				Page.id_page_hash[el.getAttribute("id")] = el;
				Page.id_pagenum_hash[el.getAttribute("id")] = i;
			});
			
			// iScroll 4 initialization
			$('.scroller').each(function (el) {
				var id = el.getAttribute("id");
				Page.scrollers[id] = new iScroll(id, {
						hScroll : false,
						onBeforeScrollStart : Page._makeIScrollFriendly // called on each scroll event
					});
			});
			
			// Page update event
			this.pages.on('update', function (e) {
				var page = $(this);
				
				if (!e.data.onlyIScroll) {
					// Update global header and footer
					Page.gHeader.html(page.find("header")[0].innerHTML);
					Page.gFooter.html(page.find("footer")[0].innerHTML);
					
					// Update: Attach event handlers to account for androids :active css bug
					Page._registerFakeActive();
					
					// No callout on navigation links
					Page.gFooter.find("a").addClass('nocallout');
					
					// Fastbutton update for toolbar links
					Page.gFooter.find("a").fastbutton(function (e) {
						Page.show(this.element.getAttribute("href").idify());
						e.preventDefault();
						return false;
					});
					
				}
				
				// Update IScroll4 object
				var scrollID = page.find('.scroller')[0].getAttribute('id');
				
				// IScroll4 doc recommends using setTimeout
				setTimeout(function () {
					console.log('Refresh of scroll area: ' + scrollID);
					Page.scrollers[scrollID].refresh();
				}, 0);
				
				// Scroll to top
				if (e.data.toTop)
					Page.scrollers[scrollID].scrollTo(0, 0, 0);
			});
			
			// Show the first page or an explicitly declared home page initially
			var startpage = this.pages.has('div[home=yes]')[0];
			this.home = startpage ? startpage : this.pages[0];
			this.show(home.getAttribute("id"));
			
			// Initialize accordions
			this._initAccordions();
			
			// Initialize modal window
			this._initModal();
			
			// Switch handlers
			this._registerSwitchHandler();
			
			// TODO: Search handler
			$('#geolocation_search_form').submit(this._search);
			
			// Start Geolocation
			if (navigator.geolocation) {
				navigator.geolocation.getCurrentPosition(this._geoPosition, this._geoError);
			} else {
				this._geoError();
			}
			
			// Update IScroll on orientationchange
			window.addEventListener(RESIZE_EV, function (e) {
				setTimeout(function () {
					Page.pages.fire('update', {
						onlyIScroll : true
					})
				}, 500); // requires a certain delay to work
			});
			
		},
		
		show : function (id) {
			if (id == "")
				id = Page.home; // If hashchange to no hash show first page
			if (!this._isPage(id))
				return;
			if (!this._lock()) // Try to place a lock on the page
				return;
			
			if (this.current_page == null) { // If you set the page for the first time...
				this.current_page = id;
				this._getPage(id).show();
				this._getPage(id).fire('update', {
					toTop : true
				});
				this._unlock();
				
			} else if (id != this.current_page) {
				to = this._getPage(id).show(); // Display the new page
				from = this._getPage(this.current_page);
				
				to.fire('update', {
					toTop : true
				}); // fire update event
				
				// Determine slide directions
				slideLeft = this._getPageNum(id) > this._getPageNum(this.current_page);
				to.css3Slide(slideLeft ? "slideinfromright" : "slideinfromleft");
				from.css3Slide(slideLeft ? "slideouttoleft" : "slideouttoright");
				
				this.current_page = id; // Update the current page
				
				setTimeout(function (e) {
					window.location.hash = Page.current_page.hashify(); // Needed for browser history
					from.hide(); // Hide old page
					Page._unlock();
				}, 775); // Workaround because event on transtionend does not work properly
			} else {
				this._unlock();
			}
		},
		
		_search : function (e) {
			var loading = $('#loading');
			
			// Show orange loading animation
			loading.removeClass('green').addClass('orange');
			loading.show();
			
			// Disable input
			$('#geolocation_search').attr('disabled', 'disabled');
			
			// AJAX
			
			
			// Fake response delay
			setTimeout(function (e) {
				$('#loading').hide();
				$('#geolocation_search').rAttr('disabled'); // Reenable input field
				Page.show('search');
			}, 1500);
			
			// Prevent default behavior
			e.preventDefault();
			return false;
		},
		
		_generate_link_list : function (links, id) {
			var html = '';
			
			for (var title in links) {
				html += '<li><a href="' + links[title] + '" fake-active="yes">';
				html += '<div class="occupancy"><div class="level"></div><div class="mask"></div></div>';
				html += '<span class="link-list-title">' + title + '</span></a></li>';
			}
			
			return '<ul class="link-list" id="' + id + '">' + html + '</ul>';
		},
		
		_geoError : function (position) {
			Page._showModal('Geolocation', 'Sorry, I encountered an error while trying to geolocate you. You may still issue a custom search.');
			var input = $('#geolocation_search'),
			form = $('#geolocation_search_form');
			
			// Hide loading animation
			$('#loading').setStyle('display', 'none');
			
			// Enable input field and change placeholder text
			input.attr('placeholder', 'Touch to enter custom query...');
			input.rAttr('disabled');
			form.removeClass('green').addClass('orange');
		},
		
		_geoPosition : function (position) {
			
			var input = $('#geolocation_search'),
			form = $('#geolocation_search_form');
			
			// TODO: Send Geo request
			var data = {
				'cords' : position.cords,
				'timestamp' : position.timestamp
			};
			var xhr = $().cxhr('POST', SERVER_HOST + '/searches.json', null, null, null);
			console.log(xhr);
			
			// Fake response delay
			setTimeout(function (e) {
				
				// Hide loading animation
				$('#loading').setStyle('display', 'none');
				
				// Enable input field and change placeholder text
				input.attr('placeholder', 'Touch to enter custom query...');
				input.rAttr('disabled');
				form.removeClass('green').addClass('orange');
				
				// Fake response result
				var links = {
					'Uni Passau Tiefgarage' : '#lot',
					'Uni Regen Tiefgarage' : '#lot',
					'Zentralgarage' : '#lot',
					'John\'s Garage' : '#lot'
				}
				form.after(Page._generate_link_list(links, 'geo_results'));
				
				// Display occupancy animation
				var occupancy = [0.3, 0.7, 1, 0.6, 0.1];
				
				setTimeout(function (e) {
					$('#geo_results .mask').each(function (el, i) {
						$(el).setStyle('width', (100 - occupancy[i] * 100) + '%');
					})
				}, 100);
				
				// Update link-list event handlers
				$('.link-list a').fastbutton(function (e) {
					Page._displayLoadingAnimation();
					var id = this.element.getAttribute('href').idify();
					
					// Fake response delay
					setTimeout(function (e) {
						Page._hideLoadingAnimation();
						Page.show(id);
					}, 2000);
				});
				
				// Fade in of geolocation results. No animation without timeout? */
				setTimeout(function (e) {
					$('#geo_results a').setStyle('opacity', '1');
					$('#geo_results').setStyle('opacity', '1');
				}, 25);
				
				$("#home").fire('update');
				
			}, 2000);
		},
		
		_registerFakeActive : function () {
			
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
		
		_getPage : function (id) {
			return $(this.id_page_hash[id]);
		},
		
		_getPageNum : function (id) {
			return this.id_pagenum_hash[id];
		},
		
		_isPage : function (id) {
			return this.id_page_hash[id] != null;
		},
		
		_lock : function () {
			if (Page.lock)
				return false;
			Page.lock = true;
			return true;
		},
		
		_unlock : function () {
			Page.lock = false;
		},
		
		_initModal : function () {
			
			// Modal test link
			//TODO: remove
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
		
		_showModal : function (heading, text) {
			var modal = $('#modal');
			
			Page._fadeOverlay();
			
			$('#modal h1').html(':: ' + heading);
			$('#modal p').html(text);
			
			modal.show();
		},
		
		_closeModal : function () {
			$('#modal').hide();
			Page._removeFadeOverlay();
		},
		
		_fadeOverlay : function () {
			var fade = $('#fade');
			fade.setStyle('z-index', '1000');
			fade.setStyle('opacity', '0.8');
		},
		
		_removeFadeOverlay : function () {
			var fade = $('#fade');
			fade.setStyle('z-index', '0');
			fade.setStyle('opacity', '0');
		},
		
		_initAccordions : function () {
			$('.faq h1').fastbutton(function (e) {
				var el = $(this.element);
				var id = el.attr('id');
				var target = $('.faq p[rel=' + id + ']');
				var toggle = target.hasClass('open');
				
				// Close already open elements
				$('.faq .open').removeClass('open');
				
				// Open the new element
				if (!toggle) {
					target.addClass('open');
					el.addClass('open');
				}
				
				// Update IScroll, height changed during animation
				setTimeout(function () {
					$(Page._getPage(Page.current_page)).fire('update', {
						toTop : false,
						onlyIScroll : true
					})
				}, 500);
			});
		},
		
		_registerSwitchHandler : function () {
			$('.switch label').fastbutton(function (e) {
				var el = $(this.element),
				slide = el.attr('rel');
				$('#' + slide).toggleClass('selected');
			});
		},
		
		_displayLoadingAnimation : function (e) {
			Page._fadeOverlay();
			$('#loading_overlay').show();
		},
		
		_hideLoadingAnimation : function (e) {
			$('#loading_overlay').hide();
			Page._removeFadeOverlay();
		},
		
		// Prevent IScroll on certain elements etc., restores functionality
		_makeIScrollFriendly : function (e) {
			var target = e.target;
			
			// bubble up
			while (target.nodeType != 1)
				target = target.parentNode;
			
			if (target.tagName != 'SELECT' && target.tagName != 'INPUT' && target.tagName != 'TEXTAREA') {
				e.preventDefault();
				return false;
			}
		}
		
	};
	
	window.onhashchange = function (event) {
		event.preventDefault();
		Page.show(window.location.hash.idify());
		return false;
	};
	
	if (typeof exports !== 'undefined')
		exports.Page = Page;
	else
		window.Page = Page;
	
})(x$);
