========
VIM Tips
========

Help
----

- :help help.txt      ---> all documents(help home page)
- :help index.txt     ---> a list of all commands for each mode
- :help motion.txt    ---> cursor motions
- :help scroll.txt    ---> scroll page up/down/left/right
- :help pattern.txt   ---> Search and replace used patterns, e.g. regular expression, exscaping, etc.
- :help magic         ---> Use magic to ease pattern escaping
- :help object-select ---> How to select a word, inner word, etc.
- :help cmdline.txt   ---> Command line mode help
- :help function-list ---> builtin functions of vim (:help functions also work)
- :help option-list   ---> a list/toc of all vim options, such as viminfo, etc.
- :help keycodes      ---> List key codes
- :help key-notation  ---> list all recognized keys (for key map definition)

Commands
--------

- :his / q:             ---> list command history
- :sav <name>           ---> Save the file as
- :set                  ---> list all currently options which are different from the default
- :version              ---> Check features enabled/compiled in vim
- :colorscheme desert   ---> Change color schemes
- :set [no]wrap         ---> world wrap
- :set relativenumber   ---> Show line number relatively based on current line
- :messages             ---> Show all messages, including errors
- :echo &abc            ---> Show the value of an option/value
- :echo &buftype        ---> Show current file's buffer type(quickfix, location list, etc.)
- :retab                ---> Replace tab as space based on tabstop
- :RemoveTrailingSpaces ---> Remove all trailing spaces
- :ccl / :cclose        ---> Close quickfix window (:h quickfix)
- :lcl / :lclose        ---> Close location list window(:h location-list)
- :set autoread         ---> Auto read file if the external file has changed(such as a live log file)
- :set conceallevel=0   ---> Stop hiding quotes for some files, such as json, markdown
- :help filetype-overview ---> help for filetype plugin indent
- :map                  ---> list all currently mapped keys
- :verbose <command>    ---> Show verebose information while running a command

  ::

    :help key-notation
    :verbose imap <tab>
    :verbose nmap <c-q>
    :verbose nmap qq

- :List supported file types and syntax highlight

  ::

    :echo glob($VIMRUNTIME . '/ftplugin/*.vim') ---> List supported(builtin) file types
    :echo glob($VIMRUNTIME . '/syntax/*.vim')   ---> List supported(builtin) syntax highlight

- Get Values
  - :set <option name>? ---> Get option value, e.g., set ft?
  - :echo <variable name>/&<option name>/&l:<local variable name>/@<register name>

Shortcuts
---------

- \*         ---> Search the word under the cursor
- K          ---> Open the manual(man) for the word under the cursor
- Ctrl + p   ---> Auto complete
- Ctrl + y   ---> Insert without line break for auto completition
- Ctrl + n/p ---> Select the next/previous choice from the auto completition list
- Ctrl + ]   ---> Jump to the section under the cursor while browsing VIM documents (such as :help index)
- Ctrl + ^   ---> Jump back to origin file from alternative file
- Ctrl + u/d ---> Scroll up/down half screen (:help usr_03.txt)
- Ctrl + b/f ---> Scroll back/forward one full screen
- {}         ---> Jump to previous/next paragraph
- Ctrl + G   ---> Show the full path of the file being edited
- Reference  ---> Refer to https://vim.rtorr.com/

Keymap
------

- :map -> check existing map
  - :map <C-e>: checking the current key mapping for Ctr + e
  - :verbose map <C-e>: checking the current key mapping for Ctr + e with verbose information
  - :verbose imap <Tab>: checking the current key mapping for Tab with verbose information
- Examples
  - map <C-n> :NERDTreeToggle<CR>
  - map <C-t> :Tagbar<CR>

Select
-------

- v              - select range of text
- shift + v      - select extire lines
- v/shift + v XG - select from current/line to the X line
- ctrl + v       - select columns(may be some other key maps based on customization)
- v/foo          - select from current position to the next instance of 'foo', n to next 'foo', ...
- ggvG           - select all
- ma -> :<line num> -> shift + v -> 'a - select from mark 'a' to line num

