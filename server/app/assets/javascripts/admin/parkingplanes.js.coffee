class LotBrush
  constructor:(@type, @category) ->
  
  toCssClassName:() ->
    "brush_#{@type}_#{@category}"

  equals:(brush) ->
    brush.type is @type and brush.category is @category
    
  sameType:(brush) ->
    brush.type is @type
    
  sameCategory:(brush) ->
    brush.category is @category
    
Brushes =
  _preload: ->
    for select in $("#parkinglots-brushes select")
      s = $(select)
      os = s.find("option")
      Brushes[s.attr('id')] = {}
      for o in os
        Brushes[s.attr('id')][$(o).val()] = new LotBrush s.attr('id'), $(o).val()
        @_createBrushLink Brushes[s.attr('id')][$(o).val()], $(o).text()
      s.remove()
    @_createBrushLink null, 'eraser'
      
  _createBrushLink: (brush, text) ->
    $("<a href=\"javascript:return false;\">#{text}</a>")
      .bind 'click', (event) ->
        $("#parkinglots-brushes a").removeClass("active-brush")
        $(this).addClass("active-brush")
        $("#parkinglots").data('plane').currentBrush = brush
        false
      .appendTo("#parkinglots-brushes")
    
      
Cell = 
  new: (brush, x, y, meshsize=20, id=null) ->
    el: $("<div class=\"lot\" style=\"left: #{x*meshsize}px;top: #{y*meshsize}px;\"></div>")
    brush: brush
    x: x
    y: y
    id: id
    
  toResource: (cell) ->
    o =
      x: cell.x
      y: cell.y
      category: cell.brush.category
    
     o.id = cell.id if cell.id?
     o
    
    
class Grid
  constructor: ->
    @size = x:0,y:0
    @grid = {}
    
  add: (x,y, data) ->
    @grid[y] = {} if not @grid[y]?
    @grid[y][x] = data
    if data?
      @size.y = Math.max(@size.y, y)
      @size.x = Math.max(@size.x, x)
    else
      @recalcSize()    
    
  used: (x,y) ->
    @grid[y]? and @grid[y][x]?
    
  remove: (x,y) ->
    el = @get x, y
    if el?
      @add x,y, null
    el
    
  get: (x,y) ->
    if @used(x,y) then @grid[y][x] else null
    
  recalcSize: ->
    @size = x:0,y:0
    for y, row of @grid
      for x, cell of @grid
        @size.y = Math.max(@size.y, y)
        @size.x = Math.max(@size.x, x)
        
    @size
    
  getSize: ->
    @size
        

