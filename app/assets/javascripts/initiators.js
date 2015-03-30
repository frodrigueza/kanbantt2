var ready = function(){
	suscribe_options();

	$('.datepicker').datepicker({
	    format: 'yyyy-mm-dd',
	    todayHighlight: true,
	    weekStart: 1,
	    language: 'es'

	})

};

$(document).ready(ready);
$(document).on('page:load', ready);