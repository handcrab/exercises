class Person
  MAX_SEX    = 1
  MAX_AGE    = 100
  MAX_HEIGHT = 300
  MAX_INDEX  = 1_000_000
  MAX_ACC    = 1_000_000.0 # balance

  attr_accessor :sex, :age, :height, :index, :balance

  def initialize params = {}
    @sex     = params[:sex]
    @age     = params[:age]
    @height  = params[:height]
    @index   = params[:index]
    @balance = params[:balance]
  end

  # => [] of Person objects
  def self.seed n = 1_000
    seed_arr = []
    n.times do
      person = new sex: seed_sex,
                   age: seed_age,
                   height: seed_height,
                   index: seed_index,
                   balance: seed_balance
      seed_arr << person
    end
    seed_arr
  end

  def attrs
    { sex: @sex, age: @age, height: @height, index: @index, balance: @balance }
  end

  alias_method :values, :attrs
  alias_method :to_hash, :attrs

  def to_h
    hash = {}
    instance_variables.each do |var|
      hash[var.to_s.delete('@').to_sym] = instance_variable_get(var)
    end
    hash
  end

  def self.random max
    rand max + 1
  end

  def self.seed_sex
    random MAX_SEX
  end

  def self.seed_age
    random MAX_AGE
  end

  def self.seed_height
    random MAX_HEIGHT
  end

  def self.seed_index
    random MAX_INDEX
  end

  def self.seed_balance
    rand 0..MAX_ACC
  end
end
