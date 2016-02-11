# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@mouseOverTable = false

@cartButtons = (value, row) ->
  '<div class="row">' +
    '<div class="col-md-5">' +
    '<button class="btn btn-xs btn-show-options btn-block"' +
    'data-email="'+row.user.email+'" data-id="'+row.id+'"' +
    'data-class="deposit">Deposit</button>' +
    '</div><div class="col-md-2"></div><div class="col-md-5">' +
    '<button class="btn btn-xs btn-show-options btn-primary btn-block"' +
    'data-email="'+row.user.email+'" data-id="'+row.id+'"' +
    'data-class="final">Final</button>' +
    '</div></div>'

@dateFormatter = (value) ->
  moment(value).format('D MMM h:mm a')

@userFormatter = (value, row) ->
  "<span title='#{row.client_id}'>#{value.email}</span>"

@hideButton = (value, row) ->
  return ""
  "<button class='btn btn-sm btn-default btn-hide-request' data-id='#{value}'>hide</button>"

@firstFormatter = (value, row) ->
  return '1st' if value
  ''

@visitedFormatter = (value, row) ->
  return '<span class="glyphicon glyphicon-eye-open"></span>' if value
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

appendSidebarUids = (el) ->
  requestId = $(el).data('id')

  $('.btn-url').each ->
    url = $(this).data('url')
    if typeof(requestId) != 'undefined'
      url = url.replace /requestId\=/, "requestId=#{requestId}"

    $(this).data('clipboardText', url)

ready = ->
  $('#request-table').on 'click', '.btn-hide-request', (e) ->
    id = $(e.target).data('id')

  $(document).on 'mouseenter', '#request-table', (e) ->
    window.mouseOverTable = true

  $(document).on 'mouseleave', '#request-table', (e) ->
    window.mouseOverTable = false

  $('#request-table').on 'click', '.btn-show-options', (e) ->
    e.preventDefault()


    appendSidebarUids(e.target)
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
