--!strict
-- Funk is dual-licensed under MIT or Apache 2.0 terms.

export type Runtime = "Runtime.Roblox" | "Runtime.Lune" | "Runtime.Vanilla"
export type Pack<T = unknown> = { [number]: unknown, n: number }

local Runtime = table.freeze {
  Roblox = "Runtime.Roblox" :: "Runtime.Roblox",
  Lune = "Runtime.Lune" :: "Runtime.Lune",
  Vanilla = "Runtime.Vanilla" :: "Runtime.Vanilla",
}

local compat = {
  Runtime = Runtime,
  unpack = table.unpack or unpack :: any,
  pack = table.pack or function(...)
    -- selene: allow(mixed_table)
    return { ..., n = select("#", ...) }
  end,
} :: {
  Runtime: typeof(Runtime),
  current_runtime: Runtime,

  cancel: (thread: thread) -> (),
  defer: <A..., R...>(resume: thread | (A...) -> R..., A...) -> thread,
  delay: <A..., R...>(seconds: number, resume: thread | (A...) -> R..., A...) -> thread,
  spawn: <A..., R...>(resume: thread | (A...) -> R..., A...) -> thread,
  wait: (seconds: number?) -> number,

  unpack: <T>(pack: Pack<T>, starting: number?, ending: number?) -> ...T,
  pack: <T>(...T) -> Pack<T>,
}

do
  if game and game.ClassName == "DataModel" then
    compat.current_runtime = Runtime.Roblox

    compat.cancel = task.cancel
    compat.defer = task.defer
    compat.delay = task.delay
    compat.spawn = task.spawn
    compat.wait = task.wait
  elseif string.find(_VERSION, "Lune") then
    compat.current_runtime = Runtime.Lune

    local task = (require)("@lune/task")
    compat.cancel = task.cancel
    compat.defer = task.defer
    compat.delay = task.delay
    compat.spawn = task.spawn
    compat.wait = task.wait
  else
    compat.current_runtime = Runtime.Vanilla

    function compat.spawn(resume, ...)
      if type(resume) == "thread" then
        coroutine.resume(resume, ...)
        return resume
      else
        local thread = coroutine.create(resume)
        coroutine.resume(thread, ...)
        return thread
      end
    end

    compat.defer = compat.spawn

    function compat.cancel(thread)
      local ok, reason = coroutine.close(thread)
      if not ok then
        error(`[funk] cannot cancel thread; {reason}`)
      end
    end

    function compat.wait(seconds)
      local start_time = os.clock()
      local end_time = start_time + (seconds or 1)
      local clock_time: number

      repeat
        clock_time = os.clock()
      until clock_time >= end_time

      return clock_time - start_time
    end

    local function delay_runner(seconds: number?, resume: thread | (...any) -> ...any, ...: any)
      compat.wait(seconds)
      if type(resume) == "thread" then
        coroutine.resume(resume, ...)
      else
        resume(...)
      end
    end

    function compat.delay(seconds, resume, ...)
      return compat.spawn(delay_runner, seconds, resume, ...)
    end
  end
end

return compat
