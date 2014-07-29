local skynet = require "skynet"
local sharedata = require "sharedata"

local mode = ...

if mode == "host" then

skynet.start(function()
	skynet.error("new foobar")
	sharedata.new("foobar", { a=1, b= { "hello",  "world" } })

	skynet.fork(function()
		skynet.sleep(300)	-- sleep 3s
		skynet.error("update foobar")
		sharedata.update("foobar", { a =2 })
	end)
end)

else


skynet.start(function()
	skynet.newservice(SERVICE_NAME, "host")

	local obj = sharedata.query "foobar"

	local b = obj.b
	skynet.error(string.format("a=%d", obj.a))

	for k,v in ipairs(b) do
		skynet.error(string.format("b[%d]=%s", k,v))
	end

	for i = 1, 5 do
		skynet.sleep(100)
		skynet.error(i)
		for k,v in pairs(obj) do
			skynet.error(string.format("%s = %s", k , tostring(v)))
		end
	end

	local ok, err = pcall(function()
		local tmp = { b[1], b[2] }	-- b is invalid , so pcall should failed
	end)

	if not ok then
		skynet.error(err)
	end

	collectgarbage()
	skynet.error("sleep")
	skynet.sleep(100)
	b = nil
	collectgarbage()
	skynet.error("sleep")
	skynet.sleep(100)

	sharedata.delete "foobar"

	skynet.exit()
end)

end