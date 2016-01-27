# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@cartButtons = (value, row) ->
  '<button class="btn btn-xs btn-show-options" data-class="deposit">Deposit</button>' +
    '<button class="btn btn-xs btn-show-options" data-class="final">Final</button>'

@firstFormatter = (value, row) ->
  return '1st' if value
  ''

@colorFormatter = (value, row) ->
  return '<img src="assets/color-wheel.png" width="16" height="16"/>' if value
  ''

ready = ->
  $('#request-table').on 'click', 'tbody tr', (e) ->
    e.preventDefault()
    $('#request-table tr.active').removeClass('active')
    $(e.target).parent().addClass('active')
    openSidebar()

  $('#request-table').on 'click', '.btn-show-options', (e) ->
    e.preventDefault()
    filter_class = $(e.target).data('class')
    $('button', e.target.parentElement).removeClass('btn-primary')
    $(e.target).addClass('btn-primary')
    filterSidebar(filter_class)

$(document).ready ready
$(document).on 'page:load', ready