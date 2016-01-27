@openSidebar = ->
  $("#wrapper").removeClass("toggled")
  $("#variants .collapse").removeClass("in")

@closeSidebar = ->
  $("#wrapper").addClass("toggled")

