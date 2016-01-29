@openSidebar = (collapse) ->
  $("#wrapper").removeClass("toggled")
  $("#variants .collapse").removeClass("in") if collapse

@closeSidebar = (collapse) ->
  $("#wrapper").addClass("toggled")
  $("#variants .collapse").removeClass("in") if collapse

