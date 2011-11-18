xui.ready(function() {
	// Number of pages
	var pageNum = 4;
	x$('#slide_container').setStyle('width', pageNum+'00%');
	
	// Set .page width based on device
	x$('.page').setStyle('width', window.innerWidth+'px');
	
	// Set active page
	x$("#slide_container").setStyle('left','-'+window.innerWidth+'px');
	
	// Needs testing
	x$('window').on('orientationchange',function(e) {
		x$('.page').setStyle('width', window.innerWidth+'px');
	});
	
	// Register page animation events on buttons (TODO: change to touchstart)
	x$("#btn_home").click(function(e) {
		x$("#slide_container").setStyle('left','-'+window.innerWidth+'px');
	})
	
	//MBP.fastButton(x$("#btn_home")[0], function() {
	//		x$("#slide_container").setStyle('left','-'+window.innerWidth+'px');
	//});
	
	x$("#btn_help").click(function(e) {
		x$("#slide_container").setStyle('left','0px');
	})
	
	x$("#btn_options").click(function(e) {
		x$("#slide_container").setStyle('left','-'+2*window.innerWidth+'px');
	})
	
});