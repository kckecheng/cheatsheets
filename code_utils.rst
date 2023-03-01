.. contents:: Code Utilities

Code Utilities
===============

Tools for searching/inspecting program sources.

ripgrep
---------

rg can be used for simple code search:

::

  rg -g '*.c' vhost_net_start_one
  rg -g '*.c' -g '!*.h' 'main\('
  rg -g '*.{c,h}' 'start_kernel'

gnu global
------------

GNU Global is a source code tagging system which can be used as a replacement of cscope.

::

  # export GTAGSLABEL='native'
  # pygments need to be installed to support other languages, if global is used only for c/c++/java, then
  # it is not needed to export GTAGSLABEL
  export GTAGSLABEL='native-pygments'
  find . -type f ! -type l -name "*.[chS]" > gtags.files
  gtags
  gtags-cscope -d -p5
  # leverage http server - not recommended since it costs huge storage space
  # brew install http-server
  htags
  cd HTML/
  http-serve
  # open browser and access http://<IP>:8080

NOTE 1: global doesnot support listing functions called by 'this function' (not quite useful, since one can go to the the definition of 'this function' to find such info). Use cscope or cflow(c/c++ only) if the capability is important.

NOTE 2: gtags only supports tagging files under current source tree (the directory where gtags is run). For external source tree:

- Use soft link: ln -s /path/to/external/source/tree .
- Use GTAGSLIBPATH:

  ::

    # tags need to be generated under each source tree dir
    export GTAGSLIBPATH=/path/to/lib1:/path/to/lib2:...
    cd /path/to/lib1
    gtags ...
    cd /path/to/lib2
    gtags ...
    ...

NOTE3: for not tag/symbol related search, such as "Find this text string", "Find this file", "Find files #including this file", etc., global/cscope only searchs the dir and sub dirs it is started.

gnu cflow
----------

GNU cflow analyzes a collection of C source files and prints a graph, charting control flow within the program to explain relationships of caller/callee.

::

  cflow -b -m start_kernel init/main.c
  cflow -b *.c # all .c files under current directory
  # leverage the bash globstar feature
  cflow **/*.c # all .c files under current directory and its subdirectories
  # cover functions not reachable from main
  cflow -b --all a.c b/*.c
  cflow -b --no-main a.c b.c c/**/*.c

cscope and ctags
------------------

Used together for programming.

Notes:

- If vim plugin vista is used together, exuberant ctags is unsupported, using universal-ctags;
- If a file has Ctrl+M at the end of the line(windows format), cscope may have issues to display the file name. Run command "find . -type f -print0 | xargs -0 dos2unix" to convert such files.

::

  # find . -type f -name "*.[chS]" ! -path "./tools/*" ! -path "./Documentation/*" ! -path "./samples/*" ! -path "./scripts/*" ! -path "./arch/*" > cscope.files
  # find . -type f -name "*.[chS]" -path "./arch/x86/*" >> cscope.files
  find . -type f ! -type l -name "*.[chS]" > cscope.files
  cscope -b -k -q -i cscope.files # build cscope db by scanning files within cscope.files instead of the whole folder
  cscope -dq # use cscope after db buildup
  ctags -L cscope.files # build ctags db by scanning files within cscope.files instead of the whole folder

codequery
----------

Based on cscope and ctags, and combine their strength together. In the meanwhile, both a GUI and a CLI tool(cqsearch) is avaiable.

::

  cscope -bckqi cscope.files # assembly code is not supported, make sure files with .S suffix is not included
  ctags --fields=+i -L cscope.files
  cqmakedb -s cq.db -c cscope.out -t tags -p
  codequery # gui
  cqsearch -h # cli

doxygen
--------

Doxygen can be used to create documents, call graphs(graphviz is required in advance), etc.

::

  cd /path/to/source/code
  doxygen -g # doxywizard can be used to generate the configuration if UI is available(install doxygen-gui)
  vim Doxyfile
  # Make changes to below options
  # PROJECT_NAME = "a proper name"
  # HAVE_DOT = YES
  # EXTRACT_ALL = YES
  # EXTRACT_PRIVATE = YES
  # EXTRACT_STATIC = YES
  # EXTRACT_xxxxxx = YES # based on needs
  # INLINE_SOURCES = YES # based on needs
  # CALL_GRAPH = YES
  # CALLER_GRAPH = YES
  # RECURSIVE = YES
  # GENERATE_LATEX = NO
  # EXCLUDE_PATTERNS = */samples/* \
  #                    */tests/*
  # tune other options based on need, e.g.:
  # DISABLE_INDEX = NO
  # GENERATE_TREEVIEW = YES
  # Note: this is time cosuming for large projects
  doxygen Doxyfile
  brew install http-server
  cd html
  http-serve

cscope + tceetree + graphviz
-------------------------------

These tools can be used together to create call graph/tree.

::

  find . -name '*.c' > cscope.files
  cscope -b -c # tceetree does not support compress, hence -c
  # tceetree can be gotten from https://github.com/mihais/tceetree
  # tceetree generates call graph with main as root by default
  tceetree # the output is tceetree.out by default
  # to generate call graph with a specified function as root, say init_hw_perf_events
  tceetree -r init_hw_perf_events
  # install graphviz to use dot
  dot -Tsvg -O tceetree.out # the output will be tceetree.out.svc
  dot -Tsvg -Grankdir=LR -O tceetree.out # the output will get a layout from left to right

valgrind
----------

::

  # multiple tools are supported, man valgrind, check the --tool options
  valgrind --leak-check=full --track-origins=yes --verbose qemu-system-i386

