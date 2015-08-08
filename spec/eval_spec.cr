require "./spec_helper"

describe Lua::State do
  describe "#[]" do
    it "returns nil for an unknown value/binding" do
      s = Lua::State.new
      s["unknown"].should be_nil
      s.close
    end
  end

  describe "#eval" do
    it "evals true" do
      s = Lua::State.new
      s.eval("a = true")
      s["a"].should be_true
      s.close
    end

    it "evals false" do
      s = Lua::State.new
      s.eval("a = false")
      s["a"].should be_false
      s.close
    end

    it "evals strings" do
      s = Lua::State.new
      s.eval("a = \"black adder\"")
      s["a"].should eq("black adder")
      s.close
    end

    it "evals additions" do
      s = Lua::State.new
      s.eval("a = 1 + 1")
      s["a"].should eq(2.0)
      s.close
    end

    it "evals nested lookups" do
      s = Lua::State.new
      s.eval("a = { b = { c = 0 } }")
      s.eval("_ = a.b.c")
      s["_"].should eq(0.0)
      s.close
    end

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

    it "returns false" do
      s = Lua::State.new
      s.eval("return false").should be_false
      s.close
    end

    it "returns true" do
      s = Lua::State.new
      s.eval("return true").should be_true
      s.close
    end

    it "returns tables" do
      s = Lua::State.new
      r = s.eval(%[return { "hello", "world", 2 }]) as Lua::Table

      r.class.should eq(Lua::Table)
      r[0].should be_nil
      r[1].should eq("hello")
      r[2].should eq("world")
      r[3].should eq(2.0)

      s.close
    end

    it "accepts a filename and a lineno optional arguments" do
      le :: Lua::LuaError

      s = Lua::State.new

      begin
        s.eval("error(77)", nil, "/nada/virtual.lua", 63)
      rescue e : Lua::LuaError
        le = e
      end

      le.kind.should eq("eval:pcall")
      le.msg.should eq("[string \"/nada/virtual.lua:63\"]:1: 77")
      le.errcode.should eq(2)

      le.filename.should eq("/nada/virtual.lua")
      le.lineno.should eq(63)

      s.close
    end
  end
end
