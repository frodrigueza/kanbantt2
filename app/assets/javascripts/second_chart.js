var initiate_charts = function(){
    // Solo haremos el llamado cuando estemos en la vista de los indicadores
    if ($('#indicators').size() > 0) 
    {
        // obtenemos el id del project
        var path_array = window.location.pathname.split('/');
        var project_id = path_array[$.inArray("projects", path_array) + 1]

        $.ajax({
            url: '/api/projects/' + project_id + '/indicators',
            dataType: 'json',
            success: function(data){

                // ESPERADOS EN DIAS
                var EDP = [];
                if ($('#days_chart'))
                {
                    $.each(data, function(i, item){
                        var date = Date.parse(data[i]['date']).getTime();
                        var progress = parseInt(data[i]['expected_days_progress']);

                        var value = [date, progress];
                        EDP.push(value);
                        // console.log(value);
                    });
                }

                // REALES EN DIAS
                var RDP = [];
                if ($('#days_chart'))
                {
                    $.each(data, function(i, item){
                        var date = Date.parse(data[i]['date']).getTime();
                        var progress = parseInt(data[i]['real_days_progress']);

                        if (!isNaN(progress)) 
                        {
                            var value = [date, progress];
                            RDP.push(value);
                            console.log(value);
                        }
                    });
                }

                // ESPERADOS EN RECURSOS
                var ERP = [];
                if ($('#resources_chart'))
                {
                    $.each(data, function(i, item){
                        var date = Date.parse(data[i]['date']).getTime();
                        console.log(date);
                        var progress = parseInt(data[i]['expected_resources_progress']);

                        var value = [date, progress];
                        ERP.push(value);
                        // console.log(value);
                    });
                }

                // REALES EN RECURSOS
                var RRP = [];
                if ($('#resources_chart'))
                {
                    $.each(data, function(i, item){
                        var date = Date.parse(data[i]['date']).getTime();
                        var progress = parseInt(data[i]['real_resources_progress']);

                        if (!isNaN(progress)) 
                        {
                            var value = [date, progress];
                            RRP.push(value);
                            console.log(value);
                        }
                    });
                }

                // Configuramos el grafico de tiempo
                if ($('#days_chart')) 
                {
                    $('#days_chart').highcharts({
                        chart:{
                            zoomType: 'x',
                        },
                        title: {
                            text: 'Progreso en días',
                            x: -20 //center
                        },
                        xAxis: {
                            type: 'datetime',
                            ordinal: false
                        },
                        yAxis: {
                            title: {
                                text: 'Progreso (%)'
                            },
                            min: 0,
                            max: 100
                        },
                        tooltip: {
                            valueSuffix: '%'
                        },
                        legend: {
                            layout: 'vertical',
                            align: 'right',
                            verticalAlign: 'middle',
                            borderWidth: 0
                        },
                        series: 
                        [
                            {
                                name: 'Esperado en días',
                                data: EDP
                            },

                            {
                                name: 'Real en días',
                                data: RDP
                            }
                        ]
                    });
                    
                }

                // Configuramos el grafico de recursos
                if ($('#resources_chart')) 
                {
                    $('#resources_chart').highcharts({
                        chart:{
                            zoomType: 'x',
                        },
                        title: {
                            text: 'Progreso segun recursos',
                            x: -20 //center
                        },
                        xAxis: {
                            type: 'datetime',
                            ordinal: false
                        },
                        yAxis: {
                            title: {
                                text: 'Progreso (%)'
                            },
                            min: 0,
                            max: 100
                        },
                        tooltip: {
                            valueSuffix: '%'
                        },
                        legend: {
                            layout: 'vertical',
                            align: 'right',
                            verticalAlign: 'middle',
                            borderWidth: 0
                        },
                        series: 
                        [
                            {
                                name: 'Esperado en recursos',
                                data: ERP
                            },

                            {
                                name: 'Real en recursos',
                                data: RRP
                            }
                        ]
                    });
                    
                }
            }

        });
    }
}

$(document).ready(initiate_charts);
$(document).on('page:load', initiate_charts);