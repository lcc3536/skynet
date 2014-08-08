--
-- Created by IntelliJ IDEA.
-- User: lcc3536
-- Date: 14-8-8
-- Time: 下午5:27
-- To change this template use File | Settings | File Templates.
--


local skynet = require "skynet"

skynet.start(function()
    print("main mysql start")
    skynet.newservice("testmysql")

    print("main mysql exit")
    skynet.exit()
end)

