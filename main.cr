require "./src/lua"

s = Lua::State.new(["base", "io"])
table = s.eval("return { [\"a\"] = 9 }") as Lua::Table
p table
p table.length
p table["a"]


