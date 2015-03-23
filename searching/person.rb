class Person
  ATTRS = %i(sex age height index balance)

  MAX_SEX    = 1
  MAX_AGE    = 100
  MAX_HEIGHT = 300
  MAX_INDEX  = 1_000_000
  MAX_ACC    = 1_000_000.0 # balance

  DEFAULT_SEX    = [*0..MAX_SEX]
  DEFAULT_AGE    = [*0..MAX_AGE]
  DEFAULT_HEIGHT = [*0..MAX_HEIGHT]
  DEFAULT_INDEX  = [1, MAX_INDEX]
  DEFAULT_ACC    = [0, MAX_ACC]

  attr_accessor *ATTRS

  def initialize params = {}
    ATTRS.each { |atr| instance_variable_set :"@#{atr}", params[atr] }
  end

  # => [] of Person objects
  def self.seed n = 1_000
    (1..n).inject([]) { |seeds, _| seeds << new(seed_attrs) }
  end

  # => {}
  def self.seed_attrs
    ATTRS.inject({}) do |res, atr|
      res.merge! atr => send(:"seed_#{atr}")
    end
  end

  def to_h
    hash = {}
    instance_variables.each do |var|
      hash[var.to_s.delete('@').to_sym] = instance_variable_get var
    end
    hash
  end

  alias_method :attrs, :to_h
  alias_method :to_hash, :attrs

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
