.. contents:: Ansible Tips

=============
Configuration
=============

Common Configuration Sample
---------------------------

For all options, refer to `ansible.cfg in source control <https://raw.github.com/ansible/ansible/devel/examples/ansible.cfg>`_

After modifying the configuration files, run command **ansible-config dump --only-changed** to verify the changes.

::

  [defaults]
  # library = ~/ansible-library:/usr/share/ansible
  # log_path=/var/log/ansible.log

  # gathering = implicit
  # gathering = explicit
  gathering = smart
  fact_caching = jsonfile
  # absolute/relative path the facts are stored under
  fact_caching_connection = facts

  host_key_checking = False
  roles_path = ~/ansible-role
  inventory = inventory/hosts
  library   = lib/modules
  module_utils   = lib/module_utils
  transport = paramiko
  jinja2_extensions = jinja2.ext.do,jinja2.ext.i18n,jinja2.ext.loopcontrols

  # By default, all objects are parsed as tring, by enabling this option,
  # there is no need to perform type casting
  jinja2_native = True

Load Additional Jinja Extensions
--------------------------------

In the ansible.cfg, enable the option as below. Refer to http://jinja.pocoo.org/docs/2.10/extensions/ for supported Jinja extensions.

::

  jinja2_extensions = jinja2.ext.do,jinja2.ext.i18n

Load a different ansible.cfg
----------------------------

::

  export ANSIBLE_CONFIG="<path to the ansible.cfg>"
  ...

Predefined Environment Variables
--------------------------------

Refer to `constants.py <https://github.com/ansible/ansible/blob/devel/lib/ansible/constants.py>`_

=========
MISC Tips
=========

offline documents
-----------------

::

  git clone https://github.com/ansible/ansible.git
  cd ansible/docs/docsite
  # make all/docs/htmldocs/...
  make htmldocs
  rm -rf _build
  cd
  ln -s /home/kc/ansible/docs/docsite/rst ansible-docs

Catch errors
------------

Normally, Ansible will stop executing remaining tasks(including tasks defined in a role) if any error happens in the playbook. However, sometimes, it is required to keep executing remaining tasks. For example, if there are severl roles(e.g. test cases), which actually are independent from each other and achieve different purposes, it is always good to keep executing when some of them hit problems.

The convenient solution for this is block, which currently support rescue. Below is an example, role1 and role2 are totally independent and won't fail the whole playbook when any one runs into exception.

.. code-block:: yaml

    task:
      - name: independent role1
        block
          - name: role1
            include_role:
              name: role1
        rescue:
          - debug:
              msg: 'Error handing code for this role'
        always:
          - debug:
              msg: 'Some cleanup code for this role'

      - name: independent role2
        block
          - name: role2
            include_role:
              name: role2
        rescue:
          - debug:
              msg: 'Error handing code for this role'
        always:
          - debug:
              msg: 'Some cleanup code for this role'

      ......


Loop over all hosts
-------------------

.. code-block:: yaml

    - command: echo {{ item }}
      with_items:
        - "{{ groups['all'] }}"

Load variables with file from CLI
---------------------------------

ansible-playbook *-e* @<path to file> ……

Break Lines
-----------

- Join multiple lines with new line

  .. code-block:: yaml

     shell: |
       command1
       command2
       ……

- Join multiple lines without new line(literal string only)

  .. code-block:: yaml

     some_key_or_module: >
       string1
       string2

- Join multiple lines with single/double quote or brackets/braces/parentheses/operators

  .. code-block:: yaml

     - name: generate fio required dict containing io file path, log path, etc.
       set_fact:
         fio_cfg: "
           {{-
             fio_cfg | default([]) +
               [
                 {
                   'ini': (fio_dir ~ '/' ~ item | basename ~ '_fio.ini') | regex_replace('/+?', '/'),
                   'output': (item ~ '/fio.iofile') | regex_replace('/+?', '/'),
                   'log': (fio_dir ~ '/' ~ item | basename ~ '_fio.log') | regex_replace('/+?', '/')
                 }
               ]
           -}}
         "
       with_items: "{{ fs_list }}"

