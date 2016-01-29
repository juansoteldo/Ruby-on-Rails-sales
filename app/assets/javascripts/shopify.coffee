# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


copyText = (url) ->
  doc = document
  text = doc.createElement('SPAN')
  $(text).text url
  range = undefined
  selection = undefined
  if doc.body.createTextRange
    range = document.body.createTextRange()
    range.moveToElementText text
    range.select()
  else if window.getSelection
    selection = window.getSelection()
    range = document.createRange()
    range.selectNodeContents text
    selection.removeAllRanges()
    selection.addRange range
  document.execCommand 'copy'
  $(text).remove()
  return

ready = ->
  #$('#variants').on "click", '.btn-url', closeSidebar
  $('.btn-url').each ->
    clip = new ZeroClipboard(this)
    clip.on "aftercopy", (event) ->
      closeSidebar(true)

$(document).ready ready
$(document).on 'page:load', ready
