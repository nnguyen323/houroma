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
//= require turbolinks
//= require jquery.turbolinks
//= require typeahead
//= require jqcloud
//= require activities
$(document).ready(function() {$('.modal').on('show.bs.modal', function(e) {
    //uhhh not ideal but works perfectly for me so far... not sure if same is true on slug computer 
    setTimeout(function() {
      $('[autofocus]', e.target).focus();
    }, 50);
  });
  // for search dropdown
  $('.dropdown-menu').find('form').click(function (e) {
      e.stopPropagation();
  });
  // press confirm button when they hit enter
  $('#pass-prompt, #pass-prompt-pw, #pass-prompt-act').on('keypress', function(e) {
      if( e.keyCode === 13 ) {
          e.preventDefault();
          $(e.currentTarget).find('[confirm_button]').click();
      }
  });
    /* Transfer focus to search box*/
  $('#search-icon').click(function() {
    setTimeout(function() {
      $('#search-all').focus();
    }, 50);
  });
  /* Transfer click to file input button when user changes image ==from user settings page== */
  $('#file-input-button').click(function() {
    $('#file-input').click();
  });
  /* Transfer the current file text to the display text */
  $('#file-input').change(function() {
    var icon = document.getElementById('display-text');
    icon.innerHTML = $('#file-input').val().replace(/^.*[\\\/]/, '');
  }); 
  /* Transfer click to file input button on activity modal */
  $('#activity-file-button').click(function() {
    $('#activity-file').click();
  });
});
// probably want to change this so instead of using hard width of 120/120 it uses up to the image size but caps it at 400
// because it would make a lot more sense for when they put pictures inside their activity form
function previewImage(input, image_id, w, h) {
  if (input.files && input.files[0]) {
    var reader = new FileReader();
    var moz_fix = document.getElementById(image_id.substring(1));

    reader.onload = function (e) {
      $(image_id)
        .attr('src', e.target.result)
        .width(w)
        .height(h);

      if (moz_fix)
        moz_fix.style.visibility="visible";
    };

    reader.readAsDataURL(input.files[0]);
  }
}
function previewLargeImage(image, preview_id) {
    $(preview_id).attr('src', image )
}

var rates = new Object();
/* are the search engines running */
var header_hound_engine = false;
var nest_hound_engine = false;