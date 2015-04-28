$(function(){
	// Metodo que crea la funcion selectedModifier y suscribe el select a esta
	var filter = function(){
		var selected_colour = 0;

		// Metodo que oculta o muestra segun el filtro seleccionado
		var selectedModifier = function(){
			

			// rango de tiempo 
			var daysRange;
			// almacenamos el valor seleccionado
			var date_select = $('#date_select_filter').val();
			var status_select = $('#status_select_filter').val();
			var pin_select = $('#pin').hasClass('active');
			var delayed_select = $('#delayed').hasClass('active');

			// segun el valor seleccionado en el select definimos el rango de tiempo a filtrar
			switch(date_select)
			{
				case 'Hoy':
					daysRange = 0;
					break;

				// hasta el siguiente domingo
				case 'Esta semana':
					var endDay = Date.today().moveToDayOfWeek(0);
					daysRange = (endDay.getTime() - Date.today().getTime())/ (1000 * 3600 * 24);
					break;

				// dentro de estas 2 semanas
				case 'Estas 2 semanas':
					var endDay = Date.today().moveToDayOfWeek(0).moveToDayOfWeek(0);
					daysRange = (endDay.getTime() - Date.today().getTime())/ (1000 * 3600 * 24);
					break;

				// este mes
				case 'Este mes':
					var endDay = Date.today().moveToLastDayOfMonth();
					daysRange = (endDay.getTime() - Date.today().getTime())/ (1000 * 3600 * 24);
					break;

				case 'Todos':
					daysRange = Number.POSITIVE_INFINITY;
					break;
			}

			// para cada item dentro del kanban 
			$('.kanban_item').each(function(index, value){
				// obtenemos las fechas de inicio y termino almacenadas en el html
				var start_date = Date.parse($(this).data('startdate'));
				var end_date = Date.parse($(this).data('enddate'));
				var today = $.now();
				var task_name = $(this).data('name');
				
				// creamos una variable auxiliar que represente un día (multiplicación)
				var oneDay = 24*60*60*1000;
				
				// alamcenamos el numero de días entre el termino de la tarea hasta hoy
				var diffDaysEnd = Math.round((end_date - today)/(oneDay)) + 1;
				if (diffDaysEnd < 0) 
				{
					diffDaysEnd = Number.POSITIVE_INFINITY;
				}
				
				// alamcenamos el numero de días entre el inicio de la tarea hasta hoy
				var diffDaysStart = Math.round((start_date - today)/(oneDay)) + 1;
				if (diffDaysStart < 0) 
				{
					diffDaysStart = Number.POSITIVE_INFINITY;
				}

				// almacenamos el estado de color, pin y delayed desde el HTML.
				var status = $(this).data('status');
				var pin_status = $(this).data('pin-status');
				var colour_id = $(this).data('colour');
				console.log('Item con color ' + colour_id);

				// FILTRO DE FECHAS /////////////////////////////////////////////////////////////
				if (start_date <= Date.today() && end_date >= Date.today()) // cuando estamos dentro del plazo de una tarea siempre se muestra
				{
					$(this).removeClass('hidden_by_date');
				}
				else if(diffDaysStart > daysRange && diffDaysEnd > daysRange)
				{
					$(this).addClass('hidden_by_date');
				}
				else
				{
					$(this).removeClass('hidden_by_date');
				}

				// FILTRO DE PIN /////////////////////////////////////////////////////
				// si esta seleccionado el pin
				if (pin_select == true) 
				{
					// si la task no esta pineada
					if (pin_status == false) 
					{
						$(this).addClass('hidden_by_pin');
					}

				}
				// si no esta seleccionado el pin
				else
				{
					// mostramos todas
					$(this).removeClass('hidden_by_pin');
				}

				// FILTRO DE ATRASADAS ////////////////////////////////////////////////////
				// atrasadas toggle button
				if (delayed_select == true) 
				{
					if (status != 'delayed') 
					{
						$(this).addClass('hidden_by_delayed');
					}

				}
				else
				{
					$(this).removeClass('hidden_by_delayed');
				}
				///////////////////////////////////////////////////////

				if (selected_colour == 0 || selected_colour == colour_id) 
				{
					$(this).removeClass('hidden_by_colour');
				}
				else
				{
					$(this).addClass('hidden_by_colour');
				}



			});

			//actualizamos los contadores
			updateCounters();
		}


		// Suscribimos los botones
		$('#date_select_filter').change(selectedModifier);
		$('#status_select_filter').change(selectedModifier);
		$('.toggle_button').click(function(){
			$(this).toggleClass('active');	
			selectedModifier();
		});
		$('.colour_option').click(function () {
			selected_colour = $(this).attr('id').split('_')[1];
			var bg_colour = $(this).css('background');
			$('#colour_filter').css('background', bg_colour);
			selectedModifier();
		})


		//por defecto que se muestre las actividades de esta semana (es el primero de las opciones y el metodo toma la opcion seleccionada)
		selectedModifier();
	};

	// metodo que actualiza el contador de las columnas

	$(document).ready(filter);
	$(document).on('page:load', filter);
});

// dejamos esta funcion fuera del scope para poder llamarla desde otros archivos. (kanban.js)
var updateCounters = function(){
	var inactive_resources_counter = 0
	var in_progress_resources_counter = 0
	var done_resources_counter = 0

	// inactivos
	$('#inactive_kanban_column').find('.kanban_item').filter(":visible").each(function(index, value){
		inactive_resources_counter += parseInt($(this).data('resources'));
	});

	// inactivos
	$('#in_progress_kanban_column').find('.kanban_item').filter(":visible").each(function(index, value){
		in_progress_resources_counter += parseInt($(this).data('resources'));
	});

	// inactivos
	$('#done_kanban_column').find('.kanban_item').filter(":visible").each(function(index, value){
		done_resources_counter += parseInt($(this).data('resources'));
	});



	$('#inactive_counter').html(inactive_resources_counter);
	$('#in_progress_counter').html(in_progress_resources_counter);
	$('#done_counter').html(done_resources_counter);
}
