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

	_.templateSettings = {
		interpolate: /\{\{\=(.+?)\}\}/g,
		evaluate: /\{\{(.+?)\}\}/g
	};

	var newsTemplate = _.template($("#news-item").html());
	var githubProfileTemplate = _.template($("#github-profile-item").html());
	var githubMutualTemplate = _.template($("#github-mutual-item").html());

	function getData() {
		$.getJSON("http://oh-hey.elasticbeanstalk.com/data.json?callback=?", function ( data ) {
			console.log(data);
			if (data != null) {
				if (data.users != null) {
					$('.users').empty();
					$(data.users).each(function(k,v) {
						$('.users').append("<div class='user' style='background: url("+v.github_json.photo+"); background-size: 100%;' ></div>");
					});
				}

				$('.github .cards').empty();
				
				if (data.users && data.users.length > 0) {
					var profileFound = false;


					$(data.users).each(function (k,v) {
						if (v.github_json) {
							profileFound = true;


							var el = githubProfileTemplate({ 
								name: v.github_json.name,
								username: v.github_json.username,
								image: v.github_json.photo,
								joined: 'JOINED: ' + v.github_json.joined
							});
							$(".github > .cards").append(el);
						}
					});

					if (profileFound) {
						$('.github.column').addClass('show');
					} else {
						$('.github.column').removeClass('show');
					}

					$(".github .more > .cards").empty();
					if (data.mutual_github && data.mutual_github.length > 0) {

						$(data.mutual_github).each( function (k,v) {
							var el = githubMutualTemplate({ 
								repo: v.title,
								stars: v.stars,
								updated: 'UPDATED: ' + v.updated,
								description: v.description,
								show: v.description && v.description.length > 0 ? "show" : ""
							});
							$(".github .more > .cards").append(el);
						});

						$('.github .more').addClass('show');
					} else {
						$('.github .more').removeClass('show');
					}
				}
				
				if (data.news && data.news.length > 0) {
					$('.news > .data').text(data.news.length + " News Items");
					$('.news .cards').empty();
					$(data.news).each(function(k,v){
						var el = newsTemplate({ 
							title: v.title,
							summary: v.summary,
							source: v.source,
							date: v.published,
							source_slug: v.source_slug
						});
						$(".news > .cards").append(el);
						if (data.news.length > 0) {
							$('.news.column').addClass('show');
						}
					});
				} else {
					$('.news.column').removeClass('show');
				}
			}
		})
			.always(function() {
	    		setTimeout(function(){getData();}, 3000);
	  		});
	}

	getData();
});