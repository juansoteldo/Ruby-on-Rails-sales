# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@mouseOverTable = false

@cartButtons = (value, row) ->
  '<div class="row">' +
    '<div class="col-md-5">' +
    '<button class="btn btn-xs btn-show-options btn-block" data-user-id="'+row.user.id+'" ' +
    'data-email="'+row.user.email+'" data-client-id="'+row.client_id+'" data-ga="'+row._ga+'" ' +
    'data-linker-param="'+row.linker_param+'"' +
    'data-class="deposit">Deposit</button>' +
    '</div><div class="col-md-2"></div><div class="col-md-5">' +
    '<button class="btn btn-xs btn-show-options btn-primary btn-block" data-user-id="'+row.id+'" ' +
    'data-email="'+row.user.email+'" data-client-id="'+row.client_id+'" data-ga="'+row._ga+'" ' +
    'data-linker-param="'+row.linker_param+'"' +
    'data-class="final">Final</button>' +
    '</div></div>'

@dateFormatter = (value) ->
  moment(value).format('D MMM h:mm a')

@userFormatter = (value, row) ->
  value.email

@hideButton = (value, row) ->
  return ""
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

appendSidebarUids = (userId, clientId, linkerParam, _ga) ->
  $('.btn-url').each ->
    txt = $(this).data('url')
    txt = txt.replace /uid\=[\d]*/, "uid=#{userId}"
    txt = txt.replace /clientId\=[^&]*&/, "clientId=#{clientId}&"
    linkerParam = encodeURI(linkerParam.replace('_ga=','')) if linkerParam
    txt = txt.replace /linkerParam\=[^&]*&/, "linkerParam=#{linkerParam}&"

    txt = txt.replace /_ga\=[^&]*&/, "_ga=#{_ga}&"

    $(this).data('clipboardText', txt)

ready = ->
  $('#request-table').on 'click', '.btn-hide-request', (e) ->
    id = $(e.target).data('id')

  $(document).on 'mouseenter', '#request-table', (e) ->
    window.mouseOverTable = true

  $(document).on 'mouseleave', '#request-table', (e) ->
    window.mouseOverTable = false

  $('#request-table').on 'click', '.btn-show-options', (e) ->
    e.preventDefault()
    userId = $(e.target).data('userId')
    clientId = $(e.target).data('clientId')
    linkerParam = $(e.target).data('linkerParam')
    _ga = $(e.target).data('ga')

    appendSidebarUids(userId, clientId, linkerParam, _ga)
    $('#request-table tr.active').removeClass('active')

    row = $(e.target).closest('tr')
    row.addClass 'active'

    email = $(e.target).data('email')
    $('#variants-user').text email
    openSidebar ($('#variants-user').text() != email)

    filter_class = $(e.target).data('class')
    filterSidebar(filter_class)

  setInterval ->
    $('#request-table').bootstrapTable('refresh') unless @mouseOverTable
  , 30000

$(document).ready ready
$(document).on 'page:load', ready
