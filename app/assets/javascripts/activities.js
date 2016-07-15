//triggered when modal is about to be shown
$(document).ready(function() {
  $('#activity-form').on('show.bs.modal', function(e) {
      //get data-id attribute of the clicked element
      var action = $(e.relatedTarget).data('action');
      var referrer = $(e.relatedTarget).data('referrer')
      if (action && referrer) {
        var text = "I'm joining " + referrer + " at #" + action + "."
        //populate the textbox
        $(e.currentTarget).find('textarea[name="activity[content]"]').val(text);
      }
  });
});
