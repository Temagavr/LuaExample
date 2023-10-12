-- search.lua
ngx.say("<h3>Select example</h3><br/><br/>")

local mysql = require "resty.mysql" -- подключим библиотеку по работе с mysql
local db, err = mysql:new()
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
end

db:set_timeout(1000) -- 1 sec

local ok, err, errcode, sqlstate = db:connect{
    host = "127.0.0.1",
    port = 3306,
    database = "office",
    user = "root",
    password = "MySqlPass",
    charset = "utf8",
    max_packet_size = 1024 * 1024,
}

if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end

ngx.say("<h4>connected to mysql.</h4><br/><br/>")

-- run a select query, expected about 10 rows in
-- the result set:
res, err, errcode, sqlstate = db:query("select * from employee order by 1 asc")
if not res then
    ngx.say("bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    return
end

local cjson = require "cjson"
ngx.say("result: ", cjson.encode(res))
-- put it into the connection pool of size 100,
-- with 10 seconds max idle timeout
local ok, err = db:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end


