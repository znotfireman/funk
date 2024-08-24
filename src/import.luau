type OverrideMode = "never" | "ignore" | "override"

local function import<T>(self: T & {}, override: OverrideMode?): T
  local override: OverrideMode = override or "ignore"
  local env = getfenv()

  if override == "never" then
    for key, value in pairs(self) do
      if value == import then
        continue
      end

      assert(env[key] == nil or override, `[funk] {key} already exists in the function environment`)
      env[key] = value
    end
  elseif override == "ignore" then
    for key, value in pairs(self) do
      if value == import or env[key] ~= nil then
        continue
      end

      env[key] = value
    end
  else
    for key, value in pairs(self) do
      if value == import then
        continue
      end

      env[key] = value
    end
  end

  (setfenv)(0, env)
  return self
end

return import
