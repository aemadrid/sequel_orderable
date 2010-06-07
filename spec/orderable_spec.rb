require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Orderable" do

  before do
  end

  describe "with SQL keyword for order field" do
    before :all do
      @c = Class.new(Sequel::Model(:sites_naughty)) do
        plugin :orderable, :field => :order
      end
    end

    before :each do
      @c.delete
      @c.create :name => "hig", :order => 3
      @c.create :name => "def", :order => 2
      @c.create :name => "abc", :order => 1
    end

    it "should work" do
      @c[:name => "def"].move_to(1)
      @c.map(&:name).should == %w[  def abc hig  ]
    end
  end

  describe "without a scope" do
    before :all do
      @c = Class.new(Sequel::Model(:sites)) do
        plugin :orderable
      end
    end

    before :each do
      @c.delete
      @c.create :name => "hig", :position => 3
      @c.create :name => "def", :position => 2
      @c.create :name => "abc", :position => 1
    end

    it "should return rows in order of position" do
      @c.map(&:position).should == [1, 2, 3]
      @c.map(&:name).should == %w[  abc def hig  ]
    end

    it "should define prev and next" do
      i = @c[:name => "abc"]
      i.prev.should == nil
      i = @c[:name => "def"]
      i.prev.should == @c[:name => "abc"]
      i.next.should == @c[:name => "hig"]
      i = @c[:name => "hig"]
      i.next.should == nil
    end

    it "should define move_to" do
      @c[:name => "def"].move_to(1)
      @c.map(&:name).should == %w[  def abc hig  ]

      @c[:name => "abc"].move_to(3)
      @c.map(&:name).should == %w[  def hig abc  ]

      proc { @c[:name => "abc"].move_to(-1) }.should raise_error(RuntimeError)
      proc { @c[:name => "abc"].move_to(10) }.should raise_error(RuntimeError)
    end

    it "should define move_to_top and move_to_bottom" do
      @c[:name => "def"].move_to_top
      @c.map(&:name).should == %w[  def abc hig  ]

      @c[:name => "def"].move_to_bottom
      @c.map(&:name).should == %w[  abc hig def  ]
    end

    it "should define move_up and move_down" do
      @c[:name => "def"].move_up
      @c.map(&:name).should == %w[  def abc hig  ]

      @c[:name => "abc"].move_down
      @c.map(&:name).should == %w[  def hig abc  ]

      proc { @c[:name => "def"].move_up(10) }.should raise_error(RuntimeError)
      proc { @c[:name => "def"].move_down(10) }.should raise_error(RuntimeError)
    end

  end

  describe "with a scope" do
    before :all do
      @c = Class.new(Sequel::Model(:pages)) do
        plugin :orderable, :field => :pos, :scope => :parent_id
      end
    end

    before :each do
      @c.delete
      p1 = @c.create :name => "Hm", :pos => 1, :parent_id => nil
      p2 = @c.create :name => "Ps", :pos => 1, :parent_id => p1.id
      @c.create :name => "P1", :pos => 1, :parent_id => p2.id
      @c.create :name => "P2", :pos => 2, :parent_id => p2.id
      @c.create :name => "P3", :pos => 3, :parent_id => p2.id
      @c.create :name => "Au", :pos => 2, :parent_id => p1.id
    end

    it "should return rows in order of position" do
      @c.map(&:name).should == %w[  Hm Ps Au P1 P2 P3  ]
    end

    it "should define prev and next" do
      @c[:name => "Ps"].next.name.should == 'Au'
      @c[:name => "Au"].prev.name.should == 'Ps'
      @c[:name => "P1"].next.name.should == 'P2'
      @c[:name => "P2"].prev.name.should == 'P1'

      @c[:name => "Ps"].prev.should == nil
      @c[:name => "Au"].next.should == nil
      @c[:name => "P1"].prev.should == nil
      @c[:name => "P3"].next.should == nil
    end

    it "should define move_to" do
      @c[:name => "P2"].move_to(1)
      @c.map(&:name).should == %w[  Hm Ps Au P2 P1 P3  ]

      @c[:name => "P2"].move_to(3)
      @c.map(&:name).should == %w[  Hm Ps Au P1 P3 P2  ]

      proc { @c[:name => "P2"].move_to(-1) }.should raise_error(RuntimeError)
      proc { @c[:name => "P2"].move_to(10) }.should raise_error(RuntimeError)
    end

    it "should define move_to_top and move_to_bottom" do
      @c[:name => "Au"].move_to_top
      @c.map(&:name).should == %w[  Hm Au Ps P1 P2 P3  ]

      @c[:name => "Au"].move_to_bottom
      @c.map(&:name).should == %w[  Hm Ps Au P1 P2 P3  ]
    end

    it "should define move_up and move_down" do
      @c[:name => "P2"].move_up
      @c.map(&:name).should == %w[  Hm Ps Au P2 P1 P3  ]

      @c[:name => "P1"].move_down
      @c.map(&:name).should == %w[  Hm Ps Au P2 P3 P1  ]

      proc { @c[:name => "P1"].move_up(10) }.should raise_error(RuntimeError)
      proc { @c[:name => "P1"].move_down(10) }.should raise_error(RuntimeError)
    end

  end
end
