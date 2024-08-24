--!strict
-- Funk is dual-licensed under MIT or Apache 2.0 terms.

local functions = require("funk/functions")
local import = require("funk/import")

type Funk = {
  import: (self: Funk, override: "never" | "ignore" | "override" | nil) -> Funk,

  all: <T>(value: T, ...(T) -> boolean) -> boolean,
  always: <T...>(T...) -> () -> T...,
  bind: <Self, Arg, Returns...>(self: Self, fn: (Self, ...Arg) -> Returns..., ...Arg) -> (...Arg) -> Returns...,
  memoize: <Args..., Returns...>(fn: (Args...) -> Returns...) -> (Args...) -> Returns...,
  noop: (...unknown) -> (),
  partial: <Arg, Returns...>(fn: (...Arg) -> Returns..., ...Arg) -> (...Arg) -> Returns...,
  some: <T>(value: T, ...(T) -> boolean) -> boolean,
  thunkify: <Args..., Returns...>(fn: (Args...) -> Returns..., Args...) -> () -> Returns...,
}

local function Funk(x: Funk): Funk
  return table.freeze(x)
end

return Funk {
  version = "0.1.0",
  import = import,

  all = functions.all,
  always = functions.always,
  bind = functions.bind,
  memoize = functions.memoize :: <Args..., Returns...>(fn: (Args...) -> Returns...) -> (Args...) -> Returns...,
  noop = functions.noop,
  partial = functions.partial,
  some = functions.some,
  thunkify = functions.thunkify,
}
