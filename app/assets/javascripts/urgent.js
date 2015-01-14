var urgents = function(){
	$('.urgent').click(function(){

		var task_id = $(this).attr('id').split('_')[1];
		console.log(task_id);
		// actualizamos la task en la base de datos
        $.ajax({
            url: "/tasks/" + task_id + "/toggle_urgent",
            type: "GET"
        });

	});
}

$(document).ready(urgents);
$(document).on('page:load', urgents);