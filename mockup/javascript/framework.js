var slideAmount = 0;

function handleHash(hash) {
	if(hash.match(/^#page:/)) {
		// If yout want to do that be aware that there is concurrency...
		Page.show("#"+hash.replace(/^#page:/, ""), false);
	} else if(hash.match(/^#option:/)) {
		Option.show("#"+hash.replace(/^#option:/, ""), false);
	}
}


var Page = {
	slideAmount: 0,
	current: 0,
	previous: null,
	pages: [],
	menu: null,
	header: null,

	init: function() {
		this.pages = $("div[data-type=page]");
		this.pages.first().addClass("active");
		this.menu = $("#menu");
		this.header = $("#header");
		this.current = 0;
		this.updateMenu();
		
		$(window).resize(this.onResize.bind(this)).trigger('resize');
	},
	
	onResize: function() {
		this.width = $(document.body).width();
		this.height = $(window).height();
	},
	
	toTop: function() {
		$(window).scrollTop(0);
	},
	
	
	show: function(el, setHash) {
		Option.hide("div[data-type=option]");
		$("#pages").css("width", this.width).css("height", this.height);
		old_current = this.current;
		current = (typeof el == "number")?el:$(el).prevAll("div[data-type=page]").length;
		if(old_current != current) {
			this.current = current;
			el = $(this.pages[this.current]);
			this.previous = $(this.pages[old_current]);
	
			setHash = (typeof setHash == 'undefined')?true:setHash;
			if(setHash) window.location.hash = "#page:"+$(el).attr("id");
		
			this.toTop();
			this.pages.removeClass("reverse out in");
			el.addClass("active slide " + (old_current<this.current?"in":"in reverse"));
			this.previous.addClass("slide " + (old_current<this.current?"out":"out reverse"));
			
			this.updateMenu();
			setTimeout("Page.previous.removeClass('active')", 200); // Hide old one
		}
	},
	
	updateMenu: function() {
		menu = $(this.pages[this.current]).find(".menu");
		links = menu.find("a");
		links.css("width", (100/(links.length==0?1:links.length)) + "%");
		this.menu.html(menu.html()).find("a").each(function(i, el) {
			new MBP.fastButton(el, function() {
				handleHash(el.getAttribute("href"));
			});
		});
		
		// Header Update
		header = $(this.pages[this.current]).find(".header");
		this.header.html(header.html()).find("a").each(function(i, el) {
			new MBP.fastButton(el, function() {
				handleHash(el.getAttribute("href"));
			});
		});
	},
	
	hideAll: function(bool) {
		$("#pages, #menu, #header")[bool?"hide":"show"]();
	}
}

var Option = {
	show: function(el, setHash) {
		Page.hideAll(true);
		$(el).show();
	},
	
	hide: function(el) {
		Page.hideAll(false);
		$(el).hide();
	}
}

$(window).hashchange(function(event) {
	handleHash(window.location.hash);
});

$(function() {
	Page.init();
	$(window).hashchange();
});