Copy
-----

- Copy all: ggyG

Delete
-------

- Delete until/upto(also valid for c/y) - t/f

  - dtx: delete until next character 'x'
  - dfx: delete up to the previous character 'x'

- Delete until based on search - d/<pattern>
- Delete based on object-selection

  - daw
  - diw
  - dab
  - ...

- Delete the whole line matching a pattern

  - :help :g
  - :g/pattern/d

- Delete the whole line which does not match a pattern

  - :help :v
  - :v/pattern/d

Vertical Edit
---------------

::

  Ctrl + V ---> column mode
             |
             V
  Select the columns and rows
             |
             V
  Shift + I ---> insert mode in column mode
             |
             V
         Type text
             |
             V
            Esc

Jumplist
---------

- :jumps ---> Display Jumplist
- Ctrl + o ---> Jump backward
- Ctrl + i ---> Jump forward


Macro
-----

- q<letter>: start recording to register letter, say d
- cmds     : commands to make changes
- q        : stop recording
- @<letter>: execute macro from register letter, say from register d
- @@       : execute the macro again

Tabs
----

- Built-in tabs: http://vim.wikia.com/wiki/Using_tab_pages
- :help tabedit
- :help tabnext/tabn
- :help tabprevious/tabp
- tabedit <file name>: open file in a new tab
- gt/gT              : go to next/previous tab

References
----------

- vim tips: http://vim.wikia.com/wiki/Best_Vim_Tips
- vim plugins: http://vimawesome.com/

Digraphs
-----------

- :help digraphs: digraph intro
- :help i_CTRL-V_digit: how to enter special chars
- :help digraph-table: find the special chars to be used, and remember their hex representations, e.g., 0x00 and 2218
- input the special chars: enter insert mode -> <C-v>u<hex num. w/o 0x>, e.g., <C-v>u00, <C-v>u2218

MISC Tips
---------

Viewports
+++++++++

Split
~~~~~

- :help split
- shortcuts:

  - <C-w>n : new horizontal split (editing a new empty buffer)
  - <C-w>s : split window horizontally (editing current buffer)
  - <C-w>v : vsplit window vertically (editing current buffer)
  - <C-w>c : close window
  - <C-w>o : close all windows, leaving only the current window open

- commands:

  - :sp    : split window horizontally (editing current buffer)
  - :vsp   : vsplit window vertically (editing current buffer)
  - :sp <file>  : open file in a horizontally splitted window
  - :vsp <file> : opne file in a vertically splitted window
  - :new   : split window horizontally (editing an new/empty buffer)
  - :vnew  : vsplit window vertically (editing an new/empty buffer)

- split with an exisitng buffer

  - :sb <num>            : split horizontally and edit the existing buffer <num>
  - :vert[ical] sb <num> : split vertically and edit the existing buffer <num>

Move/Rotate
~~~~~~~~~~~

- :help wincmd
- <C-w>r/R : rotate
- <C-w>K/J : rotate to top/bottom
- <C-w>H/L : rotate to left/right
- <C-w>T   : move the splitted window as a tabview(another way to maximize window)
- <C-w>w   : go to next window
- <C-w>p   : go to previous window
- <C-w> + Up/Down/Left/Right : go to window above/below/left/right

Resize
~~~~~~

- <C-w>| : maximize currentl vertically splitted window
- <C-w>_ : maximize current horizontally splitted window
- <C-w>= : make window size equally
- OR
- :resize +/- <num>
- :vert[ical] resize +/- <num>

Search whole word
+++++++++++++++++++

::

  /\<word\>

Reverse Search
++++++++++++++

