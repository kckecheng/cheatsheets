===========
VPLEX Notes
===========

1. #cluster expel ---> disconnect VPLEX WAN connections; "cluster unexpel" is used to reconnect the expelled cluster back;
2. Log collection:

   -  VPlexcli:/> collect-diagnostics -----> About an hour will be taken, depends on setting of the VPLEX cluster;
   -  VPlexcli:/> exit
   -  # cd /diag
   -  Note: if files like collect-diagnostics--tmp and/or collect-diagnostics-tmp-ext  exist, the log collection is still not finishedl
   -  # cd collect-diagnostics-out
   -  # ls -la  ---> The log is named as "PMTT1A000002-diagnostics-2013-07-31-08.35.51.tar.gz"

3. #cluster status ---> Show overall cluster status;
4. #rebuild status ---> Show sync status/progress;
5. #cluster summary ---> Show overall status of VPLEX clusters;
6. Shutdown/reboot a VPLEX cluster by shutdown/reboot directors:

   - cd /engines/engine-2-1/directors/;
   - VPlexcli:/engines/engine-2-1/directors> ls
     ::

       director-2-1-A  director-2-1-B

   - cd director-2-1-A/B
   - shutdown -f
   - cluster status
   - reboot

7. VPlexcli:/> ll /engines/\*\*/ports ---> Show all FE, BE ports wwn
8. VPlexcli:/> health-check ---> Check overall health status, including meta and log status;
9. VPlexcli:/> ll /engines/engine-1-1/directors/\*/hardware/ports ---> List port status(FE/BE/WAN) for engine-1-1
10. VPlexcli:/> connectivity validate-wan-com

    ::

      connectivity: PARTIAL

      port-group-3 - ERROR - Connectivity errors were found for the following com ports:
      /engines/engine-1-1/directors/director-1-1-B/hardware/ports/B4-FC03 ->
              Missing all expected connectivity.
      /engines/engine-2-1/directors/director-2-1-A/hardware/ports/A4-FC03 ->
              Missing connectivity to /engines/engine-1-1/directors/director-1-1-B/hardware/ports/B4-FC03
      /engines/engine-2-1/directors/director-2-1-B/hardware/ports/B4-FC03 ->
              Missing connectivity to /engines/engine-1-1/directors/director-1-1-B/hardware/ports/B4-FC03

11. VPlexcli:/clusters> export -> Control export such as initiator discovery control, etc.

    - export initiator-port discovery                Discovers initiator ports on the front-end fabric.
    - export initiator-port register                 Registers an initiator-port and associates one WWN pair with it.
    - export initiator-port register-host            Reads host port WWNs [with optional node WWNs] and names from a host

12. Name Mapping File Tempalte:

    ::

      Generic storage-volumes
      VPD83T3:600601602230290038063d22dc5fe411 Jerry_RP_VNX116129_10G_1
      VPD83T3:600601602230290039063d22dc5fe411 Jerry_RP_VNX116129_10G_2
