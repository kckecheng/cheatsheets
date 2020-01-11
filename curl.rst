.. contents:: Tips for curl

=====
curl
=====

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

Below are frequently used options during data passing:

- -X: specify method(PUT/POST)
- -H: specify data type through corresponding header
- -d: specify data
- -F: specify form data


Examples
----------

URL Encoded POST
~~~~~~~~~~~~~~~~~

::

  curl -X POST -H "application/x-www-form-urlencoded" -d "param1=value1" -d "param2=value2" http://localhost:8080/uri1
  curl -X POST -d "param1=value1" -d "param2=value2" http://localhost:8080/uri1
  curl -X POST -d "param1=value1&param2=value2" http://localhost:8080/uri1
  curl -X POST -d "@data.txt" http://localhost:8080/uri1

JSON POST
~~~~~~~~~~

::

  url -X POST -H "Content-Type: application/json" -d '{"key1":"value1", "key2":"value2"}' http://localhost:8080/uri2
  curl -X POST -d "data.json" -H "Content-Type: application/json" http://localhost:8080/uri2

Binary POST
~~~~~~~~~~~~

::

  curl -X POST --data-binary @binaryfile http://localhost:8080/uri3

Form POST
~~~~~~~~~~

::

  curl -X POST -H "Content-Type: multipart/form-data" -F "param1=value1" -F "param2=value2" http://localhost:8080/uri3
  curl -X POST -F "param1=value1" -F "param2=value2" http://localhost:8080/uri3

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

Login
~~~~~~

- --user

 ::

   curl --user user:pass --cookie-jar jarfile.txt http://localhost:8080/login
   curl --cookie jarfile.txt http://localhost:8080/action

- -d

 ::

   curl -c jarfile.txt -d "user=username" -d "pass=password" http://localhost:8080/login
   curl -b jarfile.txt http://localhost:8080/action

- -F

 ::

   curl -c jarfile.txt -F "user=username" -F "pass=password" http://localhost:8080/login
   curl -b jarfile.txt http://localhost:8080/action
