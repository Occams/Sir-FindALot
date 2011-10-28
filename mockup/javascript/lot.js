var Lot = {
	parent: null,
	data:null,
	lot: [],

	/*
	 * Create a parking view into dest with the given data. Data is a hash with properties:
	 * width,height, lots (array of points)
	 */
	init: function(dest, data) {
		this.parent = dest;
		this.data = data;
		this.buildTable();
		this.colorLots();
		Lot.resized();
		$(window).resize(Lot.resized);
	},

	buildTable: function() {
		$(this.parent).append("<table id=\"lot\"></table>");
		table = $(this.parent).find("table");
		for(y = 0; y < this.data.height; y++) {
			row_collection = [];
			row = document.createElement('tr');
			for(x = 0; x < this.data.width; x++) {
				cell = document.createElement('td');
				row.appendChild(cell);
				row_collection.push(cell);
			}
			table.append(row);
			this.lot.push(row_collection);
		}

		$(this.parent).append(table);
	},

	colorLots: function() {
		for(i = 0; i < this.data.lots.length; i++) {
			lot = this.data.lots[i];
			$(this.lot[lot[1]][lot[0]]).css('background-color', 'black');
		}
	},

	resized: function() {
		$('#lot td').css('height', $("#lot").width()/Lot.data.width);
	}
};

$(function() {
	Lot.init("#lotdisplay", {width: 20, height: 30,lots: [[1,1],[1,2],[1,3],[1,4],[1,5],[1,6],[3,1],[3,2],[3,3],[3,4],[3,5],[3,6]]});
});
