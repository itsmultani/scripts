#!/usr/local/bin/perl
use strict;

my $timeSummary = {};
my $urlSummary = {};

my @fileNames = `ls ~/access_log/`;
my @files = ();

foreach(@fileNames) {
	next if not /newClean/;
	chomp;
	open FH, '/homes/multani/access_log/'.$_ or die 'can not open file';

	open FW, '>', '/homes/multani/access_log/cleanUrl/'.$_.'_result';
	print 'start proccessing ' . $_ . "\n";
	while (<FH>) {
		my @elements = split ' ', $_;

		my $time = @elements[3] . ':' . @elements[4];
		$time =~ s/[\[\]]//g;
		my $url = @elements[6];

		my $timeSet = getTime($time);
		my $urlPrefix = getUrlPrefix($url);

		my $timeIndex = $timeSet->{'mon'} . '-' . $timeSet->{'day'} . '-' . $timeSet->{'hour'};

		if (!$timeSummary->{$timeIndex}) {
			$timeSummary->{$timeIndex} = 1;
		} else {
			$timeSummary->{$timeIndex} += 1;
		}

		if (!$urlSummary->{$urlPrefix}) {
			$urlSummary->{$urlPrefix} = 1
		} else {
			$urlSummary->{$urlPrefix} += 1
		}
	}
	
	foreach my $key (sort(keys $timeSummary)) {
		print FW $key . " " . $timeSummary->{$key} . "\n";
	}
	print FW "\n";
	foreach my $key (keys $urlSummary) {
		printf FW "%-18s %s\n", $key, $urlSummary->{$key};
	}

	$timeSummary = {};
	$urlSummary ={};
	close FH;
	close FW;
}




sub getTime {
	my ($time) = @_;
	my $timeSet = {};
	my @tmp = split '/', $time;
	$timeSet->{'day'} = @tmp[0];
	$timeSet->{'mon'} = @tmp[1];

	my @tmp2 = split ':', @tmp[2];
	$timeSet->{'hour'} = @tmp2[1];
	$timeSet->{'min'} = @tmp2[2];
	$timeSet->{'sec'} = @tmp2[3];
	$timeSet->{'timezone'} = @tmp2[4];
	
	return $timeSet;
}

sub getUrlPrefix {
	my ($url) = @_;
	my @tmp = split '/', $url;
	chomp(@tmp[4]);
	return @tmp[4];
}
