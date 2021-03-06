local skynet = require "skynet"
local sharedata = require "sharedata"
local gdd = require "gddata.gdd"
local syslog = require "syslog"

local CMD = {}
function CMD.open ()
    local moniter = skynet.uniqueservice ("moniter")
    skynet.call(moniter, "lua", "register", SERVICE_NAME)
end

function CMD.heart_beat ()
    -- print("--- heart_beat gdd")
end

local traceback = debug.traceback
skynet.start (function ()
	sharedata.new ("gdd", gdd)
    skynet.dispatch ("lua", function (_, source, command, ...)
        local f = CMD[command]
        if not f then
            syslog.warningf ("unhandled message(%s)", command)
            return skynet.ret ()
        end

        local ok, ret = xpcall (f, traceback, source, ...)
        if not ok then
            syslog.warningf ("handle message(%s) failed : %s", command, ret)
            -- kick_self ()
            return skynet.ret ()
        end
        skynet.retpack (ret)
    end)
end)
