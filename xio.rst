========
XIO Tips
========

Node Reboot
-----------

::

  xmcli (tech)> show-storage-controllers
  Storage-Controller-Name Index Mgr-Addr      IB-Addr-1    IB-Addr-2    Brick-Name Index Cluster-Name Index State   Health-State Enabled-State Stop-Reason Conn-State
  X1-SC1                  1     192.168.100.201 169.254.0.1  169.254.0.2  X1         1     SOlXIO       1     healthy healthy      enabled       none        connected
  X1-SC2                  2     192.168.100.202 169.254.0.17 169.254.0.18 X1         1     SOlXIO       1     healthy healthy      enabled       none        connected

  xmcli (tech)> deactivate-storage-controller sc-id=1  Please wait a moment when deactivate the next node.
  Are you sure you want to deactivate Storage Controller X1-SC1 [1]? (Yes/No): yes
  Storage Controller X1-SC1 [1] deactivation initiated
  [###################################################] 100%    Done!    (elapsed time 00:00:15)
  Storage Controller X1-SC1 [1] deactivation succeeded

  xmcli (tech)> show-storage-controllers
  Storage-Controller-Name Index Mgr-Addr      IB-Addr-1    IB-Addr-2    Brick-Name Index Cluster-Name Index State        Health-State Enabled-State Stop-Reason                 Conn-State
  X1-SC1                  1     192.168.100.201 169.254.0.1  169.254.0.2  X1         1     SOlXIO       1     disconnected healthy      user_disabled lost_connectivity_with_node disconnected
  X1-SC2                  2     192.168.100.202 169.254.0.17 169.254.0.18 X1         1     SOlXIO       1     healthy      healthy      enabled       none                        connected

  xmcli (tech)> activate-storage-controller sc-id=1
  Storage Controller X1-SC1 [1] activation initiated
  [###################################################] 100%    Done!    (elapsed time 00:06:15)
  Storage Controller X1-SC1 [1] activation succeeded

Collect Debug Log
-----------------

::

	xmcli (admin)> create-debug-info
	The process may take a while. Please do not interrupt.
	.................................................................................................................................................................................................................................................................................................................................................................................................................................................................
	Successfully collected dossier on xms
	Successfully collected dossier on X1-SC2
	Successfully collected dossier on X1-SC1
	Created /var/www/xtremapp/DebugInfo/csxio_2015_02_10_0219.tar.gz

	Debug info collected and may be accessed via https://192.168.100.101/xtremapp/DebugInfo/csxio_2015_02_10_0219.tar.gz
	xmcli (admin)> show-debug-info
	Name Index Cluster-Name Index Debug-Level Creation-Start-Time      Create-Time              Output-Url
     1     csxio        1     medium      Tue Feb 10 02:19:48 2015 Tue Feb 10 02:34:49 2015 https://192.168.100.101/xtremapp/DebugInfo/csxio_2015_02_10_0219.tar.gz
