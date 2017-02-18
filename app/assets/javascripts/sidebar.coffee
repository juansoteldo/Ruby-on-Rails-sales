@openSidebar = (collapse) ->
  $(".sidebar").collapse collapse && 'hide' || 'show'
  $('div.group').collapse 'hide'

@closeSidebar = (collapse) ->
  $(".sidebar").collapse collapse && 'hide' || 'show'

