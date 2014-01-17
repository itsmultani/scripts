#!/usr/local/bin/perl

use strict;

my @fileNames = `ls ~/access_log/`;
my @files = ();

foreach(@fileNames) {
	chomp;
	push @files, $_ if /clean/;
}


foreach(@files) {
	open FH, $_ or die 'can not open file: ' . $_;
	my @names = split('\.', $_);
	my $cleanName = @names[0]."_newClean";
	
	open FW, '>', $cleanName;
	print "proccessing $_, prepare to write to $cleanName\n";
	while(<FH>) {
		my $url = cleanUrl($_);
		print FW "$url";
	}
	close FH;
	close FW;
}

sub cleanUrl {
	my ($url) = @_;
	next if ($url =~ /\/akamai/);
	if (
		$url =~ /search_by_vql/ ||
	    $url =~ /get_details/
	) {
		$url =~ s/\?[^\s]*//g;
	} elsif (
		$url =~ /get_detail/ || 
		$url =~ /update/ || 
		$url =~ /purge/ || 
		$url =~ /close/ ||
		$url =~ /shelve/ ||
		$url =~ /delete/ ||
		$url =~ /get/ ||
		$url =~ /publish_draft/
	) {
		$url =~ s/\/[\d]*/\//g;
	}
	return $url;
}
