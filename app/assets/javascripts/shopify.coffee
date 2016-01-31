# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  #$('#variants').on "click", '.btn-url', closeSidebar
  $('.btn-url').each ->
    clip = new ZeroClipboard(this)
    clip.on "copy", (event) ->
      clipboard = event.clipboardData
      clipboard.setData 'text/html', $(event.target).data('clipboardHtml');
      #clipboard.setData 'text/plain', $(event.target).data('clipboardText');

    clip.on "aftercopy", (event) ->
      console.log event.data["text/html"]
      closeSidebar(true)

$(document).ready ready
$(document).on 'page:load', ready
