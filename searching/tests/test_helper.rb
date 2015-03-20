require 'sequel'

require '../person'
require '../search_select'
require '../search_in_db'
require '../search_hash_map'

# load data
$db = Sequel.sqlite './persons.db'
# persons = Person.seed 10_000
$persons = $db[:persons].all.map { |attrs| Person.new attrs }
$db.disconnect
$db = nil

def query_test result, query
  { query: query, result: result }
end

$queries = []
$queries << query_test(4967, sex: 0)
$queries << query_test(2062, age: 20..40)
$queries << query_test(7, age: 20..40, height: 180)
$queries << query_test(18, height: [180, 170, 175], age: 20..40)
$queries << query_test(1, sex: 1, age: 25, height: 170..180)
$queries << query_test(35, sex: 0, age: 20..30, height: 150..170)
# err with non-eclusive ranges (...) on balance
$queries << query_test(1, sex: 0, age: 20..30, height: 150..170, index: 10_000..50_000)
$queries << query_test(536, age: 20..30, balance: 500_000.0..1_000_000.0)
$queries << query_test(11, sex: 0, age: 20..35, height: 150..180, index: 10_000..500_000, balance: 500_000.0..1_000_000.0)
$queries << query_test(0, index: 10000)
