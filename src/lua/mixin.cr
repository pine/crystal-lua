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
  alias LuaPrimitiveType = Nil | Bool | String | LibLua51::Number

  module StateMixin
    LUA_GLOBALSINDEX = -10002
    LUA_ENVIRONINDEX = -10001
    LUA_REGISTRYINDEX = -10000
    LUA_NOREF = -2
    LUA_REFNIL = -1

    # Lua GC constants
    LUA_GCSTOP = 0
    LUA_GCRESTART = 1
    LUA_GCCOLLECT = 2
    LUA_GCCOUNT = 3
    LUA_GCCOUNTB = 4
    LUA_GCSTEP = 5
    LUA_GCSETPAUSE = 6
    LUA_GCSETSTEPMUL = 7

    TNONE = -1
    TNIL = 0
    TBOOLEAN = 1
    TLIGHTUSERDATA = 2
    TNUMBER = 3
    TSTRING = 4
    TTABLE = 5
    TFUNCTION = 6
    TUSERDATA = 7
    TTHREAD = 8

    SIMPLE_TYPES = [ TNIL, TBOOLEAN, TNUMBER, TSTRING ]

    LUA_MULTRET = -1

    def stack_top
      LibLua51.lua_gettop(@pointer)
    end

    # Fetches the top value on the stack (or the one specified by the optional
    # pos parameter), but does not 'pop' it.
    #
    def stack_fetch(pos=-1)

      type, tname = stack_type_at(pos)

      case type
      when TNIL then nil
      when TSTRING then
        len = LibC::SizeT.cast(0)
        ptr = LibLua51.lua_tolstring(@pointer, pos, pointerof(len))
        String.new(ptr, len)

      when TBOOLEAN then (LibLua51.lua_toboolean(@pointer, pos) == 1)
      when TNUMBER then LibLua51.lua_tonumber(@pointer, pos)

      when TTABLE then Table.new(@pointer)
        # warning : this pops up the item from the stack !

      # when TFUNCTION then Function.new(@pointer)
      # when TTHREAD then Coroutine.new(@pointer)

      else tname
      end
    end

    # Returns a pair type (int) and type name (string) of the element on top
    # of the Lua state's stack. There is an optional pos paramter to peek
    # at other elements of the stack.
    #
    def stack_type_at(pos=-1)
      type = LibLua51.lua_type(@pointer, pos)
      tname = String.new(LibLua51.lua_typename(@pointer, type))

      { type, tname }
    end

    # Given a Ruby instance, will attempt to push it on the Lua stack.
    #
    def stack_push(o)
      case o
      when Nil then LibLua51.lua_pushnil(@pointer)
      when Bool then LibLua51.lua_pushboolean(@pointer, o ? 1 : 0)
      when Int8 then LibLua51.lua_pushinteger(@pointer, Int32.cast(o))
      when UInt8 then LibLua51.lua_pushinteger(@pointer, Int32.cast(o))
      when Int16 then LibLua51.lua_pushinteger(@pointer, Int32.cast(o))
      when UInt16 then LibLua51.lua_pushinteger(@pointer, Int32.cast(o))
      when Int32 then LibLua51.lua_pushinteger(@pointer, o)
      when UInt32 then LibLua51.lua_pushinteger(@pointer, Int32.cast(o))
      when Float32 then LibLua51.lua_pushnumber(@pointer, Float64.cast(o))
      when Float64 then LibLua51.lua_pushnumber(@pointer, o)
      when String then LibLua51.lua_pushlstring(@pointer, o, LibC::SizeT.cast(o.bytesize))
      when Symbol then LibLua51.lua_pushlstring(@pointer, o.to_s, LibC::SizeT.cast(o.to_s.bytesize))
      when Hash then stack_push_hash(o)
      when Array then stack_push_array(o)
      else raise(
        ArgumentError.new(
          "don't know how to pass Crystal instance of #{o.class} to Lua"))
      end
    end

    # Pops the top value of lua state's stack and returns it.
    #
    def stack_pop

      r = stack_fetch
      stack_unstack if r.class != Table

      r
    end

    # Makes sure the stack loses its top element (but doesn't return it).
    #
    def stack_unstack
      new_top = stack_top - 1
      new_top = 0 if new_top < 0
        #
        # there are no safeguard in Lua, setting top to -2 work well
        # when the stack is crowded, but it has bad side effects when the
        # stack is empty... Now safeguarding by ourselves.

      LibLua51.lua_settop(@pointer, new_top)
    end

    # Loads the Lua object registered with the given ref on top of the stack
    #
    def stack_load_ref(ref)
      LibLua51.lua_rawgeti(@pointer, LUA_REGISTRYINDEX, @ref)
    end

    # Loads a Lua global value on top of the stack
    #
    def stack_load_global(name)
      LibLua51.lua_getfield(@pointer, LUA_GLOBALSINDEX, name)
    end
  end
end
