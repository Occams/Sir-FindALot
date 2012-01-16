###
Sir FindALot
script.js.coffee
###


(($) ->

  # Padding of the content container left+right 
  CONTENT_PADDING = 20
  
  # Domready
  $.ready ->
    unless supportsFeatures()
      window.location = "/mobile/upgrade"
    else
      Page.init()

  # Seems like some browser do not support domready, redirect to /mobile/upgrade
  window.onload = ->
    unless supportsFeatures()
      window.location = "/mobile/upgrade"
    else Page.init()  unless Page.initialized

  supportsFeatures = ->
    m = Modernizr
    m.flexbox & m.borderradius & m.boxshadow & m.cssanimations & m.cssgradients & m.csstransforms & m.csstransitions & m.fontface & m.opacity & m.textshadow & m.applicationcache & m.generatedcontent & m.localstorage & m.fontface

  # Detect capabilities
  vendor = (if (/webkit/i).test(navigator.appVersion) then "webkit" else (if (/firefox/i).test(navigator.userAgent) then "Moz" else (if "opera" of window then "O" else "")))
  
  # Browser capabilities
  isAndroid = (/android/g).test(navigator.appVersion)
  isIDevice = (/iphone|ipad/g).test(navigator.appVersion)
  isPlaybook = (/playbook/g).test(navigator.appVersion)
  isTouchPad = (/hp-tablet/g).test(navigator.appVersion)
  hasTouch = "ontouchstart" of window and not isTouchPad
  
  # Events
  RESIZE_EV = (if "onorientationchange" of window then "orientationchange" else "resize")
  START_EV = (if hasTouch then "touchstart" else "mousedown")
  MOVE_EV = (if hasTouch then "touchmove" else "mousemove")
  END_EV = (if hasTouch then "touchend" else "mouseup")
  CANCEL_EV = (if hasTouch then "touchcancel" else "mouseup")

  # Extensions
  $.fn.css3Slide = (slideType) ->
    @each ->
      $(this).removeClass($.fn.css3Slide.types).addClass $.fn.css3Slide.typesToClass[slideType]

  $.fn.css3Slide.types = "slide in out reverse"
  $.fn.css3Slide.typesToClass =
    slideinfromleft: "slide in reverse"
    slideouttoleft: "slide out"
    slideinfromright: "slide in"
    slideouttoright: "slide out reverse"

  $.fn.fastbutton = (handler) ->
    @each ->
      new MBP.fastButton(this, handler)

    this

  $.fn.rAttr = (attr) ->
    @each (el) ->
      el.removeAttribute attr

    this

  # Legacy support (display:block) may be removed because of Modernizr testing
  $.fn.show = ->
    @css
      display: "block"
      display: "box"
      display: "-" + vendor + "-box"

    this

  $.fn.hide = ->
    @setStyle "display", "none"
    this

  $.fn.dimensions = ->
    element = this[0]
    display = @getStyle("display")
    if display and display isnt "none"
      return (
        width: element.offsetWidth
        height: element.offsetHeight
      )
    style = element.style
    originalStyles =
      visibility: style.visibility
      position: style.position
      display: style.display

    newStyles =
      visibility: "hidden"
      display: "block"

    newStyles.position = "absolute"  if originalStyles.position isnt "fixed"
    Element.setStyle element, newStyles
    dimensions =
      width: element.offsetWidth
      height: element.offsetHeight

    Element.setStyle element, originalStyles
    dimensions

  $.fn.width = ->
    @dimensions().width

  $.fn.height = ->
    @dimensions().height

  String::idify = ->
    (if (@indexOf("#") > -1) then @substring(@indexOf("#") + 1, @length) else this)

  String::hashify = ->
    (if (this[0] is "#") then this else "#" + this)

  Page =
    initialized: false # If Page.init() has already been invoked
    pages: null # Holds all pages initially present in #viewport
    footer: null # Holds the references to all footer elements
    viewport: null # Holds #viewport
    gFooter: null 
    gHeader: null
    modal: null
    id_page_hash: {} # Hash from page id to page element
    id_pagenum_hash: {} # Hash from page id to page number
    current_page: null # Holds the current page id
    home: null # startpage element
    scrollers: {} #  Hash from scroller container id to IScroll object
    lock: false
    
    init: ->
      @initialized = true
      @pages = $("#viewport div[data-type=page]")
      @footer = $("#viewport footer")
      @viewport = $("#viewport")
      @gHeader = $("#global-header")
      @gFooter = $("#global-footer")
      @modal = $("#modal")
      @pages.each (el, i) ->
        Page.id_page_hash[el.getAttribute("id")] = el
        Page.id_pagenum_hash[el.getAttribute("id")] = i

      # IScroll Initialization
      $(".scroller").each (el) ->
        id = el.getAttribute("id")
        Page.scrollers[id] = new iScroll(id,
          hScroll: false
          onBeforeScrollStart: Page._makeIScrollFriendly
        )

      # LocalStorage initialization
      localStorage.setItem "auto_geo", "true"  unless localStorage.getItem("auto_geo")  if localStorage
      
      # Position object initializiation with last known position
      if localStorage.getItem("position")
        p = JSON.parse(localStorage.getItem("position"))
        Position.longitude = p.longitude
        Position.latitude = p.latitude
        
      # Register Page update event
      @pages.on "update", (e) ->
        page = $(this)
        unless e.data.onlyIScroll
        
          # Update global header and footer
          Page.gHeader.html page.find("header")[0].innerHTML
          Page.gFooter.html page.find("footer")[0].innerHTML
          
          # Attach event handlers to account for androids :active css bug
          Page._registerFakeActive()
          
          # No callout on navigation links
          Page.gFooter.find("a").addClass "nocallout"
          
          # Fastbutton update for toolbar links
          Page.gFooter.find("a").fastbutton (e) ->
            Page.show @element.getAttribute("href").idify()
            e.preventDefault()
            false
        
        # Update IScroll4 object, IScroll4 doc recommends using setTimeout
        scrollID = page.find(".scroller")[0].getAttribute("id")
        setTimeout (->
          Page.scrollers[scrollID].refresh()
        ), 0
        
        # Scroll to top
        Page.scrollers[scrollID].scrollTo 0, 0, 0  if e.data.toTop

      # Show the first page or an explicitly declared home page initially
      startpage = @pages.has("div[home=yes]")[0]
      @home = (if startpage then startpage else @pages[0])
      @show home.getAttribute("id")
      
      # Update width of Parkingarea object, must be invoked after the first page is shown.
      Parkingarea.width = $(startpage).find("div[data-type=\"page-content\"]").width() - CONTENT_PADDING
      
      # Initialize accordions, modal window and options page
      @_initAccordions()
      @_initModal()
      Options.init()
      
      # Register search handler
      $("#geolocation_search_form").on "submit", (e) ->
        loading = $("#loading")
        input = $("#geolocation_search")
        
        # Show orange loading animation
        loading.removeClass("green").addClass "orange"
        loading.show()
        
        # Disable input
        input.attr "disabled", "disabled"
        
        # Send POST request to server
        Search.doSearch input[0].value, null, $("#search div[data-type=\"page-content\"]"), (->
          $("#loading").hide()
          input.rAttr "disabled"
          Page.show "search"
        ), ->
          $("#loading").hide()
          input.rAttr "disabled"
          Page._showModal "Error on server", "The server returned with an error. Please try again later..."

        # Reset search field
        input[0].value = ""
        e.preventDefault()
        false

      # Test if automatic geolocation is enabled
      auto = eval(localStorage.getItem("auto_geo"))
      
      # Start Geolocation
      if navigator.geolocation and auto
        navigator.geolocation.getCurrentPosition @_geoPosition, @_geoError
      else
        @_geoError()
        
      #  Update IScroll and parkingarea width/height on orientationchange, requires a certain delay to work on mobile devices
      window.addEventListener RESIZE_EV, (e) ->
        setTimeout (->
          Page.pages.fire "update",
            onlyIScroll: true

          Parkingarea.width = $(Page._getPage(Page.current_page)).find("div[data-type=\"page-content\"]").width() - CONTENT_PADDING
          Parkingarea.update()
        ), 500

    show: (id) ->
      id = Page.home  if id is ""
      return  unless @_isPage(id)
      return  unless @_lock() # try to place a lock on the page
      unless @current_page?
        @current_page = id
        @_getPage(id).show()
        
        # Fire a page update event
        @_getPage(id).fire "update",
          toTop: true

        @_unlock()
      else unless id is @current_page
        to = @_getPage(id).show()
        from = @_getPage(@current_page)
        
        # Fire a page update event
        to.fire "update",
          toTop: true

        # Determine slide directions
        slideLeft = @_getPageNum(id) > @_getPageNum(@current_page)
        to.css3Slide (if slideLeft then "slideinfromright" else "slideinfromleft")
        from.css3Slide (if slideLeft then "slideouttoleft" else "slideouttoright")
        @current_page = id
        setTimeout ((e) ->
          window.location.hash = Page.current_page.hashify() # browser history
          from.hide()
          Page._unlock()
        ), 775 # wait for the slide animation to end
      else
        @_unlock()

    _geoError: (error) ->
      if error
        switch error.code
          when error.TIMEOUT
            Page._showModal "Geolocation - Timeout", "Sorry, I experienced a timeout while trying to geolocate your device. You may still issue a custom search."
          when error.POSITION_UNAVAILABLE
            Page._showModal "Geolocation - N/A", "Sorry, your current position is not available. You may still issue a custom search."
          when error.PERMISSION_DENIED
            Page._showModal "Geolocation - Timeout", "Sorry, it seems like you denied my request to geolocate you. You may still issue a custom search."
          else
            Page._showModal "Geolocation - Unknown Error", "Sorry, I encountered an error while trying to geolocate you. You may still issue a custom search."
      
      # Load ranked results from history
      Search.doSearch null, null, "#geolocation_search_results"
      input = $("#geolocation_search")
      form = $("#geolocation_search_form")
      
      # Hide loading animation
      $("#loading").setStyle "display", "none"
      
      # Enable input field and change placeholder text
      input.attr "placeholder", "Touch to enter custom query..."
      input.rAttr "disabled"
      form.removeClass("green").addClass "orange"

    _geoPosition: (position) ->
    
      # Initialize Position object, update last known position
      Position.longitude = position.coords.longitude
      Position.latitude = position.coords.latitude
      localStorage.setItem "position", "{\"latitude\" : " + Position.latitude + ", \"longitude\" : " + Position.longitude + "}"
      input = $("#geolocation_search")
      form = $("#geolocation_search_form")
      data =
        coords: position.coords
        timestamp: position.timestamp

      Search.doSearch null, data, "#geolocation_search_results", (->
        $("#loading").hide()
        input.attr "placeholder", "Touch to enter custom query..."
        input.rAttr "disabled"
        form.removeClass("green").addClass "orange"
        $("#home").fire "update"
      ), ->
        $("#loading").hide()
        input.attr "placeholder", "Touch to enter custom query..."
        input.rAttr "disabled"
        form.removeClass("green").addClass "orange"
        Page._showModal "Error on server", "The server returned with an error. Please try again later..."

    _parkingAreaLoaded: ->
      eval "var data = " + @responseText
      Search.log data.id
      Parkingarea.fill data
      Page._hideLoadingAnimation()
      
      # Show levels or map page
      if data.parkingplanes.length > 1
        Page.show "lot_levels"
      else
        Page.show "lot_map"

    _registerFakeActive: ->
      if isAndroid
        $("a[fake-active=yes], .faq h1[fake-active=yes], div[fake-active=yes]").on("touchstart", (e) ->
          $(this).addClass "fake-active"
        ).on(END_EV, ->
          $(this).removeClass "fake-active"
        ).on CANCEL_EV, ->
          $(this).removeClass "fake-active" # sometimes Android fires a touchcancel event rather than a touchend. Handle this too.

    _getPage: (id) ->
      $ @id_page_hash[id]

    _getPageNum: (id) ->
      @id_pagenum_hash[id]

    _isPage: (id) ->
      @id_page_hash[id]?

    _lock: ->
      return false  if Page.lock
      Page.lock = true
      true

    _unlock: ->
      Page.lock = false

    _initModal: ->

      $("#modal_close").fastbutton (e) ->
        Page._closeModal()
        e.preventDefault() # Prevent hash/page change
        false

    _showModal: (heading, text) ->
      modal = $("#modal")
      Page._fadeOverlay()
      $("#modal h1").html ":: " + heading
      $("#modal p").html text
      modal.show()

    _closeModal: ->
      $("#modal").hide()
      Page._removeFadeOverlay()

    _fadeOverlay: ->
      fade = $("#fade")
      fade.setStyle "z-index", "1000"
      fade.setStyle "opacity", "0.8"

    _removeFadeOverlay: ->
      fade = $("#fade")
      fade.setStyle "z-index", "0"
      fade.setStyle "opacity", "0"

    _initAccordions: ->
      $(".faq h1").fastbutton (e) ->
        el = $(@element)
        id = el.attr("id")
        target = $(".faq p[rel=" + id + "]")
        toggle = target.hasClass("open")
        
        # Close already open elements
        $(".faq .open").removeClass "open"
        
        # Open the new element
        unless toggle
          target.addClass "open"
          el.addClass "open"
        
        # Update IScroll because height changed during animation
        setTimeout (->
          $(Page._getPage(Page.current_page)).fire "update",
            toTop: false
            onlyIScroll: true
        ), 500

    _displayLoadingAnimation: (e) ->
      Page._fadeOverlay()
      $("#loading_overlay").show()

    _hideLoadingAnimation: (e) ->
      $("#loading_overlay").hide()
      Page._removeFadeOverlay()

    # Prevent IScroll on certain elements, restores functionality
    _makeIScrollFriendly: (e) ->
      target = e.target
      
      # bubble up
      target = target.parentNode  until target.nodeType is 1
      
      if target.tagName isnt "SELECT" and target.tagName isnt "INPUT" and target.tagName isnt "TEXTAREA"
        e.preventDefault()
        false

  window.onhashchange = (event) ->
    event.preventDefault()
    Page.show window.location.hash.idify()
    false

  if typeof exports isnt "undefined"
    exports.Page = Page
  else
    window.Page = Page
) x$