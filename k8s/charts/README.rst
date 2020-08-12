About
=======

Customized and self-packaged charts.

Charts
-------

List of charts.

telegraf
~~~~~~~~~~

This is a customized Helm chart based on the official influxdata/telegraf (version 1.7.21).

Changes:

- Upgrade Telegraf from 1.14 to 1.15.2;
- Add support for the sFlow input plugin (UDP port exposure through service). The values for the sFlow input plugin should be specified as below:

  ::

    inputs:
      - sflow:
          service_address: "udp://:6343"
