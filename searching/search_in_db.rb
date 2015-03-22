require 'sequel'
require_relative './person'

class TmpDb
  attr_accessor :db
  def initialize persons_arr
    @db = Sequel.sqlite # in-memory db

    @db.create_table :people do
      primary_key :id
      Integer     :sex # TrueClass
      Integer     :age
      Integer     :height
      Integer     :index
      Float       :balance
      # index :height
      # index [:sex, :age, :height, :index, :balance]
    end

    arr_to_db persons_arr
    # @db[:people].multi_insert persons_arr.map(&:attrs)
  end

  def people
    @db[:people]
  end

  private

  # 1_000_000
  # @utime=32.06999999999999>
  def arr_to_db arr
    people.multi_insert arr.map(&:attrs)
  end

  # doesnt work in parallel!?
  # def arr_to_db_mt arr, num_threads = 4
  #   threads = []
  #   arr = arr.each_slice(arr.size/num_threads).to_a

  #   arr.each_with_index do |slice, i|
  #     threads << Thread.new(slice, i) do |slice, i|
  #       DB[:people].multi_insert slice.map(&:attrs)
  #     end
  #   end

  #   threads.each { |thr| thr.join }
  # end

  # require 'parallel'
  # def arr_to_db_pll arr
  #   Parallel.each(arr, in_processes: 2) do |el|
  #     DB[:persons].insert el.attrs
  #   end
  # end
end
