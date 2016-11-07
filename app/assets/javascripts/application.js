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
//= require turbolinks
//= require bootstrap.min
//= require html5shiv
//= require respond.min
//= require freelancer
//= require jquery.iframetracker.js
//= require toastr.min.js
//= require_tree .

$(document).ready(function () {
  toastr.options = {
    "closeButton": false,
    "debug": false,
    "newestOnTop": false,
    "progressBar": false,
    "positionClass": "toast-top-center",
    "preventDuplicates": false,
    "onclick": null,
    "showDuration": "300",
    "hideDuration": "1000",
    "timeOut": "3000",
    "extendedTimeOut": "1000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
  }
  window.setTimeout(listenFBiframe, 500);
});

function listenFBiframe() {
  var $fbi = $('.fb-send-to-messenger iframe');
  if ($fbi.length)
    $fbi.load(function () {
      $('#fb-loading-spinner').hide();
      $fbi.iframeTracker({
        blurCallback: function () {
          window.setTimeout(function () {
            $('#guide-fb-messenger').show();
          }, 500)
        }
      });
    });
  else
    window.setTimeout(listenFBiframe, 500);
}

function openFBM() {
  window.open('https://m.me/kickybot', '_blank');
}