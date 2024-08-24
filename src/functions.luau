--!strict
-- Funk is dual-licensed under MIT or Apache 2.0 terms.

local compat = require("funk/compat")

type Pack = { [number]: unknown, n: number }
type Cache = {
  [unknown]: {
    children: Cache,
    result: Pack,
  },
}

local WEAK_METATABLE = { __mode = "v" }
local function weaken<T>(table: (T & {})?): T
  return setmetatable((table or {}) :: any, WEAK_METATABLE)
end

local function get_cache(
  cache: Cache,
  ...: unknown
): {
  children: Cache,
  result: Pack,
}?
  local node = cache
  for index = 1, select("#", ...) do
    node = node.children and node.children[select(index, ...)]
    if not node then
      return nil
    end
  end
  return node.results
end

local function add_cache(cache: Cache, params: { unknown }, results: compat.Pack)
  local node: any = cache
  local param
  for i = 1, #params do
    param = params[i]
    node.children = node.children or weaken()
    node.children[param] = node.children[param] or {}
    node = node.children[param]
  end
  node.results = results
end

local functions = {}

function functions.all<T>(value: T, ...: (T) -> boolean)
  for index = 1, select("#", ...) do
    local predicate = select(index, ...)
    if not predicate(value) then
      return false
    end
  end
  return true
end

function functions.always<T...>(...: T...): () -> T...
  local arguments = (compat.pack :: any)(...)
  return function()
    return (compat.unpack :: any)(arguments)
  end
end

--[=[
  Bind a function to an object, meaning that whenever the function is called,
  the value of this will be the object. Optionally, pass arguments to the
  function to pre-fill them, also known as partial application.
]=]
function functions.bind<Self, Arg, Returns...>(self: Self, fn: (Self, ...Arg) -> Returns..., ...: Arg): (...Arg) -> Returns...
  local partial = compat.pack(...)
  if partial.n > 0 then
    return function(...)
      local args = table.clone(partial)
      for index = 1, select("#", ...) do
        table.insert(args, select(index, ...))
      end
      return fn(self, compat.unpack(args))
    end
  end
  return function(...)
    return fn(self, ...)
  end
end

--[=[
  Memoizes a given function by caching the results to be returned when the same
  arguments occur again.
]=]
function functions.memoize(fn: (...any) -> ...any)
  local cache: Cache = weaken()
  return function(...: any): ...any
    local params = compat.pack(...)
    local results: any = get_cache(cache, params)
    if not results then
      results = compat.pack(fn(...))
      add_cache(cache, params, results)
    end
    return compat.unpack(results)
  end
end

function functions.noop() end

--[=[
  Partially apply a function by creating a version that has had some of its
  arguments pre-filled.
]=]
function functions.partial<Arg, Returns...>(fn: (...Arg) -> Returns..., ...: Arg): (...Arg) -> Returns...
  local partial = compat.pack(...)
  if partial.n > 0 then
    return function(...)
      local args = table.clone(partial)
      for index = 1, select("#", ...) do
        table.insert(args, select(index, ...))
      end
      return fn(compat.unpack(args))
    end
  end
  return function(...)
    return fn(...)
  end
end

function functions.some<T>(value: T, ...: (T) -> boolean)
  for index = 1, select("#", ...) do
    local predicate = select(index, ...)
    if predicate(value) then
      return true
    end
  end
  return false
end

function functions.thunkify<Args..., Returns...>(fn: (Args...) -> Returns..., ...: Args...): () -> Returns...
  return functions.always(fn(...))
end

return functions