set_fact with jinja expression
------------------------------

- Leverage jinja together with set_fact will make Ansible able to conduct complciated operations, such as updating a list of dicts, etc.

  .. code-block:: yaml

     - name: update a list of dict with set_fact and jinja expression
       hosts: localhost
       vars:
         disks:
           - name: sda
             wwn: wwn1
           - name: sdb
             wwn: wwn2

       tasks:
         - name: update disks by appending a key
           set_fact:
             disks: >
               {%- set disks_new=[] -%}
               {%- for d in disks -%}
                 {%- do d.update({'label': 'vtoc'})-%}
                 {%- do disks_new.append(d) -%}
               {%- endfor -%}
               {{ disks_new }}


- Pitfalls: for a normal variable (not a list/dict), '{{ <variable name> }}' will be a string with a trailing new line. Leverage below workaround:

  .. code-block:: yaml

     - name: update a normal variable
       hosts: localhost

       tasks:
         # the result of below statement won't be {'data': 100} but {'data': '100\n'}
         - set_fact:
             data: >
               {%- if data is undefined -%}
                 100
               {%- endif -%}

         # workaround - use dict
         - block:
             - set_fact:
                 data: >
                   {%- set data_new = {'value': data | default(0)} -%}
                   {%- if data is undefined -%}
                     {%- do data_new.update({'value': 100}) -%}
                   {%- endif -%}
                   {{ data_new }}

             # data_new.value will be 100 as expected
             - debug:
                 var: data.value

Integer list on the fly
-----------------------

Level the Jinja2 global function **range**:

::

  - debug:
      var: range(0, 100, 10) | list

Inventory on the fly
--------------------

When the host to be used is not defined in the inventory, try this:

.. code-block:: shell

  # ansible-playbook -i 'xha10100,' test.yml -v -e "ansible_host=192.168.10.100 ansible_user=root ansible_ssh_pass='password'"

Handler task trigger
--------------------

Ansible "notify" actions(hanlder) will only be run when there is a change, which can be seen with "ansible-playbook -vvv" output(changed: true).

Overwrite changes
-----------------

Leverage *changed_when* to always set changes as true/false:

::

  - module_name:
      param1: value1
      ......
    changed_when: true

  - module_name:
      param1: value1
      ......
    changed_when: false

Meta module
-----------

Meta tasks are a special kind of task which can influence Ansible internal execution or state.

It can be used to **clear_facts**, **refresh_inventory**, etc.

Add new element(key value pairs) to a dict
------------------------------------------

.. code-block:: yaml

   - name: add a key
     set_fact:
       d1: "{{ d1 | combine({'a': 100}) }}"

set_fact on a list
------------------

.. code-block:: yaml

   - name: store a list
     set_fact:
       list_name: "{{ list_name | default([]) + [ item ] }}"
     with_items: "{{ original_list }}"

Compose complicated list by looping all servers
-----------------------------------------------

.. code-block:: yaml

   - name: store complicated data
     set_fact:
       nodes: "{{ nodes | default([]) + [{'name': hostvars[item].name, 'wwns': hostvars[item].wwns}] }}"
     with_items: "{{ groups['all'] }}"
     delegate_to: localhost
     run_once: yes

Match a list against another list
---------------------------------

There are 2 x lists, l1, l2. The expected result is getting a new list containing only elements in l1 which match(contain) elements in l2.

For example:

- l1 = ['abc', 'def', 'ghi']
- l2 = ['ab', 'gh']

The expected list: ['abc', 'ghi']

.. code-block:: yaml

   - name: list match
     set_fact:
       matched: "{{ (matched | default([]) + [item[0]]) | unique }}"
     when: item[0] | search(item[1])
     with_nested:
       - "{{ l1 }}"
       - "{{ l2 }}"

