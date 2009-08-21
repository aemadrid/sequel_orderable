require 'spec'
require 'sequel'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'orderable'

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

DB.create_table :pages do
  int :id
  varchar :name
  int :pos
  int :parent_id
end


