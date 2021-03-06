<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<databrowser>
    <title>Noise signals</title>
    <save_changes>true</save_changes>
    <show_legend>true</show_legend>
    <show_toolbar>true</show_toolbar>
    <grid>false</grid>
    <scroll>true</scroll>
    <update_period>3.0</update_period>
    <scroll_step>5</scroll_step>
    <start>-30.08 min</start>
    <end>now</end>
    <archive_rescale>NONE</archive_rescale>
    <background>
        <red>235</red>
        <green>235</green>
        <blue>235</blue>
    </background>
    <title_font>DejaVu Sans Mono|36|1</title_font>
    <label_font>DejaVu Sans Mono|26|1</label_font>
    <scale_font>DejaVu Sans Mono|26|0</scale_font>
    <legend_font>DejaVu Sans Mono|20|0</legend_font>
    <axes>
        <axis>
            <visible>false</visible>
            <name>sim://noise(100,125,1)</name>
            <use_axis_name>false</use_axis_name>
            <use_trace_names>true</use_trace_names>
            <right>false</right>
            <color>
                <red>21</red>
                <green>21</green>
                <blue>196</blue>
            </color>
            <min>100.0</min>
            <max>610.0</max>
            <grid>false</grid>
            <autoscale>false</autoscale>
            <log_scale>false</log_scale>
        </axis>
        <axis>
            <visible>true</visible>
            <name>sim://noise(600,610,1)</name>
            <use_axis_name>false</use_axis_name>
            <use_trace_names>true</use_trace_names>
            <right>false</right>
            <color>
                <red>242</red>
                <green>26</green>
                <blue>26</blue>
            </color>
            <min>100.0</min>
            <max>610.0</max>
            <grid>false</grid>
            <autoscale>false</autoscale>
            <log_scale>false</log_scale>
        </axis>
    </axes>
    <annotations>
    </annotations>
    <pvlist>
        <pv>
            <display_name>sim://noise(100,125,1)</display_name>
            <visible>true</visible>
            <name>sim://noise(100,125,1)</name>
            <axis>1</axis>
            <color>
                <red>21</red>
                <green>21</green>
                <blue>196</blue>
            </color>
            <trace_type>AREA</trace_type>
            <linewidth>2</linewidth>
            <point_type>NONE</point_type>
            <point_size>2</point_size>
            <waveform_index>0</waveform_index>
            <period>0.0</period>
            <ring_size>5000</ring_size>
            <request>OPTIMIZED</request>
            <archive>
                <name>Local Archive RDB</name>
                <url>jdbc:postgresql://localhost/css_archive_3_0_0</url>
                <key>1</key>
            </archive>
            <archive>
                <name>Snapshot RDB</name>
                <url>jdbc:postgresql://4504ds-srv-0008.codac.iter.org/css_archive_3_0_0</url>
                <key>2</key>
            </archive>
        </pv>
        <pv>
            <display_name>sim://noise(600,610,1)</display_name>
            <visible>true</visible>
            <name>sim://noise(600,610,1)</name>
            <axis>1</axis>
            <color>
                <red>242</red>
                <green>26</green>
                <blue>26</blue>
            </color>
            <trace_type>AREA</trace_type>
            <linewidth>2</linewidth>
            <point_type>NONE</point_type>
            <point_size>2</point_size>
            <waveform_index>0</waveform_index>
            <period>0.0</period>
            <ring_size>5000</ring_size>
            <request>OPTIMIZED</request>
            <archive>
                <name>Local Archive RDB</name>
                <url>jdbc:postgresql://localhost/css_archive_3_0_0</url>
                <key>1</key>
            </archive>
            <archive>
                <name>Snapshot RDB</name>
                <url>jdbc:postgresql://4504ds-srv-0008.codac.iter.org/css_archive_3_0_0</url>
                <key>2</key>
            </archive>
        </pv>
    </pvlist>
</databrowser>