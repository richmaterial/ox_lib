--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

local ratelimit = {}

---@param key string Unique identifier for the ratelimit
---@param duration? number|false Milliseconds to wait before allowing again
---@param cb? function Callback to execute if not rate-limited
---@param ...? any Arguments to pass to the callback
lib.ratelimit = function(key, duration, cb, ...)
    local now = GetGameTimer and GetGameTimer() or os.time() * 1000

    if not duration and not cb then
        if ratelimit[key] and now < ratelimit[key] then
            local ms = ratelimit[key] - now
            local sec = ms / 1000

            return true, ms, sec
        else
            return false, 0, 0
        end
    end

    if not ratelimit[key] or now >= ratelimit[key] then
        if duration and duration > 0 then
            ratelimit[key] = now + duration
            
            if cb then
                local args = { ... }

                SetTimeout(duration, function()
                    return cb(table.unpack(args))
                end)
            end
        else
            ratelimit[key] = nil
        end
    end
end

return lib.ratelimit