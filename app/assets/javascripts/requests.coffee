# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@cartButtons = (value, row) ->
  '<div class="row">' +
    '<div class="col-md-5">' +
    '<button class="btn btn-xs btn-show-options btn-block" data-user-id="'+row.id+'" ' +
    'data-user-id="'+row.email+'" data-client-id="'+row.client_id+'" data-class="deposit">Deposit</button>' +
    '</div><div class="col-md-2"></div><div class="col-md-5">' +
    '<button class="btn btn-xs btn-show-options btn-primary btn-block" data-user-id="'+row.id+'" ' +
    'data-user-id="'+row.email+'" data-client-id="'+row.client_id+'" data-class="final">Final</button>' +
    '</div></div>'

@dateFormatter = (value) ->
  moment(value).format('D MMM')

@userFormatter = (value, row) ->
  value.email

@hideButton = (value, row) ->
  "<button class='btn btn-sm btn-default btn-hide-request' data-id='#{value}'>hide</button>"

@firstFormatter = (value, row) ->
  return '1st' if value
  ''

@colorFormatter = (value, row) ->
  return "<img src='#{image_path('color-wheel.png')}' width='16' height='16'/>" if value
  ''

@coverFormatter = (value, row) ->
  return '<div style="border: 1px solid #222;padding: 2px;color: #444;" class="">CU</div>' if value
  ''

filterSidebar = (filter) ->
  $("#variants .deposit, #variants .final").hide()
  $("#variants .#{filter}").show()

appendSidebarUids = (userId, clientId) ->
  $('.btn-url').each ->
    txt = $(this).data('clipboard-text')
    txt = txt.replace /uid\=[\d]*/, "uid=#{userId}"
    txt = txt.replace /clientId\=[^&]*&/, "clientId=#{clientId}&"
    $(this).attr('data-clipboard-text', txt)

ready = ->
  $('#request-table').on 'click', '.btn-hide-request', (e) ->
    id = $(e.target).data('id')


  $('#request-table').on 'click', '.btn-show-options', (e) ->
    e.preventDefault()
    row = $(e.target).closest('tr')
    userId = $(e.target).data('userId')
    clientId = $(e.target).data('clientId')
    console.log clientId
    appendSidebarUids(userId, clientId)
    $('#request-table tr.active').removeClass('active')
    row.addClass 'active'

    email = $(e.target).data('email')
    $('#variants-user').text email
    openSidebar ($('#variants-user').text() != email)

    filter_class = $(e.target).data('class')
    filterSidebar(filter_class)

$(document).ready ready
$(document).on 'page:load', ready
