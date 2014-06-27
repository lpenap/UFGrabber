#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;
use Image::Grab;
use Image::Magick;
use Time::Local;
use POSIX 'strftime';

# Config

my $startDate = "2011-01-01";
my $endDate   = "2014-06-26";
my $errorFile = "error.log";

# Main cicle

my $ext   = ".gif";
my $url   = "http://ars.userfriendly.org/cartoons/?id=";
my $start = date2epoch($startDate);
my $end   = date2epoch($endDate);
my $curr  = $start;
printHeader();
$|++;
while ( $curr <= $end ) {

	# fetching the current binary image file
	my $picUrl = $url . strftime "%Y%m%d", localtime($curr);
	my $pic = fetchImg ($picUrl);
	if ($pic->image) {

		# saving the image with a proper filename
		my $imageFile = strftime "uf%Y_%m_%d", localtime($curr);
		open( IMAGE, ">" . $imageFile . "_0" . $ext );
		print IMAGE $pic->image;
		close IMAGE;

		# extract frames for image (if any)
		process($imageFile);
		print ".";
	} else {
		
		# an error ocurred, log the error and continue
		print "X";
		appendLog (strftime "ERROR: uf%Y_%m_%d : ". $picUrl, localtime($curr));
	}

	# advance the next day and sleep [2, 6] secs
	$curr += 24 * 60 * 60;
	sleep( int( rand(5) ) + 2 );
}
print "\n";

# Subrutines

sub appendLog {
	my $entry = shift;
	use Time::localtime;
	my $tm = localtime;
	my $date = sprintf("%04d-%02d-%02d", $tm->year+1900, ($tm->mon)+1, $tm->mday);
	my $time = sprintf(" %02d:%02d:%02d ", $tm->hour, $tm->min, $tm->sec);
	open (LOG, ">>" . $errorFile);
	print LOG $date . $time . $entry . "\n";
	close LOG;
}

sub printHeader {
	print "UFGrabber v1.0 by lpenap\@gmail.com\n";
	print "start date: " . $startDate . "\n";
	print "end date:   " . $endDate . "\n";
	print "fetching    ";
}

sub fetchImg {
	my $url     = shift;
	my $imgPath = parsePage( get $url);
	my $pic     = new Image::Grab;
	$pic->url( $imgPath . $ext );
	$pic->grab;
	return $pic;
}

sub parsePage {
	my $content = shift;
	my $imgUrl  = '';
	if ( $content =~ m/(http:\/\/www.userfriendly.org\/cartoons\/archives\/)(\d\d\w\w\w)\/(\w+\d+).gif/) {
		$imgUrl = $1 . $2 . "/" . $3;
	}
	return $imgUrl;
}

sub process {
	my $file = shift;
	my $p    = new Image::Magick;
	$p->Read( $file . "_0" . $ext );
	for ( my $x = 1 ; $p->[$x] ; $x++ ) {
		$p->[$x]->Write( $file . "_" . $x . $ext );
	}
}

sub date2epoch {
	my ( $y, $m, $d ) = split /-/, shift;
	return timelocal( 0, 0, 12, $d, $m - 1, $y - 1900 );
}
