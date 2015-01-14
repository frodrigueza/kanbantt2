var ready = function(){
	suscribe_options();
	$(".bs-switch").bootstrapSwitch();
};

$(document).ready(ready);
$(document).on('page:load', ready);