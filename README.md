Name
====

lua-tablepool - Lua table recycling pools for LuaJIT

Table of Contents
=================

* [Name](#name)
* [Synopsis](#synopsis)
* [Description](#description)
* [Methods](#methods)
    * [fetch](#fetch)
    * [release](#release)
* [Prerequisites](#prerequisites)
* [Community](#community)
    * [English Mailing List](#english-mailing-list)
    * [Chinese Mailing List](#chinese-mailing-list)
* [Bugs and Patches](#bugs-and-patches)
* [Author](#author)
* [Copyright and License](#copyright-and-license)

Synopsis
========

```nginx
local tablepool = require "tablepool"

local pool_name = "some_tag"

local my_tb = tablepool.fetch(pool_name, 0, 10)

-- using my_tb for some purposes...

tablepool.release(pool_name, my_tb)
```

Description
===========

This Lua library implements a pool mechanism to recycle small Lua tables. This can
avoid frequent allocations and de-allocation of many small Lua tables for temporary use.
Recycling tables can also reduce the overhead of garbage collection in general.

The Lua table pools are shared across all the requests handled by the current NGINX
worker process unless `lua_code_cache` is turned off in your `nginx.conf`.

Methods
=======

To load the `tablepool` module,

```
local tablepool = require "tablepool"
```

[Back to TOC](#table-of-contents)

fetch
-----
`syntax: tb = tablepool.fetch(pool_name, narr, nrec)`

Fetches a (free) Lua table from the table pool of the specified name `pool_name`.
If the pool
does not exist or the pool is empty, simply create a Lua table whose array part has
`narr` elements and whose hash table part has `nrec` elements.

[Back to TOC](#table-of-contents)

release
-------
`syntax: cache, err = tablepool.release(pool_name, tb, [no_clear])`

Releases the already used Lua table, `tb`, into the table pool named `pool_name`. If the specified
table pool does not exist, create it right away.

The caller must *not* continue using the released Lua table, `tb`, after this call. Otherwise
random data corruption is expected.

The optional `no_clear` parameter specifies whether to clear the contents in the Lua table
`tb` before putting it into the pool. Defaults to `false`, that is, always clearing the Lua table.
If you always initialize all the elements in the Lua table and always use the exactly same number of elements in the Lua table, then you can set this argument to `true` to
avoid the overhead of explicit table clearing.

According to the current implementation, for maximum 200 Lua tables can be cached in
an individual pool. We may make this configurable in the future. If the specified table
pool already exceeds its size limit, then the `tb` table is subject to garbage collection. This behavior is to avoid potential memory leak due to unbalanced `fetch` and `release` method calls.

[Back to TOC](#table-of-contents)

Caveats
=======

Large tables requiring clearing
-------------------------------

If you always need to clear out the recycled Lua tables, then you should avoid recycling
relatively large Lua tables (like those of hundreds or even thousands of elements in a single table).
This is because clearing large Lua tables may offset the benefit of recycling tables.

It is recommended to always watch for the `lj_tab_clear` function frames in the C-land on-CPU
flame graphs of your busy nginx worker processes.

Prerequisites
=============

This Lua library depends on the new `table.new` and `table.clear` API functions first introduced since LuaJIT 2.1.
Older versions of LuaJIT or the standard Lua interpreters will *not* work at all.

[Back to TOC](#table-of-contents)

Community
=========

[Back to TOC](#table-of-contents)

English Mailing List
--------------------

The [openresty-en](https://groups.google.com/group/openresty-en) mailing list is for English speakers.

[Back to TOC](#table-of-contents)

Chinese Mailing List
--------------------

The [openresty](https://groups.google.com/group/openresty) mailing list is for Chinese speakers.

[Back to TOC](#table-of-contents)

Bugs and Patches
================

Please report bugs or submit patches by

1. creating a ticket on the [GitHub Issue Tracker](https://github.com/openresty/lua-resty-lrucache/issues),
1. or posting to the [OpenResty community](#community).

[Back to TOC](#table-of-contents)

Author
======

Yichun "agentzh" Zhang (章亦春) <agentzh@gmail.com>, OpenResty Inc.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2016-2017, by Yichun "agentzh" Zhang, OpenResty Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)
