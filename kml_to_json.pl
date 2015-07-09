#!/usr/bin/perl

#USAGE: ./kml_to_json.pl <kml filename>
# if things that look like lines are found, outputs as json format for drawtools
# it things that look like points are found, outputs as intel link
# eventually plan to add iitc bookmark output for points and stock intel output for lines

use Data::Dumper;
use XML::Simple;
use JSON::PP;

my %points;
my %lines;

my $kmlref = XMLin($ARGV[0]);

my %kmlhash = %{$kmlref->{Document}->{Folder}};

recurse (\%kmlhash, ""); #exports points and lines

if(!%points && !%lines){
  print "Sorry, no coordinates found in KML\n";
}else{
  if(%lines){
    print "Lines Found: drawtools below...\n";
    my @jsonarray;
    foreach my $key (keys %lines){
      my %minihash;
      $minihash{"type"} = "polyline";
      $minihash{"color"} = "#a24ac3";
      my @coords = split /\|/, $lines{$key};
      foreach my $pair (@coords){
        my ($lat,$lng)=split /,/, $pair;
        my %coordhash;
        $coordhash{"lat"} = $lat;
        $coordhash{"lng"} = $lng;
        push(@{$minihash{"latLngs"}}, \%coordhash); 
      }
      push(@jsonarray, \%minihash);
    }
    #print Dumper @jsonarray;
    print JSON::PP->new->encode(\@jsonarray);
    print "\n\n";
  }
  if(%points){
    print "Points Found: intel links below...\n";
    foreach my $key (keys %points){
      my ($lat,$lng) = split /,/, $points{$key};
      print "$key: https://www.ingress.com/intel?ll=$lat,$lng&z=15\n";
    }
  }
}




sub recurse {
 my ($ref,$trail) = @_;
 my %hash = %$ref;
 foreach my $key (keys %hash){
   if($key eq "coordinates"){
     my @data = split /\s+/, $ref->{$key};
     if ($#data == 0) { #single point
       my ($lon, $lat, @rest) = split /,/, $data[0];
       $points{$trail} = "$lat,$lon";
     }else{ #line
       foreach my $point (@data){
         my ($lon, $lat, @rest) = split /,/, $point;
         $lines{$trail} .= "$lat,$lon|";
       }
     }
 
   }else{
     recurse($ref->{$key}, "$trail/$key");
   }
 } 

}


