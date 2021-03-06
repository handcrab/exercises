require 'ohm'
require_relative './person'
require_relative './helpers'
# redis = Redis.new

class PersonInRedis < Ohm::Model
  extend PersonQuery

  attribute :sex,     ->(x) { x.to_i }
  attribute :age,     ->(x) { x.to_i }
  attribute :height,  ->(x) { x.to_i }
  attribute :index,   ->(x) { x.to_i }
  attribute :balance, ->(x) { x.to_f }

  index :sex
  index :age
  index :height
  index :index
  index :balance

  class << self
    # TODO: super slow. multi insert
    def load persons
      # persons.map(&:attrs).map &:save
      persons.each { |person| create person.attrs }
    end

    # def self.dump_mt persons, num_threads = 4
    #   threads = []
    #   arr = persons.each_slice(persons.size/num_threads).to_a

    #   arr.each_with_index do |slice, i|
    #     threads << Thread.new(slice, i) do |slice, i|
    #       slice.each { |person| PersonInRedis.create person.attrs }
    #     end
    #   end

    #   threads.each { |thr| thr.join }
    # end

    def cleanup
      redis.call "FLUSHDB"
    end

    def with data
      load data
      yield self
      cleanup
    end

    def normalize_query query
      query = super
      query[:sex] = query[:sex].empty? ? Person::DEFAULT_SEX : query[:sex]
      query[:age] = query[:age].empty? ? Person::DEFAULT_AGE : query[:age]
      query[:height] = query[:height].empty? ? Person::DEFAULT_HEIGHT : query[:height]
      query
    end

    # TODO: refactor
    def search query
      query = normalize_query query

      persons = all.combine(sex: query[:sex])
                   .combine(age: query[:age])
                   .combine(height: query[:height])

      skip_index, skip_balance = false, false
      if query[:index].one?
        persons  = persons.find index: query[:index]
        skip_index = true
      end
      if query[:balance].one?
        persons  = persons.find balance: query[:balance]
        skip_balance = true
      end

      return persons if (skip_balance && skip_index) || (query[:balance] == Person::DEFAULT_ACC && query[:index] == Person::DEFAULT_INDEX)
      persons.to_a.select { |person| obj_index_and_balance_between? person, query }
    end
  end
end

