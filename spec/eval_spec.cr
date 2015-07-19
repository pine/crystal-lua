require "./spec_helper"

describe Lua::State do
  describe "#eval" do
    it "return numbers" do
      s = Lua::State.new
      s.eval("return 7").should eq(7.0)
      s.eval("return 8").should_not eq(7.0)
      s.close
    end

    it "returns multiple values" do
      s = Lua::State.new
      s.eval("return 1, 2").should eq [ 1.0, 2.0 ]
      s.close
    end

    it "returns multiple values (tables included)" do
      s = Lua::State.new
      r = s.eval("return 1, 2, {}") as Array

      r.should be_a Array
      r[0, 2].should eq [ 1.0, 2.0 ]
      r[2].should be_a Lua::Table
      (r[2] as Lua::Table).size.should eq(0)

      s.close
    end
  end
end
