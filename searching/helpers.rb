require_relative './person'
# query = hash
# => hash of arrays
# { age: 20..22 }   => { age: [20, 21, 22] }
# { age: 25 }       => { age: [25] }
# { age: [20, 40] } => { age: [20, 40] }
# { balance: 100.0..300.0 } => { balance: [100.0, 300.0] }
# { balance: 100.0 } => { balance: [100.0, 100.0] }
# { balance: [] } => { balance: [0, Person::MAX_ACC ]}
# same with index
def normalize_query query
  default_query = { sex: [], age: [], height: [], index: [], balance: [] }

  # convert values to arrays
  query.each do |k, v|
    next if k == :balance || k == :index
    query[k] = [].push(v.respond_to?(:to_a) ? v.to_a : v).flatten
  end

  query[:balance] = extremums query[:balance], Person::MAX_ACC
  query[:index] = extremums query[:index], Person::MAX_INDEX
  default_query.merge query
end

# => [min, max]
def extremums obj, maximum
  min = obj.respond_to?(:min) ? obj.min : obj
  max = obj.respond_to?(:max) ? obj.max : obj
  [min || 0, max || maximum]
end
