# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@cartButtons = (value, row) ->

  '<div class="row">' +
    '<div class="col-md-5">' +
    '<button class="btn btn-xs btn-show-options btn-block" data-class="deposit">Deposit</button>' +
    '</div><div class="col-md-2"></div><div class="col-md-5">' +
    '<button class="btn btn-xs btn-show-options btn-primary btn-block" data-class="final">Final</button>' +
    '</div></div>'

@firstFormatter = (value, row) ->
  return '1st' if value
  ''

@colorFormatter = (value, row) ->
  return '<img src="assets/color-wheel.png" width="16" height="16"/>' if value
  ''

filterSidebar = (filter) ->
  $("#variants .deposit, #variants .final").hide()
  $("#variants .#{filter}").show()
  $('#variants-title').
  text(s.titleize(filter) + " Products").addClass(filter)

appendSidebarUids = (userId) ->
  $('.btn-url').each ->
    txt = $(this).data('clipboard-text')
    txt = txt.replace /uid\=[\d]*/, "uid=#{userId}"
    $(this).attr('data-clipboard-text', txt)

ready = ->
  $('#request-table').on 'click', '.btn-show-options', (e) ->
    e.preventDefault()
    row = $(e.target).closest('tr')
    userId = $($('td', row )[0]).text()
    appendSidebarUids(userId)
    $('#request-table tr.active').removeClass('active')
    email = $($('td', row )[1]).text()
    $('#variants-user').text email
    console.log email
    openSidebar()

    filter_class = $(e.target).data('class')
    filterSidebar(filter_class)

$(document).ready ready
$(document).on 'page:load', ready