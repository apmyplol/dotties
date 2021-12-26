function print_table(inp)
    for k,v in pairs(inp) do
      print(k)
      print(v)
    end
end


function split_str(delim, input)
  temp = {}
  for word in input:gmatch(delim) do table.insert(temp, word) end
  return temp
end