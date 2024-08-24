declare function all<T>(value: T, ...: (T) -> boolean): boolean
declare function always<T...>(...: T...): () -> T...
  
--[=[
  Bind a function to an object, meaning that whenever the function is called,
  the value of this will be the object. Optionally, pass arguments to the
  function to pre-fill them, also known as partial application.

  @within Funk
]=]
declare function bind<Self, Arg, Returns...>(self: Self, fn: (self: Self, ...Arg) -> Returns..., ...: Arg): (...Arg) -> Returns...

--[=[
  Memoizes a given function by caching the results to be returned when the same
  arguments occur again.

  @within Funk
]=]
declare function memoize<Args..., Returns...>(fn: (Args...) -> Returns...): (Args...) -> Returns...
declare function noop(...: unknown): ()

--[=[
  Partially apply a function by creating a version that has had some of its
  arguments pre-filled.

  @within Funk
]=]
declare function partial<Arg, Returns...>(fn: (...Arg) -> Returns..., ...: Arg): (...Arg) -> Returns...
declare function some<T>(value: T, ...: (T) -> boolean): boolean
declare function thunkify<Args..., Returns...>(fn: (Args...) -> Returns..., ...: Args...): () -> Returns...