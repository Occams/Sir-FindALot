class LocalStorage
  get: (key, def = null) ->
    d = @_get(key)
    if d == null
      return def
    else
      return JSON.parse(d)
    end
  
  put: (key, value) ->
    @_put(key, JSON.stringify(value))
    
  _get: (key) ->
    localStorage.getItem key
  
  _put: (key, value) ->
    localStorage.setItem key, value
      
window.LocalStorage = new LocalStorage