Notes: match('*' ~ something ~ '*') == search(something)

Change every elements of a list with map
----------------------------------------

Filter *map* accept another filter as the first parameter, and pass all its other parameters to the filter.

.. code-block:: yaml

   - name: change list elements with map
     debug:
       msg: "{{ original_list | map('regex_replace', '(.*)', '/media/\\1') | list }}"


Unset a variable
----------------

There is no 'unset' in Ansible/YAML to make a variable as undefined. However, you can gain the purpose by setting a variable as null(*!!null*):

.. code-block:: yaml

   - set_fact:
       var1: "Hello world"

   - set_fact:
       var1: !!null

   - debug:
       var: var1
     when: var1 | bool

Loop in group_vars file
-----------------------

With *group_vars file*, it is not possible to use any module, like set_fact, to define lists. However, Jinja tempalte can be used to achieved the same. Below is an example:

1. 2 x hosts are defined in the inventory: hosts

   ::

     node1 ansible_host=192.168.100.100
     node2 ansible_host=192.168.100.101

     [nodes]
     node1
     node2

2. host_vars:

   - node1 host_var definition: host_vars/node1.yml

     ::

       wwn:
        - wwn1
        - wwn2

   - node2 host_var definition: host_vars/node2.yml

     ::

       wwn:
        - wwn1
        - wwn2

3. In group_vars file, we can build a complicated list for all hosts: group_vars/nodes.yml

   - Format without breaking lines:

     ::


       group_name: nodes
       servers: "{% set servers=[] %}{% for host in groups[group_name] %}{{ servers.append({ 'name': hostvars[host].ansible_hostname, 'wwn': hostvars[host].wwns }) }}{% endfor %}{{ servers }}"

       --- when Jinja expression statement is on (jinja2.ext.do in ansible.cfg) ---

       group_name: nodes
       servers: "{% set servers=[] %}{% for host in groups[group_name] %}{% do servers.append({ 'name': hostvars[host].ansible_hostname, 'wwn': hostvars[host].wwns }) %}{% endfor %}{{ servers }}"

   - Break lines format(recommended):

     ::

       group_name: nodes
       servers: |
         {%- set servers=[] -%}
         {%- for host in groups[group_name] -%}
           {%- do servers.append({ 'name': hostvars[host].ansible_hostname, 'wwn': hostvars[host].wwns }) -%}
         {%- endfor -%}
         {{ servers }}


4. In playbook, the list can be verified:

   .. code-block:: yaml

      - debug:
          var: servers

Handle one time interaction command
-----------------------------------

   .. code-block:: yaml

      shell: |
        stmsboot -e -D fp <<-EOF
        n
        EOF
      register: output

Create a random string with hash filter
---------------------------------------

   .. code-block:: yaml

      - name: create a random string
        set_fact:
          random_s: "{{ lookup('pipe', 'date') | hash('sha1') }}"

Pitfalls with assert
--------------------

When the assert module is used together with loops, 'item' is decoded as a string literally when it is used as a key of a dict. Under such conditions, use [] instead of . notation.

For example:

- This won't work:

  ::

    - assert:
        that:
          - "var1.item == 0"

- This works:

  ::

    - assert:
        that:
          - "var1[item] == 0"

Pitfalls with with_sequence
---------------------------

item returned from loop with_sequence is a unicode but not a int. To use it in math ops, filter it.

::

  - debug:
      var: item | int + 100
    with_sequence: start=0 end=10 stride=2

Filter/reduce a list
--------------------

- **select** can be used together with match/search to filter/reduce a list:

  ::

    - debug:
        var: list1 | select('match', '<regular expression such as .*zfs.*>') | list
    - debug:
        var: list2 | select('search', '<substring such as zfs>') | list

