# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


copyUrl = (event) ->
  btn = event.target
  url = $(btn).data('url')
  closeSidebar(event)

ready = ->
  $('#variants').on "click", '.btn-url', copyUrl
  console.log "attached"

$(document).ready ready
$(document).on 'page:load', ready