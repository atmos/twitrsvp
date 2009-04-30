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
    $('.date-picker').datepicker({
      clickInput:true,
      buttonImage: '/img/calendar.png',
      buttonImageOnly: true,
      showOn: 'button'
    });
    $(".time-picker").timePicker();
  });
});