- **selectattr** can be used together with match/search/equalto to filter/reduce a list of dicts:

  ::

    - debug:
        var: list3 | selectattr("type", "equalto", "floating") | map(attribute='addr') | list
    - debug:
        var: list4 | selectattr("type", "match", "^floating$") | map(attribute='addr') | list }}
    - debug:
        var: list5 | selectattr("type", "search", "^floating$") | map(attribute='addr') | list }}

- **reject** can be used together with match/search to **reverse** filter/reduce a list:

  ::

    - debug:
        var: list6 | reject('match', '<regular expression such as .*zfs.*>') | list
    - debug:
        var: list7 | reject('search', '<substring such as zfs>') | list

json_query
----------

- Refer to:

  - Tutorial: http://jmespath.org/tutorial.html
  - Examples: http://jmespath.org/examples.html
  - JMESPath Spec: http://jmespath.org/specification.html
  - JSONPath Expression Summary and Samples: http://goessner.net/articles/JsonPath
  - Tools:

    - JMESHPath Terminal(*recommended*): https://github.com/jmespath/jmespath.terminal
    - JSON Online Editor: https://jsoneditoronline.org/
    - JSONPath Online Evaluator: http://jsonpath.com/

- Tips:

  - Literal: `<value>`, e.g., `[1, 2]` stands for [1, 2] but not an array
  - Logical combination: &&, || , !

**Sample Data**:

::

  servers:
    - name: server1
      cluster: c1
      hbas:
        - status: online
          wwn: wwn11
        - status: offline
          wwn: wwn12
        - status: online
          wwn: N/A
      nics:
        - status: online
          speed: 100
          ip: ip11
    - name: server2
      cluster: c1
      hbas:
        - status: online
          wwn: wwn21
        - status: offline
          wwn: wwn22
      nics:
        - status: online
          speed: 1000
          ip: ip21
        - status: online
          speed: 1000
          ip: ip21

**Examples**:

::

  - name: extract a single attribute
    debug:
      var: servers | json_query(query_str)
    vars:
      query_str: "[*].name"

  - name: extract multiple attributes
    debug:
      var: servers | json_query(query_str)
    vars:
      query_str: "[*].[name, hbas]"

  - name: extract multiple attributes and construct a dict
    debug:
      var: servers | json_query(query_str)
    vars:
      query_str: "[*].{name: name, hbas: hbas}"

  - name: extract attributes of an attribute
    debug:
      var: servers | json_query(query_str)
    vars:
      query_str: "[*].{name: name, hbas: hbas[*].wwn}"

  - name: extract attributes of an attribute based on a condition
    debug:
      var: servers | json_query(query_str)
    vars:
      query_str: "[*].{name: name, hbas: hbas[?status=='online'].[wwn, status]}"

Pitfalls with hostname
----------------------

- inventory_hostname: the host alias added in the inventory, which is always set the same as the real hostname, but a different value can be used.
- ansible_hostname:   the real hostname of a host.
- Sample: inventory_hostname will be host1, and ansible_hostname will equal to the value when you login the server and run command hostname

  ::

    # Inventory file
    host1 ansible_host=192.168.1.10 ansible_user=root ansible_ssh_pass=password
- Therefore, to use condtion checks, such as the when clause, to restrict where a task can be run, "inventory_hostname" is the right answer if inventory_hotname does not equal to ansible_hostname. For example:

  ::

    - name: restrict where a command should be run
      hosts: all

      tasks:
        - name: run on node1
          command: echo "hello node1"
          when: inventory_hostname == 'node1'
          run_once: yes

        ...

Pitfalls with add_host
----------------------

A host added by add_host won't take effect (except for tasks which define delegate_to: <the newly added host>) until you start a new play in the same playbook.

For example, below is a test playbook:

