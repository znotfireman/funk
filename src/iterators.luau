export type Iterator<Generator, Parameters, State> = {
  generator: Generator,
  parameters: Parameters,
  state: State,
}

local iterators = {}
iterators.funk = nil

function iterators.wrap<Generator, Parameters, State>(
  generator: Generator,
  parameters: Parameters,
  state: State
): Iterator<Generator, Parameters, State>
  return setmetatable({
    generator = generator,
    parameters = parameters,
    state = state,
  }, {
    __index = iterators.funk,
    __call = function(self: Iterator<(any, any) -> (any, any, any), Parameters, State>, param, state)
      return self.generator(param, state)
    end,
  }) :: any
end
