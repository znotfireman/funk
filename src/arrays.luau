local transformers = {}

function transformers.map<KI, VI, KO, VO>(fn: (KI, VI, { [KI]: VI }) -> (KO, VO), table: { [KI]: VI }): { [KO]: VO }
  local output = {}
  for key, value in table do
    local new_key, new_value = fn(key, value, table)
    output[new_key] = new_value
  end
  return output
end

table.freeze(transformers)
return transformers
