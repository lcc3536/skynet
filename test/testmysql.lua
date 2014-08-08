local skynet = require "skynet"
local mysql = require "mysql"
local cjson = require "cjson"

local mysql_server_config = {
    host = "127.0.0.1",
    port = 3306,
    database = "skynet",
    user = "root",
    password = "1",
    max_packet_size = 1024 * 1024
}

local table_name = "skynet_mysql_test_table";

local opts = {
    [1] = {
        desc = "drop table test",
        sql = "drop table if exists " .. table_name
    },
    [2] = {
        desc = "create table test",
        sql = "create table " .. table_name .. " (id serial primary key, name varchar(10))"
    },
    [3] = {
        desc = "insert test",
        sql = "insert into " .. table_name .. " (name) values (\'oppai\'),(\'嘿嘿\'),(\'\'),(null)"
    },
    [4] = {
        desc = "select test",
        sql = "select * from " .. table_name .. " order by id asc; select * from " .. table_name
    },
    [5] = {
        desc = "multi result set test",
        sql = "select * from " .. table_name .. " order by id asc; select * from " .. table_name
    },
    [6] = {
        desc = "bad sql test",
        sql = "select * from not_exist_table"
    }
}

local db;

local function connect()
    print("\n------------------------------------------------------------------------------------------------")
    print("test mysql begin, server config is:")
    print(cjson.encode(mysql_server_config))
    print("------------------------------------------------------------------------------------------------")

    db = mysql.connect(mysql_server_config)

    if db then
        print("success to connect")
    else
        print("failed to connnect")
    end
    print("------------------------------------------------------------------------------------------------\n")
end

local function escape_string_test()
    print("\n------------------------------------------------------------------------------------------------")
    print("escape string test result: ", mysql.quote_sql_str([[\mysql escape %string test'test"]]))
    print("-------------------------------------------------------------------------------------------\n")
end

local function test_opt(index)
    local opt = opts[index]
    local res = db:query(opt.sql)

    print("\n------------------------------------------------------------------------------------------------")
    print("desc: ", opt.desc)
    print("sql: ", opt.sql)
    print("res: ", cjson.encode(res))
    print("------------------------------------------------------------------------------------------------\n")
end

local function loop_test(index)
    local tast_name = "loop test" .. index

    return function()
        if not db then
            print("db no exist")
            return
        end

        print("start " .. tast_name)

        local sql = "select * from " .. table_name .. " order by id asc"
        local res
        local i = 1

        while true do
            res = db:query(sql)
            print("--11--", tast_name, " times = ", i, "res : ", cjson.encode(res))

            res = db:query(sql)
            print("--22--", tast_name, " times = ", i, "res : ", cjson.encode(res))

            skynet.sleep(1000)

            i = i + 1
        end
    end
end

local function init()
    connect()

    for i = 1, #opts do
        test_opt(i)
    end

    for i = 1, 4 do
        skynet.fork(loop_test(i));
    end
end

skynet.start(init);
