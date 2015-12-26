def json_diff(new, old, array_is_set = false, path = '')
  case [new.class, old.class]
  when [Hash, Hash]
    a = (new.keys - old.keys).map{ |k| { type: '+', path: "#{path}.#{k}", value: new[k] } }
    d = (old.keys - new.keys).map{ |k| { type: '-', path: "#{path}.#{k}", value: old[k] } }
    ks = new.keys & old.keys
    c = ks.map{ |k| json_diff(new[k], old[k], array_is_set, "#{path}.#{k}") }
    return [a, d, c].flatten.compact
  when [Array, Array]
    if array_is_set
      a = new.each_with_index.select{ |e, i| not old.include?(e) }
          .map{ |e, i| { type: '+', path: "#{path}[#{i}]", value: e } }
      d = old.each_with_index.select{ |e, i| not new.include?(e) }
          .map{ |e, i| { type: '-', path: "#{path}[#{i}]", value: e } }
      return [a, d].flatten
    else
      a = (old.size ... new.size).map{ |i| { type: '+', path: "#{path}[#{i}]", value: new[i] } }
      d = (new.size ... old.size).map{ |i| { type: '-', path: "#{path}[#{i}]", value: old[i] } }
      n = [new.size, old.size].min - 1
      c = 0.upto(n).map{ |i| json_diff(new[i], old[i], array_is_set, "#{path}[#{i}]") }
      return [a, d, c].flatten.compact
    end
  else
    if new != old
      { type: '~', path: path, value: [new, old] }
    end
  end
end

