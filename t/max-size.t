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

=== TEST 1: max pool size is 200
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local tablepool = require "tablepool"

            local arr = {}
            for i = 1, 201 do
                local t = tablepool.fetch("tag", 0, 1)
                t.a = "foo"

                arr[i] = t
            end

            for i = 1, #arr do
                tablepool.release("tag", arr[i], true)
            end

            for i = 1, 2 do
                local t = tablepool.fetch("tag", 0, 10)
                ngx.say("old value: ", t.a)
            end
        }
    }
--- request
GET /t
--- response_body
old value: foo
old value: foo
--- no_error_log
[error]
