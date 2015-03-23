require 'sequel'
require_relative './person'

class TmpDb
  attr_accessor :db
  def initialize persons_arr
    @db = Sequel.sqlite # in-memory db

    @db.create_table :people do
      primary_key :id
      Integer     :sex
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

  # require 'parallel'
  # def arr_to_db_pll arr
  #   Parallel.each(arr, in_processes: 2) do |el|
  #     DB[:persons].insert el.attrs
  #   end
  # end
end
