// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-table/dist/bootstrap-table
//= require bootstrap-validator/dist/validator
//= require bootstrap-datepicker/dist/js/bootstrap-datepicker
//= require material.min
//= require material-dashboard
//= require nouislider/distribute/nouislider
//= require underscore.string/dist/underscore.string
//= require clipboard/dist/clipboard
//= require zeroclipboard
//= require sweetalert2/dist/sweetalert2
//= require moment/min/moment-with-locales
//= require bootstrap-daterangepicker/daterangepicker
//= require js-routes
//= require lightbox2/dist/js/lightbox
//= require_tree .

$(document).ready(function() {
  const $reportRange = $('#reportrange');

	const applyCallback = function(start, end) {
	  const format = 'YYYY-MM-DD';
	  $('span', $reportRange).html(start.format(format) + ' - ' + end.format(format));
    const minDate = start.format(format);
    const maxDate = end.format(format);
	  window.location.href = `salespeople?date_min=${minDate}&date_max=${maxDate}`;
	}

  $reportRange.daterangepicker({
	  ranges: {
	     'Today': [moment(), moment()],
	     'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
	     'Last 7 Days': [moment().subtract(6, 'days'), moment()],
	     'Last 30 Days': [moment().subtract(29, 'days'), moment()],
	     'This Month': [moment().startOf('month'), moment().endOf('month')],
	     'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
	  }
	});

  $reportRange.on('apply.daterangepicker', function(ev, picker) {
		const start = picker.startDate;
    const end = picker.endDate;
		applyCallback(start, end);
	});
});
