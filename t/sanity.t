# vi:ft=

use Test::Nginx::Socket::Lua;

repeat_each(2);
#no_long_string();

plan tests => repeat_each() * (3 * blocks());

my $pwd = `pwd`;
chomp $pwd;

our $HttpConfig = <<_EOC_;
    lua_package_path '$pwd/lib/?.lua;lib/?.lua;;';
_EOC_

#log_level 'warn';

run_tests();

__DATA__

=== TEST 1: sanity
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local tablepool = require "tablepool"

            local old_tb = tablepool.fetch("tag", 0, 10)
            if not old_tb then
                ngx.say("failed to fetch table")
                return
            end

            old_tb.a = "test"
            tablepool.release("tag", old_tb)

            local new_tb = tablepool.fetch("tag", 0, 10)
            ngx.say("equal: ", new_tb == old_tb, " old value:", new_tb.a)
        }
    }
--- request
GET /t
--- response_body
equal: true old value:nil
--- no_error_log
[error]



=== TEST 2: release without clear
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local tablepool = require "tablepool"

            local old_tb = tablepool.fetch("tag", 3, 10)
            if not old_tb then
                ngx.say("failed to fetch table")
                return
            end

            old_tb.a = "test"
            tablepool.release("tag", old_tb, true)

            new_tb = tablepool.fetch("tag", 3, 10)
            ngx.say("equal: ", new_tb == old_tb, " old value:", new_tb.a)
        }
    }
--- request
GET /t
--- response_body
equal: true old value:test
--- no_error_log
[error]



=== TEST 3: release without clear
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local tablepool = require "tablepool"

            tablepool.release("tag", nil)
        }
    }
--- request
GET /t
--- response_body_like: 500 Internal Server Error
--- error_code: 500
--- error_log
content_by_lua(nginx.conf:45):4: object empty



=== TEST 4: clear metatable
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local tablepool = require "tablepool"

            local old_tb = tablepool.fetch("tag", 0, 10)
            if not old_tb then
                ngx.say("failed to fetch table")
                return
            end

            local meta = { foo = 1 }
            meta.__index = meta

            setmetatable(old_tb, meta)

            tablepool.release("tag", old_tb)

            local new_tb = tablepool.fetch("tag", 0, 10)
            ngx.say("equal: ", new_tb == old_tb, " old value:", new_tb.foo)
        }
    }
--- request
GET /t
--- response_body
equal: true old value:nil
--- no_error_log
[error]
