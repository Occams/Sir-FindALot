if typeof (Number::toRad) is "undefined"
  Number::toRad = ->
    this * Math.PI / 180
    
Position =
  longitude: null
  latitude: null
  RADIUS: 6371
  distance: (lon, lat) ->
    if @longitude? and @latitude?
      lat1 = @latitude.toRad()
      lon1 = @longitude.toRad()
      lat2 = lat.toRad()
      lon2 = lon.toRad()
      dLat = lat2 - lat1
      dLon = lon2 - lon1
      a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) * Math.sin(dLon / 2)
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
      @RADIUS * c
    else
      null
      
if typeof exports isnt "undefined"
  exports.Position = Position
else
  window.Position = Position