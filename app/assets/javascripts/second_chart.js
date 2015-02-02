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
                            var date = Date.parse(data[i]['date']);
                            var progress = parseInt(data[i]['expected_days_progress']);

                            var value = [date, progress];
                            EDP.push(value);
                            // console.log(value);
                        });
                    // console.log(EDP);
                    }

                    // REALES EN DIAS
                    var RDP = [];
                    if ($('#days_chart'))
                    {
                        $.each(data, function(i, item){
                            var date = Date.parse(data[i]['date']);
                            var progress = parseInt(data[i]['real_days_progress']);

                            if (!isNaN(progress)) 
                            {
                                var value = [date, progress];
                                RDP.push(value);
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
                                type: 'datetime'
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
                                    name: 'Esperado',
                                    pointInterval: 24 * 3600 * 1000 * 7,
                                    data: EDP
                                },

                                {
                                    name: 'Real',
                                    pointInterval: 24 * 3600 * 1000 * 7,
                                    data: RDP
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