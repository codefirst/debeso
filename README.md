debeso
=======================

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

[![Build Status](https://secure.travis-ci.org/codefirst/debeso.png)](http://travis-ci.org/codefirst/debeso)
[![wercker status](https://app.wercker.com/status/258544b3ecebe46e2c1bc92d54b0d2c1/s/ "wercker status")](https://app.wercker.com/project/bykey/258544b3ecebe46e2c1bc92d54b0d2c1)

Overview
----------------
debeso is an application to manage code snippets.

Features:

 * Easy Installtion
 * Version Control
 * Search
 * Syntax Highlights
 * API

Authors
-----------------------

 * @suer
 * @mallowlabs

 We are [codefirst.org](https://codefirst.org)!

Requirements
-----------------------
 * Ruby 1.8+
 * RubyGems 1.4.2+
 * Bundler 1.0.15+
 * SQLite 3.6.18+
 * Git 1.4.7.1+

Installation
-----------------------

Type below command:

    $ bundle install --path vendor/bundle
    $ cp config/setting.yml.sample config/setting.yml
    $ vi config/setting.yml
    $ bundle exec padrino rake ar:migrate
    $ bundle exec padrino start

Next, access to http://localhost:3000

How to test (for Developers)
-----------------------

Type below command:

    $ bundle exec padrino rake ar:migrate -e test
    $ bundle exec padrino rake spec

if you prefer to auto testing:

    $ bundle exec guard start

Special Thanks
-----------------------

Original idea from:

 * [gist](https://gist.github.com/)
 * [Heso](https://github.com/lanius/heso/)

We respect there applications and authors.

License
-----------------------

The MIT License (MIT) Copyright (c) 2011 codefirst.org

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


debeso depends on below software:

 * [Twitter Bootstrap](http://twitter.github.com/bootstrap/) - Apache License 2.0
 * [CodeMirror](http://codemirror.net/) - The MIT-style license

