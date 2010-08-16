$(document).ready(function(){
	$("#declined_whole").css({position: "absolute"});

	//$('input').animate({opacity: "0.8"}, 0);
	$('input').hover( function () {
        $(this).animate({opacity: "0.8"}, 100);
    }, function () {
        $(this).animate({opacity: "1.0"}, 100);
    });
	
	
	$("#declined").animate({opacity: "1.0"}, 1500, function() {
		$("#declined").animate({marginRight: "-=160px"}, 1000, function() { 
			$("#declined_whole").css({zIndex: "0"});
		});
	});
	
	$("#declined_tab").toggle(function(){
		$("#declined").animate({marginRight: "+=160px"}, 1000);
		$("#declined_whole").css({zIndex: "1000"});
	}, function(){
		$("#declined").animate({marginRight: "-=160px"}, 1000, function() { 
			$("#declined_whole").css({zIndex: "0"});
		});
	});
	
	$('.jhide').hide('fast', function() {
		$(this).after('(<a class="show_me context" href="#">more to read</a>)'),
		$('a.show_me').toggle(function () {
			$('.jhide').slideDown(1500);
			$(this).addClass('orange').empty().prepend('X close')
			return false;
		}, function() {
			$('.jhide').slideUp(1500);
			$(this).removeClass('orange').empty().prepend('more to read')
			return false;
		});
	});
	
});