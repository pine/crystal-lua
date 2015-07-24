#--
# Copyright (c) 2009-2014, John Mettraux, Alain Hoang.
# Copyright (c) 2015 Pine Mizune.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

module Lua

  class State
    include StateMixin

    def initialize(include_libs = true)
      @pointer = LibLua51.luaL_newstate
      @error_handler = 0
      @closed = false
      open_libraries(include_libs)
    end

    # Evaluates a piece (string) of Lua code within the state.
    #
    def eval(s, bndng=nil, filename=nil, lineno=nil)
      loadstring_and_call(s, bndng, filename, lineno)
    end

    # Returns a value set at the 'global' level in the state.
    #
    #   state.eval('a = 1 + 2')
    #   puts state['a'] # => "3.0"
    #
    def [](k)
      k.index('.') ? self.eval("return #{k}") : get_global(k)
    end

    # This method holds the 'eval' mechanism.
    #
    def loadstring_and_call(s, bndng, filename, lineno)

      bottom = stack_top
      chunk = filename ? "#{filename}:#{lineno}" : "line"

      err = LibLua51.luaL_loadbuffer(@pointer, s, LibC::SizeT.cast(s.length), chunk)
      fail_if_error("eval:compile", err, bndng, filename, lineno)

      pcall(bottom, 0, bndng, filename, lineno) # arg_count is set to 0
    end

    # This method will raise an error with err > 0, else it will immediately
    # return.
    #
    def fail_if_error(kind, err, bndng, filename, lineno)
      return if err < 1

      s = String.new(LibLua51.lua_tolstring(@pointer, -1, nil))
      LibLua51.lua_settop(@pointer, -2)

      raise LuaError.new(kind, err, s, bndng, filename, lineno)
    end

    # Given the name of a Lua global variable, will return its value (or nil
    # if there is nothing bound under that name).
    #
    def get_global(name)

      stack_load_global(name)
      stack_pop
    end

    # Returns the result of a function call or a coroutine.resume().
    #
    def return_result(stack_bottom)
      count = stack_top - stack_bottom

      return nil if count == 0
      return stack_pop if count == 1

      (1..count).map { |pos| stack_pop }.reverse
    end

    # Assumes the Lua stack is loaded with a ref to a method and arg_count
    # arguments (on top of the method), will then call that Lua method and
    # return a result.
    #
    # Will raise an error in case of failure.
    #
    def pcall(stack_bottom, arg_count, bndng, filename, lineno)

      #err = Lib.lua_pcall(@pointer, 0, 1, 0)
        # When there's only 1 return value.
        # Use LUA_MULTRET (-1) the rest of the time

      err = LibLua51.lua_pcall(@pointer, arg_count, LUA_MULTRET, @error_handler)
      fail_if_error("eval:pcall", err, bndng, filename, lineno)

      return_result(stack_bottom)
    end


    def open_libraries(libs)
      if libs == true
        LibLua51.luaL_openlibs(@pointer)
      end
    end

    # Closes the state.
    #
    # It's probably a good idea (mem leaks) to close a Lua state once you're
    # done with it.
    #
    def close
      raise "State already closed" if @closed
      LibLua51.lua_close(@pointer)
      @closed = true
    end
  end
end
