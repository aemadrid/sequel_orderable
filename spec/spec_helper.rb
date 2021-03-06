require 'spec'
require 'sequel'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))

require 'sequel_orderable'

Spec::Runner.configure do |config|  
end

class Symbol
  def to_proc() lambda{ |object, *args| object.send(self, *args) } end
end

DB = Sequel.connect ENV['SEQUEL_ORDERABLE_CONN'] || 'sqlite:/'

DB.create_table :sites do
  primary_key :id
  varchar :name
  int :position
end

DB.create_table :sites_naughty do
  primary_key :id
  varchar :name
  int :order
end

DB.create_table :pages do
  primary_key :id
  varchar :name
  int :pos
  int :parent_id
end


