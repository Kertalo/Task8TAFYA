def open_file(file_name) #открываем файл и заносим таблицу переходов в Hash "table"
  table = { alphabet: [], states: [], final_states: [], columns: [] }
  i = 0
  File.readlines(file_name).each do |line|
    line.gsub!(/\s+/, '')
    if i == 0
      line = line[1,line.length]
      table[:alphabet] = line.split("|")
    else
      column1 = line.split("|")[0]
      is_first = false
      if column1[0, 2] == "->"
        is_first = true
        column1.delete!("->")
      end
      if column1[0] == '(' and column1[-1] == ')'
        column1.delete!("(")
        column1.delete!(")")
        if !is_first
          table[:final_states].push(column1)
        else
          table[:final_states].unshift(column1)
        end
      end
      if !is_first
        table[:states].push(column1)
      else
        table[:states].unshift(column1)
      end
      columns = line.split("|")
      columns = columns[1, columns.size]

      if !is_first
        table[:columns].push(columns)
      else
        table[:columns].unshift(columns)
      end
    end
    i += 1
  end
  table
end

def sort(table, str) #сортировка нового состояния (пример: С,B,A -> ABC)
  if str == nil
    return "-"
  end
  str.squeeze
  res = ""
  table[:states].each do |state|
    if str.include? state
      res += state
    end
  end
  if res == ""
    res = "-"
  end
  res
end

def determinization(table) #детерминизация
  new_table = { alphabet: table[:alphabet], states: [table[:states][0]], final_states: [], columns: [] }
  new_table[:states].each do |new_state|
    table[:final_states].each do |f|
      if new_state.include? f
        new_table[:final_states].push new_state
        break
      end
    end
    new_table[:columns].push(Array.new(new_table[:alphabet].size, ""))
    while new_state != "" and new_state != nil
      if (i = table[:states].index new_state[0])
        new_table[:alphabet].each_with_index do |a, j|
          new_table[:columns][-1][j] += table[:columns][i][j]
        end
      end
      new_state = new_state[1, new_state.size]
    end
    new_table[:columns][-1].each_with_index do |c, j|
      new_table[:columns][-1][j] = sort(table, c)
      if (!(new_table[:states].include? new_table[:columns][-1][j]) and (new_table[:columns][-1][j] != "-"))
        new_table[:states].push new_table[:columns][-1][j]
      end
    end
  end
  new_table
end

def create_file(file_name, table) #создаем файл и заносим в него таблицу "table"
  length = 0
  table[:states].each do |s|
    if table[:final_states].include? s
      now_length = s.size + 2
    else
      now_length = s.size
    end
    if now_length > length
      length = now_length
    end
  end

  out_file = File.new(file_name, "w")

  out_file.print(" " * (length + 2))
  table[:alphabet].each do |a|
    out_file.print("|" + a + " " * (length - a.size))
  end

  out_file.puts ""
  out_file.print("->")

  table[:states].each_with_index do |s, i|
    if i != 0
      out_file.print "  "
    end
    if table[:final_states].include? s
      out_file.print("(" + s + ")" + " " * (length - s.size - 2))
    else
      out_file.print(s + " " * (length - s.size))
    end

    table[:columns][i].each do |c|
      out_file.print("|" + c + " " * (length - c.size))
    end
    out_file.puts ""
  end

  out_file.close
end

table = open_file('table_ND.txt')
new_table = determinization(table)
create_file('table_D.txt', new_table)
