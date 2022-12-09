def sort(table, str)
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

def open_file(file_name)
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

def determinization(table)
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

def create_file(file_name)
  nil
end

table = open_file('table_ND.txt')
puts table
puts determinization(table)
