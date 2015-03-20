require './test_helper'
require 'benchmark'

$persons = Person.seed 1_000_000

puts 'One query'.center(40)
#        user     system      total        real
# select:  1.640000   0.000000   1.640000 (  1.638540)
# in db:  30.520000   0.270000  30.790000 ( 30.809591)
# map:     3.070000   0.010000   3.080000 (  3.081607)
Benchmark.bm do |x|
  x.report("select:") do
    q = $queries[-2]
    arr_select $persons, q[:query]
  end

  x.report("in db: ") do
    q = $queries[-2]
    people = TmpDb.new($persons)
    people = people.db[:people]

    people.where(q[:query]).all
  end

  x.report("map:   ") do
    q = $queries[-2]
    m = HashMap.new $persons
    m.find q[:query]
  end
end

puts 'All test queries'.center(40)
#        user     system      total        real
# select: 16.410000   0.020000  16.430000 ( 16.449052)
# in db:  34.620000   0.080000  34.700000 ( 34.741636)
# map:     4.270000   0.020000   4.290000 (  4.300002)
Benchmark.bm do |x|
  x.report("select:") do
    $queries.each do |q|
      arr_select $persons, q[:query]
    end
  end

  x.report("in db: ") do
    people = TmpDb.new($persons)
    people = people.db[:people]

    $queries.each do |q|
      people.where(q[:query]).all
    end
  end

  x.report("map:   ") do
    m = HashMap.new $persons
    $queries.each do |q|
      m.find q[:query]
    end
  end
end

puts 'Larger amount of queries'.center(40)
#         Larger amount of queries        
#        user     system      total        real
# select:169.050000   0.390000 169.440000 (169.575351)
# in db:  72.440000   0.160000  72.600000 ( 72.678391)
# map:    24.750000   0.150000  24.900000 ( 24.930474)

Benchmark.bm do |x|
  x.report("select:") do
    10.times do
      $queries.each do |q|
        arr_select $persons, q[:query]
      end
    end
  end

  x.report("in db: ") do
    people = TmpDb.new($persons)
    people = people.db[:people]

    10.times do
      $queries.each do |q|
        people.where(q[:query]).all
      end
    end
  end

  x.report("map:   ") do
    m = HashMap.new $persons
    10.times do
      $queries.each do |q|
        m.find q[:query]
      end
    end
  end
end

