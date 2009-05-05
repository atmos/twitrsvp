$(function() {
  $("#page a.should_post").click(function() {
    jQuery.post($(this).attr('href'), {}, function(data, textStatus) {
      if(textStatus == 'success') {
        top.location.href = '/manage'
      }
    });
    return false;
  });
  $("textarea[name='description']").keyup(function(){
    limitChars($("textarea[name='description']"), 140, '#charlimitinfo');
  });

  function limitChars(textid, limit, infodiv) {
    var text = textid.val(); 
    var textlength = text.length;

    if(textlength > limit) {
      $(infodiv).html('(char left: '+ (limit - textlength) +')');
      textid.val(text.substr(0,limit));
      return false;
    } else {
      $(infodiv).html('(char left: '+ (limit - textlength) +')');
      return true;
    }
  }

  jQuery(document).ready(function($) {
    $('.date-picker').datepicker({
      clickInput:true,
      dateFormat: 'yy/mm/dd',
      buttonImage: '/img/calendar.png',
      buttonImageOnly: true,
      showOn: 'button'
    });
    $("textarea[name='description']").each(function(el) {
      limitChars($(this), 140, '#charlimitinfo');
    });
  });
});
