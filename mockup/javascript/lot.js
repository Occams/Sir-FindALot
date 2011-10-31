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
    
    $("#three").bind("pageshow", function() {
      Lot.resized();
    });
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
      
      cl = "";
      if(lot[2]) {
        cl = "free";
      } else { cl = "used"; }
      $(this.lot[lot[1]][lot[0]]).addClass(cl);
    }
  },

  resized: function() {
    $('#lot td').css('height', $("#lot").width()/Lot.data.width);
  },
  
  testLot: function(w, h) {
    arr = [];
    for(i = 0; i < w; i+=2) {
      for(y = 0; y < h; y++) {
        if(y % 5 != 0) {
          arr.push([i, y, Math.random() < 0.5]);
        }
      }
    }
    return arr;
  }
};

$(function() {
  Lot.init("#lotdisplay", {width: 20, height: 30,lots: Lot.testLot(20,30)});
});
