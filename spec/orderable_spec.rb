require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Orderable" do

  before do
  end

  describe "without a scope" do
    before :all do
      @no_scope = Class.new(Sequel::Model(:sites)) do
        plugin :orderable
      end

      @no_scope.create :name => "hig.com", :position => 3
      @no_scope.create :name => "def.com", :position => 2
      @no_scope.create :name => "abc.com", :position => 1
    end

    it "should return rows in order of position" do
      @no_scope.map(&:position).should == [1,2,3]
      @no_scope.map(&:name).should == %w[ abc.com def.com hig.com ]
    end

  end

  describe "with a scope" do
    before :all do
      @scoped = Class.new(Sequel::Model(:pages)) do
        plugin :orderable, :field => :pos, :scope => :parent_id
      end

      @scoped.create :id => 5, :name => "Au", :pos => 3, :parent_id => 1
      @scoped.create :id => 4, :name => "P2", :pos => 2, :parent_id => 2
      @scoped.create :id => 3, :name => "P1", :pos => 1, :parent_id => 2
      @scoped.create :id => 2, :name => "Ps", :pos => 2, :parent_id => 1
      @scoped.create :id => 1, :name => "Hm", :pos => 1, :parent_id => nil
    end

    it "should return rows in order of position" do
#      @scoped.map(&:pos).should == [1,2,1,2,3]
      @scoped.map(&:name).should == %w[ Hm Ps P1 P2 Au ]
    end

  end
end

#
#class @c < Sequel::Model(:items)
#
#  set_schema do
#    primary_key :id
#    varchar :name
#    int :pos
#  end
#
#  is :orderable, :field => :pos
#
#end
#
#describe @c do
#  before(:all) {
#    @c.create_table!
#
#    @c.create :name => "one",   :pos => 3
#    @c.create :name => "two",   :pos => 2
#    @c.create :name => "three", :pos => 1
#  }
#
#
#  it "should define prev and next" do
#    i = @c[:name => "two"]
#    i.prev.should == @c[:name => "three"]
#    i.next.should == @c[:name => "one"]
#  end
#
#  it "should define move_to" do
#    @c[:name => "two"].move_to(1)
#    @c.map(&:name).should == %w[ two three one ]
#
#    @c[:name => "two"].move_to(3)
#    @c.map(&:name).should == %w[ three one two ]
#  end
#
#  it "should define move_to_top and move_to_bottom" do
#    @c[:name => "two"].move_to_top
#    @c.map(&:name).should == %w[ two three one ]
#
#    @c[:name => "two"].move_to_bottom
#    @c.map(&:name).should == %w[ three one two ]
#  end
#
#  it "should define move_up and move_down" do
#    @c[:name => "one"].move_up
#    @c.map(&:name).should == %w[ one three two ]
#
#    @c[:name => "three"].move_down
#    @c.map(&:name).should == %w[ one two three ]
#  end
#
#end
#
#class ListItem < Sequel::Model(:list_items)
#
#  set_schema do
#    primary_key :id
#    int :list_id
#    varchar :name
#    int :position
#  end
#
#  is :orderable, :scope => :list_id
#
#end
#
#describe ListItem do
#
#  before(:all) {
#    ListItem.create_table!
#
#    ListItem.create :name => "a", :list_id => 1, :position => 3
#    ListItem.create :name => "b", :list_id => 1, :position => 2
#    ListItem.create :name => "c", :list_id => 1, :position => 1
#
#    ListItem.create :name => "d", :list_id => 2, :position => 1
#    ListItem.create :name => "e", :list_id => 2, :position => 2
#    ListItem.create :name => "f", :list_id => 2, :position => 3
#  }
#
#  it "should print in order with scope provided" do
#    ListItem.map(&:name).should == %w[ c b a d e f ]
#  end
#
#  it "should fetch prev and next records with scope" do
#    b = ListItem[:name => "b"]
#    b.next.name.should == "a"
#    b.prev.name.should == "c"
#    b.next.next.should be_nil
#    b.prev.prev.should be_nil
#
#    e = ListItem[:name => "e"]
#    e.next.name.should == "f"
#    e.prev.name.should == "d"
#    e.next.next.should be_nil
#    e.prev.prev.should be_nil
#  end
#
#  it "should move only within the scope provided" do
#    ListItem[:name => "b"].move_to_top
#    ListItem.map(&:name).should == %w[ b c a d e f ]
#
#    ListItem[:name => "c"].move_to_bottom
#    ListItem.map(&:name).should == %w[ b a c d e f ]
#  end
#
#end