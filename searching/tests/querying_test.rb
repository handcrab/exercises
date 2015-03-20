require './test_helper'
require 'minitest/autorun'

describe 'Array select' do
  it 'selects correct data' do
    $queries.each do |q|
      arr_select($persons, q[:query]).size.must_equal q[:result]
    end
  end
end

describe 'DB select' do
  it 'selects correct data' do
    people = TmpDb.new($persons)
    people = people.db[:people]

    $queries.each do |q|
      people.where(q[:query]).count.must_equal q[:result]
    end
  end
end

describe 'Hash select' do
  it 'selects correct data' do
    m = HashMap.new $persons
    $queries.each do |q|
      m.find(q[:query]).size.must_equal q[:result]
    end
  end
end
