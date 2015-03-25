var ready = function(){
	suscribe_options();

	$('.datepicker').datepicker({
	    format: 'yyyy-mm-dd',
	    startDate: '-3d'
	})

};

$(document).ready(ready);
$(document).on('page:load', ready);