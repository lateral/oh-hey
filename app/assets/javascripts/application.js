// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
$(document).ready( function () {

	// $(".call").bind("click", function () {
		// $.ajax({
		//   url: "http://oh-hey.elasticbeanstalk.com/data.json",
		//   beforeSend: function( xhr ) {
		//   	console.log('sending');
		//   }
		// }).done(function( data ) {
		//   console.log(data);
		// });

	_.templateSettings = {
		interpolate: /\{\{\=(.+?)\}\}/g,
		evaluate: /\{\{(.+?)\}\}/g
	};

	var newsTemplate = _.template($("#news-item").html());

	$.getJSON("http://oh-hey.elasticbeanstalk.com/data.json?callback=?", function ( data) {
		console.log(data);
		$(data.news).each(function(k,v){
			var el = newsTemplate({ title: v.title });
			$(".news .cards").append(el);
		});
	});
	// });
});