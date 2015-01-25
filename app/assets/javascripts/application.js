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
  var eventsTemplate = _.template($("#event-item").html());
  var githubProfileTemplate = _.template($("#github-profile-item").html());
  var githubMutualTemplate = _.template($("#github-mutual-item").html());
  var twitterProfileTemplate = _.template($("#twitter-profile-item").html());
  var twitterMutualTemplate = _.template($("#twitter-mutual-item").html());

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
        $('.twitter .cards').empty();

        if (data.users && data.users.length > 0) {
          var githubProfileFound = false;
          var twitterProfileFound = false;


          $(data.users).each(function (k,v) {
            if (v.github_json) {
              githubProfileFound = true;
              var el = githubProfileTemplate({
                name: v.github_json.name,
                username: v.github_json.username,
                image: v.github_json.photo,
                joined: 'JOINED: ' + v.github_json.joined
              });
              $(".github > .cards").append(el);
            }

            if (v.twitter_json) {
              twitterProfileFound = true;
              var el = twitterProfileTemplate({
                name: v.twitter_json.name,
                photo: v.twitter_json.photo.replace("_normal", ""),
                handle: v.twitter_json.username,
                followers: v.twitter_json.followers,
                description: v.twitter_json.description,
                show: v.twitter_json.description && v.twitter_json.description.length > 0 ? "show" : ""
              });
              $(".twitter > .cards").append(el);
            }
          });

          if (githubProfileFound) {
            $('.github.column').addClass('show');
          } else {
            $('.github.column').removeClass('show');
          }

          if (twitterProfileFound) {
            $('.twitter.column').addClass('show');
          } else {
            $('.twitter.column').removeClass('show');
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

          $(".twitter .more > .cards").empty();
          if (data.mutual_following && data.mutual_following.length > 0) {
            $(data.mutual_following).each(function (k,v) {
              var el = twitterMutualTemplate({
                name: v.username,
                photo: v.photo.replace("_normal", ""),
                handle: v.username,
                followers: v.followers
              });
              $(".twitter .more > .cards").append(el);
            });

            $('.twitter .more').addClass('show');
          } else {
            $('.twitter .more').removeClass('show');
          }
        } else {
          $('.github.column').removeClass('show');
          $('.twitter.column').removeClass('show');
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

        if (data.events && data.events.length > 0) {
          $('.events > .data').text(data.events.length + " Events");
          $('.events .cards').empty();
          $(data.events).each(function(k,v){
            var el = eventsTemplate(v);
            $(".events > .cards").append(el);
            if (data.events.length > 0) {
              $('.events.column').addClass('show');
            }
          });
        } else {
          $('.events.column').removeClass('show');
        }
      }
    }).always(function() {
      setTimeout(function(){getData();}, 2000);
    });
  }

  getData();
});
