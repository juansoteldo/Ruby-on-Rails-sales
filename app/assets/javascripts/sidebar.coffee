@openSidebar = ->
  $("#wrapper").removeClass("toggled")

@closeSidebar = ->
  $("#wrapper").addClass("toggled")

@filterSidebar = (filter) ->
  $("#variants .deposit, #variants .final").hide()
  $("#variants .#{filter}").show()
  $('#variants-title').text(filter)