#!/usr/bin/perl
# for exporting iitc bookmarks to kml placemarks for usage on my maps
# usage ./bookmarks_to_kml.pl <file_containing ittc bookmark output>
# 
# this program does no integrity checking on input.  use at your own risk 

use JSON::PP;

open FH, $ARGV[0];

$text = <FH>;
$data = decode_json $text;

print qq ^<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <Style id="bluedot">
    <IconStyle>
      <Icon>
        <href>http://maps.google.com/mapfiles/ms/icons/blue-dot.png</href>
      </Icon>
    </IconStyle>
  </Style>
^;

foreach $folder (keys %{$data->{portals}}){
  foreach $bookmark (keys %{$data->{portals}->{$folder}->{bkmrk}}){
    ($lat,$lng) = split /\,/, $data->{portals}->{$folder}->{bkmrk}->{$bookmark}->{latlng};
    $label = $data->{portals}->{$folder}->{bkmrk}->{$bookmark}->{label};
    $guid = $data->{portals}->{$folder}->{bkmrk}->{$bookmark}->{guid};
    print qq ^
  <Placemark>
    <name>$label</name>
    <description>$guid</description>
    <styleUrl>#bluedot</styleUrl>
    <color>7fff0000</color>
    <Point>
      <coordinates>$lng,$lat,0</coordinates>
    </Point>
  </Placemark> ^;

  }
}



print qq ^
</Document>
</kml>

^;
