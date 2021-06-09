.. contents:: Python Tips

===========
Python Tips
===========

Virtual Env
------------

venv
~~~~~

Since version 3.6, python has already provides a builtin module, A.K.A venv, to support virtual env. In other words, without any additional software and configuration, virtual env can be used directly. **However, it is not possible to specify a different python version with it.**

::

  python -m venv --help
  python -m venv venv1
  source venv1/bin/activate

  deactivate
  rm -rf venv1

virtualenvwrapper
~~~~~~~~~~~~~~~~~~

virtualenvwrapper is a set of extensions to to make virtual env ops easier. **It is recommended on Linux. However, it does not work well on Windows.**

::

  pip install virtualenvwrapper
  # Below source line is recommended to be included in your bash profile
  source /usr/local/bin/virtualenvwrapper.sh

  mkdir project1 && cd project1
  mkvirtualenv project1 -p /usr/bin/python3.6
  deactivate

  lsvirtualenv
  workon project1
  lssitepackages
  deactivate
  rmvirtualenv project1

Virtualenv
~~~~~~~~~~~~

Works well on both Linux and Windows, and it is easy to specify a different python verion. Refer to its official document - https://virtualenv.pypa.io/en/latest/

::

  # Windows example - with git-bash
  python -m virtualenv -p /c/Python27/python.exe virtenv1
  cd virtenv1
  source Scripts/activate
  deactivate

pip
----

Specify multiple index-url
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # pip.conf
  [global]
  index-url = http://pypi.org
  extra-index-url = http://extra1.org
                    http://extra2.org

Specify trusted hosts for pip
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  # defualt ~/.pip/pip.conf
  # virtualenv ~/.virtualenvs/<venv name>/pip.conf
  [global]
  trusted-host = pypi.python.org
                 pypi.org


Install for local user only
~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is **recommended** since packages installed through pip may get conflict with packages installed through system package management tools, such as apt, pacman. By installing pacakges for a user only, pacakges will be installed to ~/.local, which will never hit conflict problems.

::

  pip install --user <package>


List outdated packages
~~~~~~~~~~~~~~~~~~~~~~

::

  pip list [--local] --outdated

show pip dependency
~~~~~~~~~~~~~~~~~~~

Leverae tool **pipdeptree**

::

  pip install --user pipdeptree
  pipdeptree [-l]
  pipdeptree -p <package name>
  pipdeptree -r -p <package name>

upgrade all pip installed packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  pip freeze > requirements.txt
  sed -i 's/==.*$//' requirements.txt
  pip install -r requirements.txt --upgrade

Upgrade pip without checking the SSL ceritification
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  pip install --trusted-host pypi.python.org --upgrade pip

Install a specific version of package with pip
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  pip install 'prompt-toolkit==1.0.15'
  pip install 'prompt-toolkit<2.0.0,>=1.0.15'

List all avaible versions for a package
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trigger an error(specify a non-existing version with ==) with *pip install* on purpose which will list all versions of a package.

::

  pip install <package name>==

Install a local package
~~~~~~~~~~~~~~~~~~~~~~~

Sometimes, a package cannnot be installed with pip but needed to be installed by leveraging another pacakge/module. However, permission issues may be triggered.

For example, to install spaCy english model with command *python -m spacy download en*, permission deny problem will be hit if root is not used. Under such a condition, when we still want to install the package with a normal user, we need to download the pacakge to local and use pip to install it(Output of *python -m spacy download en* will indicate the file download path, then we can download the file with a web browser or curl)

::

  pip install --user ./en_core_web_sm-2.0.0.tar.gz

Log
~~~

::

  pip <commands> --log /tmp/pip.log

ElasticSearch
-------------

Common Search
~~~~~~~~~~~~~

::

  from elasticsearch import Elasticsearch
  es = Elasticsearch(['http://localhost:9200'])
  query = {
     'query': {
        'term': {
           'source': '/var/log/ycsb.log'
        }
     }
  }
  res = es.search(index='_all', body=query, _source=['host.name', 'message'], size=100)

Search Definition
~~~~~~~~~~~~~~~~~

Refer to:

  - `Request Body Search <https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html>`_
  - `Query DSL <https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html>`_

source code check
------------------

::

  python -m py_compile foo.py

format json
-----------

::

  cat <json file> | python -m json.tool
  vim <json file> -> :%!python -m json.tool (toggle vim plugin indentLine at fisrt)

python decorator
----------------

Refer to https://www.artima.com/weblogs/viewpost.jsp?thread=240845 for detailed explanations

Change Anaconda IPython Font Size
---------------------------------

::

  jupyter qtconsole --generate-config
  # Open the file generated above, and change the font size accordingly with corresponding option

