# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#    <span class="ui-icon ui-icon-arrowthick-2-n-s"></span>

class Parkingramp
  constructor: ->
    me = this
    $(".parkingramps-planes").disableSelection().sortable
      update: (event, ui) ->
        me.sortPlanes(this)

    
  sortPlanes: (ramp) ->
    data = []
    $(ramp).find("li").each ->
      data.push($(this).attr("ref"))
    $("#content").activity({color:"#FFFFFF", length:40, width:8}).overlay(true)
    $.get("/admin/parkingramps/#{$(ramp).parent("li").attr("ref")}/sortplanes/#{data.join(',')}", {}, ->
      $("#content").overlay(false).activity(false)
    )
    
  
window.Parkingramp = Parkingramp
$( ->
  new Parkingramp()
)
