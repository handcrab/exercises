require_relative './person'

module PersonQuery
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
    default_query = Person::ATTRS.inject({}) { |res, atr| res.merge atr => [] }

    # convert values to arrays
    query.each do |k, v|
      next if k == :balance || k == :index
      query[k] = [].push(v.respond_to?(:to_a) ? v.to_a : v).flatten
    end

    query[:balance] = extremums query[:balance], Person::MAX_ACC
    query[:index]   = extremums query[:index], Person::MAX_INDEX
    default_query.merge query
  end

  # => [min, max]
  def extremums obj, maximum
    min = obj.respond_to?(:min) ? obj.min : obj
    max = obj.respond_to?(:max) ? obj.max : obj
    [min || 0, max || maximum]
  end

  def obj_attr_include? obj, query, atr_key
    query[atr_key].empty? || query[atr_key].include?(obj.send atr_key)
  end

  def obj_attr_between? obj, query, atr_key
    query[atr_key].empty? || obj.send(atr_key).between?(*query[atr_key])
  end

  def obj_index_and_balance_between? obj, query
    obj.index.between?(*query[:index]) &&
    obj.balance.between?(*query[:balance])
  end

  module_function :obj_attr_between?, :obj_attr_include?, :normalize_query,
                  :obj_index_and_balance_between?, :extremums
end
