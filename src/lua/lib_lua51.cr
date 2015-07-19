@[Link("lua5.1")]
lib LibLua51
  type State = Void*

  alias CFunction = (State) -> Int32
  alias Number = Float64

  fun luaL_loadbuffer(s : State, buff : UInt8*, sz : LibC::SizeT, name : UInt8*) : Int32
  fun luaL_newstate() : State
  fun luaL_openlibs(s : State) : Void
  fun luaL_ref(s : State, t : Int32) : Int32
  fun luaL_unref(s : State, t : Int32, ref : Int32) : Void

  fun lua_call(s : State, nargs : Int32, nresults : Int32) : Void
  fun lua_close(s : State) : Void
  fun lua_gettable(s : State, index : Int32) : Void
  fun lua_gettop(s : State) : Int32
  fun lua_next(s : State, index : Int32) : Int32
  fun lua_objlen(s : State, index : Int32) : LibC::SizeT
  fun lua_pcall(s : State, nargs : Int32, nresults : Int32, errfunc : Int32) : Int32
  fun lua_pushcclosure(s : State, fn : CFunction, n : Int32) : Void
  fun lua_pushboolean(s : State, b : Int32) : Void
  fun lua_pushinteger(s : State, n : Int32) : Void
  fun lua_pushnumber(s : State, n : Number) : Void
  fun lua_pushnil(s : State) : Void
  fun lua_pushlstring(s : State, s : UInt8*, len : LibC::SizeT) : Void
  fun lua_rawgeti(s : State, index : Int32, n : Int32) : Int32
  fun lua_settable(s : State, index : Int32) : Void
  fun lua_settop(s : State, index : Int32) : Void
  fun lua_toboolean(s : State, index : Int32) : UInt32
  fun lua_tolstring(s : State, index : Int32, length : LibC::SizeT*) : UInt8*
  fun lua_tonumber(s : State, index : Int32) : Number
  fun lua_type(s : State, index : Int32) : Int32
  fun lua_typename(s : State, tp : Int32) : UInt8*
end
