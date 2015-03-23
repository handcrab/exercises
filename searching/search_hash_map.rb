require_relative './person'
require_relative './helpers'

# @map=
# {0=> # sex
#  {28=> # age
#    height: [ids]
#    {180=>[0, 86769, 287429, 422905, 431340, 487507],
#     103=>[305, 152861, 194403, 243172, 340850, 401044, 411235],
#     178=>[452, 103602, 108272, 328706, 361397, 361643, 483292],

class HashMap
  attr_accessor :map

  include PersonQuery

  # TODO: build map of given structure
  # structure = [:sex, :age, :height]
  def initialize objects
    @map     = build_map_of objects
    @objects = objects
  end

  def find query = {}
    skip_index_filter = !query[:index]
    skip_balance_filter = !query[:balance]

    query = normalize_query query
    objs = locate_objects query

    return objs if skip_balance_filter && skip_index_filter
    objs.select { |o| obj_index_and_balance_between? o, query }
  end

  private

  # search within map
  # TODO: refactor
  def locate_objects query
    return @objects if query[:sex].empty? && query[:age].empty? && query[:height].empty?

    res = []
    found_sex_keys = find_keys @map.keys, query[:sex]
    found_sex_keys.each do |sk|
      found_age_keys = find_keys @map[sk].keys, query[:age]
      found_age_keys.each do |ak|
        found_height_keys = find_keys @map[sk][ak].keys, query[:height]
        found_height_keys.each do |hk|
          res << @map[sk][ak][hk]
        end # hk
      end # ak
    end # sk

    res = res.flatten
    return [] if res.empty?
    objects_by_ids res
  end

  def objects_by_ids ids
    # @objects.values_at(*ids) # <== SystemStackError: stack level too deep
    ids.inject([]) { |res, i| res << @objects[i] }
  end

  def build_map_of objs
    map = {}
    objs.each_with_index do |o, i|
      map[o.sex] ||= {}
      map[o.sex][o.age] ||= {}
      map[o.sex][o.age][o.height] ||= []

      map[o.sex][o.age][o.height] << i
    end
    map
  end

  def find_keys src, query
    return src if query.empty?
    src & query
  end
end