class Plane
  currentBrush: null
  ajaxqueries:0
  ajaxreadycb:null

  constructor: (element, @lots, @concretes, @meshsize=20) ->
    Brushes._preload()
    @grid = new Grid
    @db = new Grid
    @currentBrush = null
    @oldx = @oldy = -1
    
    
    @plane = $(element).bind 'click', (event) =>
      position = x:event.pageX-@planepos.left, y:event.pageY-@planepos.top
      cell = x:Math.floor(position.x/@meshsize), y:Math.floor(position.y/@meshsize)
      @handleClicked cell
      
    @plane.bind 'mousedown', (event) => 
      @plane.bind 'mousemove', (event) =>
        x = Math.floor((event.pageX-@planepos.left)/@meshsize)
        y = Math.floor((event.pageY-@planepos.top)/@meshsize)
        if x isnt @oldx or y isnt @oldy
          @oldx = x
          @oldy = y
          @handleClicked {x:x, y:y}
      event.preventDefault()
      false
      
    @plane.bind 'mouseup', (event) => 
      @plane.unbind 'mousemove'
      event.preventDefault()
      false
      
    @plane.data('plane', this);
    @planepos = @plane.position()
    
    for rname, resource of {parkinglot: @lots, concrete: @concretes}
      for single in resource
        cell = Cell.new Brushes[rname][single.category], single.x, single.y, @meshsize
        cell.el.appendTo(@plane).addClass(cell.brush.toCssClassName())
        single.brush = cell.brush
        @db.add single.x, single.y, single
        @grid.add single.x, single.y, cell
    
  handleClicked: (cell) ->
    if !@currentBrush?
      c = @grid.remove(cell.x, cell.y)
      c.el.remove() if c?
    else
      if @grid.used cell.x, cell.y
        @handleUpdate @grid.get cell.x, cell.y
      else
        cell = Cell.new @currentBrush, cell.x, cell.y, @meshsize
        cell.el.appendTo(@plane).addClass(@currentBrush.toCssClassName())
        @grid.add cell.x, cell.y, cell

  handleUpdate: (oldcell) ->
    oldcell.el.removeClass(oldcell.brush.toCssClassName())
    oldcell.brush = @currentBrush
    oldcell.el.addClass(@currentBrush.toCssClassName())
    
  serialize: () ->
    data = {}
    for t in ['parkinglot', 'concrete']
      data[t] = {}
      for m in ['create', 'update', 'delete']
        data[t][m] = []
      
    
    db_size = @db.getSize()
    grid_size = @grid.getSize()
    max_size = x:Math.max(db_size.x, grid_size.x), y:Math.max(db_size.y, grid_size.y)
    
    for y in [0..max_size.y]
      for x in [0..max_size.x]
        dbcell = @db.get(x,y)
        cell = @grid.get(x,y)
        
        if not dbcell? and cell?
          data[cell.brush.type].create.push(Cell.toResource(cell))
          
        if dbcell? and not cell?
          data[dbcell.brush.type].delete.push(Cell.toResource(dbcell))
        
        if dbcell? and cell?
          if dbcell.brush.sameType cell.brush
            if not dbcell.brush.sameCategory cell.brush
              dbcell.brush.category = cell.brush.category
              data[dbcell.brush.type].update.push(Cell.toResource(dbcell))
          else
            data[dbcell.brush.type].delete.push(Cell.toResource(dbcell))
            data[cell.brush.type].create.push(Cell.toResource(cell))
    data
    
  save: (callback) ->
    $("#content").activity({color:"#FFFFFF", length:40, width:8}).overlay(true)
    # The URLs are hardcoded!!!
    baseurl = window.location.pathname.substring(0, window.location.pathname.lastIndexOf("/"))
    data = @serialize()
    ajaxrequested = false
    _this = this
    
    for datatype in ['parkinglot', 'concrete']
      # First of all delete
      ids = (lot.id for lot in data[datatype].delete).join(",")
      if ids isnt ""
        @ajaxqueries++
        ajaxrequested = true
        $.post("#{baseurl}/#{datatype}s/#{ids}", { '_method' : 'delete' }, _this._ajaxFinished.bind(_this))
        
      # Now update
      if data[datatype]['update'].length > 0
        @ajaxqueries++
        ajaxrequested = true
        first = data[datatype]['update'][0]
        tmp = '_method=put&' + data[datatype]['update'].toJson(datatype)
        $.post("#{baseurl}/#{datatype}s/#{first.id}", tmp, _this._ajaxFinished.bind(_this))
        
      # Now create
      if data[datatype]['create'].length > 0
        @ajaxqueries++
        ajaxrequested = true
        tmp = data[datatype]['create'].toJson(datatype)
        $.post("#{baseurl}/#{datatype}s", tmp, _this._ajaxFinished.bind(_this))
        
    # Set now the callback. Has to be set after all queries were started
    if not ajaxrequested
      callback()
    else
      @ajaxreadycb = callback
    true
    
  _ajaxFinished: () ->
    console.log this
    console.log "down #{@ajaxqueries}"
    @ajaxqueries--
    if @ajaxqueries is 0 and @ajaxreadycb?
      console.log "ok"
      @ajaxreadycb()
      
  

Array::toJson = (name) ->
  str = []
  for el in this
    for k,v of el
      str.push("#{name}[][#{k}]=#{v}")
  str.join("&")
    
window.Plane = Plane
window.Brushes = Brushes
