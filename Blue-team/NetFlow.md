# Analyzing NetFlow Data with Nfdump

Once data collection is set up, you can analyze the NetFlow data using nfdump. The basic syntax for nfdump is:

```nfdump -r <file> [options]```

1. Date: This column shows the date when the flow was first observed. For example, "2015-11-24" indicates that the flow started on November 24, 2015.
2. Example: For the first row, the date is "2015-11-24".
first seen: This column displays the exact time when the flow was first observed, down to milliseconds (HH:MM:SS.mmm format).
3. Example: For the first row, the flow was first seen at "18:18:59.504".
Duration: This column shows how long the flow lasted, formatted as HH:MM:SS.mmm.
4. Example: The first row shows a duration of "00:00:00.108", meaning the flow lasted for 0.108 seconds.
Proto: This column indicates the protocol used for the flow, such as UDP or TCP.
5. Example: The first row has "UDP", indicating that the flow used the User Datagram Protocol.
Src IP Addr:Port: This column shows the source IP address and port number of the flow. It identifies where the flow originated.
6. Example: In the first row, the source is "10.1.25.119:50575".
Dst IP Addr:Port: This column displays the destination IP address and port number, indicating where the flow was sent.
7. Example: In the first row, the destination is "224.0.0.252:5355".
Packets: This column lists the total number of packets transmitted during the flow.
8. Example: The first row shows "2" packets were transmitted.
Bytes: This column shows the total number of bytes transmitted during the flow.
9. Example: The first row indicates "104" bytes were transmitted.
Flows: This column indicates the number of individual flows that were aggregated to form this entry.
Example: The first row shows "1" flow was aggregated for this entry.

Note:
In some versions of `nfdump`, certain columns, such as "Duration," may not be shown by default. To ensure that all possible columns are displayed, you can add `-o extended` option when running `nfdump`. This option will provide a more detailed view that might be relevant to your analysis.

```nfdump -r <file> -o extended```

Common tasks you can perform with nfdump
Filtering Flows

Nfdump allows you to filter flows based on various criteria. For example, to filter flows by source IP address:

```nfdump -r nfcapd.202401011200 -A srcip -n 10```

This command will aggregate flows by source IP and display the top 10.
Identifying Top Talkers

To identify the top talkers in your network, you can use:

```nfdump -r nfcapd.202401011200 -s record/bytes -n 10```

This will sort the flows by the number of bytes and display the top 10.
Analyzing Traffic Over Time

To analyze traffic patterns over time, use the following command to generate a time series report:

```nfdump -r nfcapd.202401011200 -s record/bytes -t 10```

This will display the traffic in 10-minute intervals.