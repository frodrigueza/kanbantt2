var animate_focused_items = function(){
	$('.focused').animate({boxShadow: '0 0 30px #486583'}, 2000);
	$('.focused').animate({boxShadow: '0 0 0px #486583'}, 2000);

}

$(document).ready(animate_focused_items);
$(document).on('page:load', animate_focused_items);