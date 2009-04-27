$(function() {
  $("#main a.should_post").click(function() {
    jQuery.post($(this).attr('href'), {}, function(data, textStatus) {
      if(textStatus == 'success') {
        top.location.href = '/'
      }
    });
    return false;
  });
  jQuery(document).ready(function($) {
//    $("#main").tabs();
  });
});
