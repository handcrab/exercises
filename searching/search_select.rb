require_relative './person'
require_relative './helpers'

def arr_select objects, query
  query = PersonQuery.normalize_query query

  objects.select do |obj|
    (PersonQuery.obj_attr_include? obj, query, :sex) &&
    (PersonQuery.obj_attr_include? obj, query, :age) &&
    (PersonQuery.obj_attr_include? obj, query, :height) &&
    (PersonQuery.obj_attr_between? obj, query, :index) &&
    (PersonQuery.obj_attr_between? obj, query, :balance)
  end
end