Common Error Capture
--------------------

::

  import sys
  import traceback

  try:
    1 / 0
  except Exception as e:
    e_type, e_value, e_trace = sys.exc_info()
    print(f'Error type: {e_type}, Error value: {e_value}')
    traceback.print_tb(e_trace)

Datetime Conversion
-------------------

::

  from datetime import datetime
  from datetime import timedelta
  import pprint

  d1 = datetime.now() + timedelta(days=-1)
  d2 = datetime.now() + timedelta(days=1)
  if d1 < d2:
      pprint.pprint(d2 - d1)

  s1 = d1.strftime('%Y %m %d %H %M %S')
  s2 = d2.strftime('%Y %m %d %H %M %S')
  pprint.pprint(s1)
  pprint.pprint(s2)

  d1_new = datetime.strptime(s1, '%Y %m %d %H %M %S')
  d2_new = datetime.strptime(s2, '%Y %m %d %H %M %S')
  pprint.pprint(d1_new)
  pprint.pprint(d2_new)

Logging
--------

- Simple logging for daily debug

  ::

    import logging
    logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
    logging.info("Hello world!")

- Log to File and Console

  ::

    import logging
    import sys

    logger = logging.getLogger(__name__)
    logger.setLevel(logging.DEBUG)

    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

    ch = logging.StreamHandler(sys.stdout)
    ch.setLevel(logging.ERROR)
    ch.setFormatter(formatter)

    fh = logging.FileHandler('/tmp/spam.log')
    fh.setLevel(logging.DEBUG)
    fh.setFormatter(formatter)

    logger.addHandler(ch)
    logger.addHandler(fh)

Return every Nth Element
------------------------

::

  #l[::n]
  import random
  l1 = list(range(0, 100))
  random.shuffle(l1)
  l1[::5]

Split List into Chunks
----------------------

::

  #[l[i:i + n] for i in range(0, len(l), n)]
  l1 = list(range(0, 100))
  [l1[i:i+5] for i in range(0, len(l1), 5)]

Function Cache
--------------

::

  from functools import lcu_cache
  @lru_cache(maxsize=32)
  def testFunc1(*args, **kwargs):
    pass

  testFunc1()
  testFunc1.cache_info()
  testFunc1.clear_cache()

Run jupyter notebook with virtualenv
-------------------------------------

Beside below ops, "Kernel->Change kernel" need to be used to select the right execution virtualenv from the jupyter notebook.

::

  # Add virtualenv into jupyter
  ipython kernel install --user --name=<venv name>
  # Remove virtualenv from jupyter
  jupyter kernelspec list
  jupyter kernelspec uninstall <venv name>

Collect results from coroutines
-------------------------------

::

  import pprint
  import asyncio
  import random


  async def worker():
      num = random.randint(0, 100)
      data = list(range(0, num))
      return data


  async def main():
      tasks = []
      num = random.randint(1, 10)
      for i in range(0, num):
          tasks.append(worker())

      results = await asyncio.gather(*tasks)
      return results


  if __name__ == '__main__':
      results = asyncio.run(main())
      pprint.pprint(results)

Reload modules in IPython
--------------------------

::

  %load_ext autoreload
  %autoreload 2

Use IPython for interactive debug
----------------------------------

- Insert below line at the location where debug is needed, IPython will be started while run to the location:

  ::

    from IPython import embed; embed(colors="neutral")

- To abort the session, especially during a loop

  ::

    import os; os._exit(1)

Get Absolute Path of Current File
----------------------------------

::

  import os
  import pathlib
  path = pathlib.Path(os.path.realpath(__file__)).parent
  print(path)
  print(path.as_posix())

Sort List of Dicts based on Dict Key
-------------------------------------

::

  sorted(list_of_dict_to_be_sorted, lambda x: x['sort_key'])

Customize Package Name Swagger Codegen Creates
------------------------------------------------

By default, the package name swagger codegen creates will be swagger_api which is meaningless. This can be changed by defining a JSON configuration file as below:

1. Create config.json with below contents:

   ::

     {
       "packageName": "<package name, such as abc_api>",
       "projectName": "<project name, such as abc-api>"
     }

#. Generate SDK with the package name:

   ::

      java -jar swagger-codegen-cli.jar generate -i openapi.json -l python -c config.json -o <project name>

#. Other supported customization can be seen based on the help:

   ::

     java -jar swagger-codegen-cli.jar config-help -l python

Dynamically Import Module and Initialize Class Based on Strings
-----------------------------------------------------------------

- Import module based on string

  ::

    import importlib
    module = importlib.import_module(module_name)

- Initialize class based on string

  ::

    class_ = getattr(module, class_name)
    instance = class_()
