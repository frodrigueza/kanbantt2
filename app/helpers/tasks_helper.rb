module TasksHelper

  def real_image(real)
    if real < 8
      '0.png'
    elsif real < 20
      'r1.png'
    elsif real < 33
      'r2.png'
    elsif real < 46
      'r3.png'
    elsif real < 58
      'r4.png'
    elsif real < 71
      'r5.png'
    elsif real < 83
      'r6.png'
    elsif real < 96
      'r7.png'
    else
      'r8.png'
    end
  end

  def expected_image(expected)
    if expected < 8
      '0.png'
    elsif expected < 20
      'e1.png'
    elsif expected < 33
      'e2.png'
    elsif expected < 46
      'e3.png'
    elsif expected < 58
      'e4.png'
    elsif expected < 71
      'e5.png'
    elsif expected < 83
      'e6.png'
    elsif expected < 96
      'e7.png'
    else
      'e8.png'
    end
  end

  # entrga lo que falta de manera formateada, se ocupa en la vista del arbol
  def remaining_days(task)
    remaining_to_start = task.remaining_to_start
    remaining_to_end = task.remaining_to_end

    if task.progress == 100 #terminadas
      '<span class="glyphicon glyphicon-ok"></span>'.html_safe
    elsif remaining_to_start >= 0
      case remaining_to_start
        when 0
          'Comienza hoy'
        when 1
          'Comienza mañana'
        else
          'Comienza en ' + remaining_to_start.to_s + ' días'
      end
    elsif remaining_to_end >= 0 #en progreso
      case remaining_to_end
        when 0
          'Finaliza hoy'
        when 1
          'Finaliza mañana'
        else
          'Finaliza en ' + remaining_to_end.to_s + ' días'
      end
    elsif remaining_to_end < 0 # atrasadas
      case remaining_to_end
        when -1
          'Atrasada 1 día'
        else
          'Atrasada ' + (remaining_to_end * -1 ).to_s + ' días'
      end
    end
  end

  def css_task_status_color(task)
    if task.delayed
      'bad'
    else
      'great'
    end
  end

  def urgent_task_title(task)
    if task.urgent
      'Tarea marcada como urgente'
    else
      'Marcar esta tarea como urgente'
    end
  end

  def urgent_task_class(task)
    if task.urgent
      'active'
    else
      ''
    end
  end

  def user_assigned_task_title(task)
    'Tarea asignada a ' + task.user.f_name
  end

  def user_commited_tak_title(task)
    task.user.f_name + ' se ha comprometido a realizar esta tarea'
  end

  






end
