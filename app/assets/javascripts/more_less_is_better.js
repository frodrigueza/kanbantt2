var more_less_is_better = function(){
	
	$('.more_is_better').each(function(index, value){
		var item = $(this);
		console.log(item.html());
		var value = item.html();

		if (value > 0 ) 
		{
			item.addClass('great');
		}
		else
		{
			item.addClass('bad')
		}
	});
	
	$('.less_is_better').each(function(index, value){
		var item = $(this);
		console.log(item.html());
		var value = item.html();

		if (value <= 0 ) 
		{
			item.addClass('great');
		}
		else
		{
			item.addClass('bad')
		}
	}); 
}


$(document).ready(more_less_is_better);
$(document).on('page:load', more_less_is_better);