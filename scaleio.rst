============
ScaleIO Tips
============

Install SDC manually
--------------------

MDM Node
++++++++

::

  # scli --mdm_ip <MDM IP> --login --username admin
  # scli --add_sdc --sdc_ip <SDC IP> --sdc_name <SDC Name>

SDC Node
++++++++

::
  # rpm -ivh EMC-ScaleIO-sdc-2.0-7120.0.el7.x86_64.rpm
  # vi /bin/emc/scaleio/drv_cfg.txt
  ini_guid 68dde52d-84a4-493b-b9d3-1d0ecbc562e3 --->Make sure this ID is unique
  mdm 10.103.116.202,10.103.116.193 ---> Add this line
  # systemctl restart scini

Query Device Used for SDS
-------------------------

::

  # scli --query_sds <SDS ID/Name/IP/etc.>
