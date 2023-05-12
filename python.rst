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

List files owned by a package
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  pip show -f <package name>

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

source code check
------------------

::

  python -m py_compile foo.py

format json
-----------

::

  cat <json file> | python -m json.tool
  vim <json file> -> :%!python -m json.tool (toggle vim plugin indentLine at fisrt)

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
    # e_type, e_value, e_trace = sys.exc_info()
    # print(f'Error type: {e_type}, Error value: {e_value}')
    # traceback.print_tb(e_trace)
    err = sys.exc_info()
    traceback.print_exception(*err)

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

Literal curly braces within format string
------------------------------------------

::

  # literal curly braces need to be input as {{ and }}
  # the result will be { 100 200 }
  "{{ {a} {b} }}".format(a=100, b=200)

Run nohup through paramiko
----------------------------

Construct the command as "nohup ./app >/dev/null 2>&1 &" (redirect output to files or discard it directly), otherwise, the connection will wait there until timeout.

argparse with subcommands
--------------------------------

::

  import argparse

  if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="argparse demo w/ subcommands")

    # to use subcommands, subparse is required, and dest is used to store the subcommand name(within namespace)
    subparser = parser.add_subparsers(title="subcommands", description="subcommands", dest="cmd")

    # a subcommand w/o any arguments
    subc1 = subparser.add_parser(name='command1', help="command1 w/o any arguments")

    subc2 = subparser.add_parser(name='command2', help="command2 w/ arguments")
    subc2.add_argument('-n', '--name', required=True, help='required argument for command2')

    args = parser.parse_args()
    if args.cmd == 'command1':
      print("actions for command1")

    if args.cmd == 'command2':
      print("actions for command2")
      print("argument name for command 2", args.name)

Generator expressions
-----------------------

::

  # syntax: (expression for item in iterable)
  # example:
  squares_generator = (i * i for i in range(5)) # the generator
  for i in squares_generator: # iterate over the generator
    print(i)

