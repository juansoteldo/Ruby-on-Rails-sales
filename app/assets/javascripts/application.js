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
//= require bootstrap-table
//= require bootstrap-datepicker
//= require material.min
//= require material-dashboard
//= require nouislider.min
//= require underscore.string
//= require zeroclipboard
//= require moment
//= require bootstrap-daterangepicker
//= require js-routes
//= require_tree .

$(document).ready(function() {
	function applyCallback(start, end) {
	  $('#reportrange span').html(start.format('YYYY-MM-DD') + ' - ' + end.format('YYYY-MM-DD'));
	  var min_date = start.format('YYYY-MM-DD');
	  var max_date = end.format('YYYY-MM-DD');
	  window.location.href = 'salespeople?date_min='+ min_date +'&date_max='+max_date;
	}
	$('#reportrange').daterangepicker({
	  ranges: {
	     'Today': [moment(), moment()],
	     'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
	     'Last 7 Days': [moment().subtract(6, 'days'), moment()],
	     'Last 30 Days': [moment().subtract(29, 'days'), moment()],
	     'This Month': [moment().startOf('month'), moment().endOf('month')],
	     'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
	  }
	});
	$('#reportrange').on('apply.daterangepicker', function(ev, picker) {
		var start = picker.startDate;
		var end = picker.endDate;
		applyCallback(start, end);
	})
});