::

  - name: add_host test
    hosts: all

    tasks:
      - name: add a host
        add_host:
          name: host1
          ansible_host: 192.168.1.10
          ansible_user: root
          ansible_password: password

      - name: update facts
        setup:

      - name: output hostname
        debug:
          var: ansible_hostname

The execution result will not as your expected: "update facts" and "output hostname" will only be run for once and only be run on other hosts excluding the newly added host1.

To fix this issue, a new play in the same playbook needs to be created. The working version is as below:

::

  - name: add_host test
    hosts: all

    tasks:
      - name: add a host
        add_host:
          name: host1
          ansible_host: 192.168.1.10
          ansible_user: root
          ansible_password: password

  - name: add_host test
    hosts: all

    tasks:
      - name: update facts
        setup:

      - name: output hostname
        debug:
          var: ansible_hostname

Find groups a host belongs to
-----------------------------

::

  - name: output the group names the current host belongs to
    debug:
      var: group_names

  # The below task equals to the above one
  - name: output the group names the current host belongs to, but more dynamic
    debug:
      var: hostvars[inventory_hostname].group_names

  # host_inventory_name1 is the hostname defined in the inventory
  - name: output the group names any host belongs to
    debug:
      var: hostvars['host_inventory_name1'].group_names

Use scp for the copy module
---------------------------

By default, the copy module will use sftp to copy files to targets. On some system, such as cirros, sftp won't be enabled. To bypass this, below configuration options can be used in ansible.cfg:

::

  [ssh_connection]
  scp_if_ssh = smart

Define variables with add_host
------------------------------

::

  - name: add a host and define a parameter named address
    add_host:
      name: host1
      ansible_host: 192.168.1.10
      ansible_user: root
      ansible_password: password
      address: 192.168.1.10

Document for a module
---------------------

Document can be written by following guide/spec `Documenting Your Module <http://docs.ansible.com/ansible/latest/dev_guide/developing_modules_documenting.html>`_. After defining document based on the spec, ansible-doc can be leveraged to review it.

Quick module debug
------------------

Refer to `Ansible Module Development Walkthrough <http://docs.ansible.com/ansible/latest/dev_guide/developing_modules_general.html>`_ for details.

::

  export ANSIBLE_KEEP_REMOTE_FILES=1
  ansible-playbook ... -vvvv
  ssh remote_target
  cd <remote script directory of the module>
  python ansible_module_<module name>.py explode
  cd ./debug-dir
  chmod a+x ansible_module_<module name>.py
  # Add debug code in the script
  ./ansible_module_<module name>.py args

meta: clear_host_errors
-----------------------

Connection failures set hosts as ‘UNREACHABLE’, which will remove them from the list of active hosts for the run. To recover from these issues you can use meta: clear_host_errors to have all currently flagged hosts reactivated, so subsequent tasks can try to use them again.

Load environemnt variables on Ubuntu
------------------------------------

On Ubuntu, the default sh(*/bin/sh*) points to /bin/dash. When it is executed, .bashrc won't be loaded automatically. In other words, if some environment varaibles are defined in .bashrc, they won't work. In the meanwhile, because of line **[ -z "$PS1" ] && return**, environment variables won't take effect if they are defined after this line.

The solution:

- Changung /bin/sh to bash: ln -s -f /bin/bash /bin/sh
- Define variables at the begining of .bashrc

Send Ansible log to Elasticsearch
---------------------------------

1. Ansible cannot send its log to Elasticsearch directly, but there exist a builtin callback to send Ansible log to logstash, through which log can be redirected to Elasticsearch;
2. Ansible Configuration:

   - Define below environment variable:

     .. code-block:: sh

        export LOGSTASH_SERVER=x.x.x.x #default localhost
        export LOGSTASH_PORT=xxxx #deault 5000
        export LOGSTASH_TYPE=xxxx #default ansible

   - Enable logstash callback in ansible.cfg

     ::

       callback_whitelist = logstash
       callback_plugins = logstash

   - Install logstash python library

     ::

       pip install python-logstash

