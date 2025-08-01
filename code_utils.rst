===============
Code Utilities
===============

Tools for searching/inspecting program sources.

ripgrep
---------

rg can be used for simple code search:

::

  rg -g '*.c' vhost_net_start_one
  rg -g '*.c' -e pattern1 -e pattern2
  rg -g '*.c' -g '!*.h' 'main\('
  rg -g '*.{c,h}' 'start_kernel'
  rg -g '*.S' -w idt arch/x86
  rg -g '*.S' -w idt -o arch/x86
  rg -l -g '*.[chS]' # list file names w/o any contents
  rg --color=always task_struct | less -R

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

gnu global
------------

GNU Global is a source code tagging system which works similarly as cscope. It provides more accurate results when used for finding global definitions.

::

  # if a language is not supported by the used parser, gtags won't work, to specify a parser:
  # - default: builtin parser, support asm, c/c++, java, php, yacc;
  # - ctags: use exuberant-ctags as parser, support more than 40 x languages;
  # - new-ctags: use universal-ctags as parser, support more than 100 x languages;
  # - pygments: use pygments(apt install python3-pygments) as parser, support more than 300 x languages;
  # - native-pygments(recommended): use builtin parse for asm, c/c++, java, php, yacc and pygments for others;
  export GTAGSLABEL='native-pygments' # or gtags --gtagslabel=native-pygments
  find . -type f ! -type l -name "*.[chS]" > gtags.files
  gtags
  # incremental updates
  gtags -i
  gtags-cscope -dp5
  # leverage http server - not recommended since it costs huge storage space
  # brew install http-server
  htags
  cd HTML/
  http-serve
  # open browser and access http://<IP>:8080

GNU Global can be used from CLI directly:

::

  gtags -i
  global -x start_kernel
  global -rx start_kernel
  global -src start_kernel

NOTE 1: use cscope when analyzing caller/callee is important

- global does not support 'Find functions called by this function'
- global does not list the caller's name while 'Find references of this function'

NOTE 2: gtags only supports tagging files under current source tree (the directory where gtags is run). For external source tree:

- Use soft link(use "find -L ..." to create gtags.files): ln -s /path/to/external/source/tree .
- Use GTAGSLIBPATH:

  ::

    # tags need to be generated under each source tree dir
    export GTAGSLIBPATH=/path/to/lib1:/path/to/lib2:...
    cd /path/to/lib1
    gtags ...
    cd /path/to/lib2
    gtags ...
    ...

NOTE 3: for not tag/symbol related search, such as "Find this text string", "Find this file", "Find files #including this file", etc., global/cscope only searchs the dir and sub dirs it is started.

cscope and ctags
------------------

cscope is recommended for analyzing caller/callee relationships which is not supported well in GNU Global. When it is used for finding global definitions, the results are not quite accurate since external declarations and some references will also be included.

Notes:

- If vim plugin vista is used together, exuberant ctags is unsupported, using universal-ctags;
- If a file has Ctrl+M at the end of the line(windows format), cscope may have issues to display the file name. Run command "find . -type f -print0 | xargs -0 dos2unix" to convert such files.

  ::

    # find . -type f -name "*.[chS]" ! -path "./tools/*" ! -path "./Documentation/*" ! -path "./samples/*" ! -path "./scripts/*" ! -path "./arch/*" > cscope.files
    # find . -type f -name "*.[chS]" -path "./arch/x86/*" >> cscope.files
    find . -type f ! -type l -name "*.[chS]" > cscope.files
    cscope -b -k -q -i cscope.files # build cscope db by scanning files within cscope.files instead of the whole folder
    cscope -dqp5 # use cscope after db buildup
    ctags -L cscope.files # build ctags db by scanning files within cscope.files instead of the whole folder

- Filter: use ^ to filter results, e.g., use ^ + grep -v ';$' to exclude external declarations, or use ^ + grep '{$' to focus on real type declarations.
- cscope supports line-oriented useage:

  ::

    # -Lnum: num is from 0~9, man cscope for details
    cscope -d -L0 start_kernel
    cscope -d -L1 start_kernel
    cscope -d -L2 start_kernel

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

valgrind
----------

::

  # multiple tools are supported, man valgrind, check the --tool options
  valgrind --leak-check=full --track-origins=yes --verbose qemu-system-i386

Makefile
---------

Overriding Variables

::

  # choose a suitable method directly from below options
  # for gcc options, man gcc to get the enable/disable arguments
  # 1. w/ Makefile, adding an options as below:
  CFLAGS+=-Wno-deprecated-declarations
  # Notice: below 2 x options won't respect existing options
  # 2. pass the env var ahead of the make command
  CFLAGS=-Wno-deprecated-declarations make
  # 3. pass the env var w/ make parameter
  make -e CFLAGS=-Wno-deprecated-declarations

clang
------

Static Analyzer:

::

  clang --analyze -I /path/to/additional/include1 -I ... <file to check>
  # checkers can be listed w/ command: scan-build --help-checkers
  clang --analyze -Xanalyzer \
    -analyzer-checker=<checker class such as core or specific checker name such as core.CallAndMessage> \
    -analyzer-checker=...
    ...
    <file to check>

clangd
--------

clangd is a language server for c/c#/c++. To make it work:

- code should be built for at least once;
- a compilation database(compile_commands.jso) should exist at the project root folder;

Here are several examples on how to generate compile_commands.json:

- linux kernel: ships with a script which generates compile_commands.json

  ::

    make CC=clang defconfig
    make CC=clang -j`nproc`
    python ./scripts/clang-tools/gen_compile_commands.py
    head compile_commands.json

- ltp: use bear to generate compile_commands.json

::

  ./configure --with-realtime-testsuite --with-open-posix-testsuite
  # sudo apt install -y bear
  bear -- make CC=clang
  head compile_commands.json

- legacy projects(which cannot be built w/ clang): use compiledb to parse build logs and generate compile_commands.json

::

  ./configure ...
  make --always-make --dry-run -j32 2>&1 | tee build.log
  # uv tool install compiledb
  compiledb --parse build.log
  head compile_commands.json
