.. contents:: Tips for curl

=============
Tips for curl
=============

**httpie**, which is a moden simplified command line http client, can be leveraged as an alternative for curl.

Basic
-----

- verbose: curl **-v** http://example.com
- Follow redirect: curl -v **-L** http://example.com
- Ignore cert: curl -v -L **-k** http://example.com
- Authentication: curl -v -L **-u** name:password http://example.com
- Specify http header: curl **-H** 'Content-Type: application/json' http://example.com
- Specify request method: curl **-X** PUT http://example.com

Pass data
---------

**-d** options need to be used to send data:

- Basic: curl **-d** arbitrary http://example.com
- With space: curl -d **"**\ Hello world\ **"** http://example.com
- JSON: curl -d **'**\ {"name": "Kim"}\ **'** http://example.com
- Load JSON directly from a file: curl -d **@**\ file1.json http://example.com

Cookies
-------

- Write cookies: curl **-c** cookiejar.txt http://example.com
- Read cookies: curl **-b** cookiejar.txt http://example.com

Tips
----

Dumper Headers
~~~~~~~~~~~~~~

::

  curl -v -L -D /tmp/headers.txt http://example.com

Ignore Response Body
~~~~~~~~~~~~~~~~~~~~

::

  curl -v -L -o /dev/null http://example.com