3. Logstash configuration:

   ::

     input {
         tcp {
             port => 5000
             codec => json
         }
     }

     output {
         elasticsearch {
             hosts => [ "localhost:9200" ]
             index => "ansible"
         }
     }

4. Kibana configuration:

   - Run a playbook to send an initial data to Elasticsearch to generate the index "ansible"
   - Kibana GUI -> Management -> Elasticsearch -> Index Management: check the availablility of the index
   - Kibana GUI -> Management -> Kibana -> Index Patterns -> Create index pattern: create a pattern for the index

5. Done

===============
Template/Jinja2
===============

Overview
--------

All Jinja2 **filters/global functions/test** can be used directly with Ansible

- http://jinja.pocoo.org/docs/2.10/templates/#list-of-builtin-filters
- http://jinja.pocoo.org/docs/2.10/templates/#list-of-global-functions
- http://jinja.pocoo.org/docs/2.10/templates/#list-of-builtin-tests

Extension - Expression Statement
--------------------------------

1. To enable the Jinja extension, enable the option in ansible.cfg as below:

   ::

     jinja2_extensions = jinja2.ext.do

2. Then, below format takes effect:

   ::

     {% do <statements> %}

3. It equals to *{{ <statements> }}* except that it won't print anything, which makes it suitable for list operations.

Extension - Loop Controls
-------------------------

1. To enable the Jinja extension, enable the option in ansible.cfg as below:

   ::

     jinja2_extensions = jinja2.ext.loopcontrols

2. Then, below format takes effect(break/continue):

   ::

     {% for ... %}
       ...
       {% if ... %}
         {% break %}
       {% endif %}
       ...
     {% endfor %}

Remove white spaces from left/right
-----------------------------------

Refer to - http://jinja.pocoo.org/docs/2.9/templates/#whitespace-control

.. code-block:: jinja

   {%- for <…> -%}
   …
   {%- endfor -%}

   {{- <varibale name> -}}

   {%- if <…> -%}
   …
   {%- endif -%}

Create a list
-------------

The output of below tempalte will look like: $CFG{systems}=["xha239194","xha239195"];

.. code-block:: jinja

   $CFG{systems}=[
     {%- for host in groups['vcs'] -%}
       "{{- hostvars[host]['ansible_hostname'] -}}" {%- if not loop.last -%},{%- endif -%}
     {%- endfor -%}
   ];

Iterate over Hosts
------------------

.. code-block:: jinja

   {% for host in groups['all'] %}
   {{ hostvars[host]['ansible_default_ipv4']['address'] }} {{ hostvars[host]['ansible_hostname'] }}
   {% endfor %}

Raw Contents
------------

**{% raw %}<content>{% endraw %}**: Contents, such as {{ var1 }}, between 'raw' block will be treated literally.

Pitfalls with set
-----------------

Jinja **'set'** won't work beyond scope (such as loop, if, etc.). E.g., below sample won't work as expected - 'exist' will always be False (the original value outside the for loop):

.. code-block:: jinja

   {% set exist = False %}
   {% for v in vars%}
     {% if v %}
       {% set exist = True %}
     {% endif %}
   {% endfor %}
   {{ exist }}

**To bypass** the issue, use dict's update method as below. The 'exist.value' will be as expected:

.. code-block:: jinja

   {% set exist = {'value': False} %}
   {% for v in vars%}
     {% if v %}
       {% do exist.update({'value': True}) %}
     {% endif %}
   {% endfor %}
   {{ exist.value }}

=============
Custom Plugin
=============

Access Plugin Parameter
-----------------------

.. code-block:: python

   self._task.args[<arg name>]

Access Existing Fact Variable
-----------------------------

.. code-block:: python

   try:
       self._templar.template("{{ <variable name> }}", convert_bare=True, fail_on_undefined=True)
   except:
       <variable name> = <init data when undefined>
