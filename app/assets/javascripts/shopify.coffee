# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  #$('#variants').on "click", '.btn-url', closeSidebar
  $('.btn-url').each ->
    clip = new ZeroClipboard(this)
    clip.on "copy", (event) ->
      console.log event
      userId = $(event.target).data('userId')
      clientId = $(event.target).data('clientId')
      linkerParam = $(event.target).data('linkerParam')
      _ga = $(event.target).data('ga')

      url = $(event.target).data('clipboardText')
      title = $(event.target).data('title')

      clipboard = event.clipboardData
      clipboard.setData 'text/html', "<a style='font-family: sans-serif;' href='#{url}'>#{title}</a>"

    clip.on "aftercopy", (event) ->
      console.log event.data["text/html"]
      closeSidebar(true)

$(document).ready ready
$(document).on 'page:load', ready