Search lines which do not contain a word (refer to https://vim.fandom.com/wiki/Search_for_lines_not_containing_pattern_and_other_helpful_searches):

::

  /\v^((.*word.*)@!.)*$
  /\v^(.*word)@!.*$

Explanations:

- \\v: magic pattern (:help magic), ease the use of escape for special characters
- @!: does not match the preceding word

Search within a range
+++++++++++++++++++++++

::

  # :help search-range
  # search "pattern" between line 100(\%>100l) and 200(\%<200l)
  /\%>100l\%<200lpattern

Search/Replace respecting case
++++++++++++++++++++++++++++++

- <pattern>\c or \c<pattern>(help \\c): ignore case search/replace
- <pattern>\C or \C<pattern>(help \\C): search/replace respecting case
- Examples:

  - /hello\c: match hello, Hello, HELLO, etc.
  - /Hello\C: match only Hello

Replace with complicated expression
+++++++++++++++++++++++++++++++++++

Use **\\\=**: the result of evaluating the following expression.

Examples:

- Insert current line num. before each line

  ::

		:%s/^/\=printf('%-4d', line('.'))

- Insert current line num. relative to the selection

  ::

		:'<,'>s/^\S/\=printf("%d.\t", line(".") - line("'<") + 1)

Position cursor line
+++++++++++++++++++++

::

  # normal mode
  # to center
  zz
  # top top
  zt
  # to bottom
  zb

vimdiff
+++++++

- :h diff.txt - get help
- ]c          - next difference
- [c          - previous difference
- do          - diff obtain
- dp          - diff put
- zo          - open folded text
- zc          - close folded text
- :diffupdate - re-scan the files for differences

Profiling
+++++++++

Some plugins may lead to vim slow reponse. Profiling can help identify the culprit.

::

  :profile start profile.log
  :profile func *
  :profile file *
  " At this point do slow actions
  :profile pause
  :noautocmd qall!

Change file type/format
+++++++++++++++++++++++

- set ft?                     - Show current **filetype**
- set ft=text/log/json/...    - Set file type
- set ff?                     - Show **fileformat**, which is local to each buffer
- set ffs?                    - Show **fileformats**, which is global and specifies which file formats will be tried when Vim reads a file
- Covert dos/unix to unix

  ::

    :update
    :e ++ff=dos
    :setlocal ff=unix
    :w

- Convert from dos/unix to dos

  ::

    :update
    :e ++ff=dos
    :w

Capital and lower words
+++++++++++++++++++++++

- Select lines to be capitalized/lowered with visual selection
- U/u

Replace and refer to original data
++++++++++++++++++++++++++++++++++

- Use () to store matches
- Use \x to refer to the saved contents, \0 is the full original content, \1 is the first match, etc.
- Refer to :help regexp for re details
- \r equals new line

::

  :%s/\(content1\):\(content2\)/\1\r\2/

Non-greedy Operations
+++++++++++++++++++++

By default, search and replace in vim are greedy. To perform non-greedy operations, use ".\\{-}" instead of ".\*". Refer to **:help non-greedy** for details.

Show full path of a file
+++++++++++++++++++++++++

- Shortcut: **1**, then **Ctrl + G**
- Status line: set statusline+=%F

Define a custom command
++++++++++++++++++++++++++

::

  # create a command "TagbarToggle" which calls VoomToggle markdown for ft=markdown
  # since TagbarToggle already exists, this works as an overwriting when current buffer
  # is with ft=markdown
  # refer to :help command for "command" details
  autocmd FileType markdown call SetVoomMD()
  function SetVoomMD()
    command! -buffer TagbarToggle VoomToggle markdown
  endfunction

Debug log
++++++++++++

::

  # vim.log will record all debug info with verbose lever 9, default is 10
  vim -V9vim.log /path/to/some/file

Shortcut to current file w/ cmdline mode
+++++++++++++++++++++++++++++++++++++++++++

::

  # % stands for current file name w/ cmdline mode
  # :help filename-modifiers
  :Git add %
  :python %

