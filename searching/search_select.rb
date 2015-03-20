require_relative './person'
require_relative './helpers'

def arr_select objects, query
  query = normalize_query query

  objects.select do |o|
    (query[:sex].empty?     || query[:sex].include?(o.sex)) &&
    (query[:age].empty?     || query[:age].include?(o.age)) &&
    (query[:height].empty?  || query[:height].include?(o.height)) &&
    # (query[:index].empty?   || query[:index].include?(o.index)) &&
    # (query[:balance].empty? || query[:balance].include?(o.balance))
    (query[:index].empty?   || o.index.between?(*query[:index])) &&
    (query[:balance].empty? || o.balance.between?(*query[:balance]))
  end
end
