#!/usr/bin/perl

#
# This code is stolen from SHA-1.1/sha_driver.pl
#

use strict;
use warnings;

use Getopt::Std;
use Crypt::RIPEMD160;

sub do_test
{
    my ($label, $str, $expect) = @_;
    my $ripemd160 = Crypt::RIPEMD160->new;
    $ripemd160->add($str);
    print "\n";
    print "$label:\n";
    print "EXPECT:   $expect\n";
    print "RESULT 1: " . $ripemd160->hexdigest() . "\n";
    print "RESULT 2: " . $ripemd160->hexhash($str) . "\n";

# comment out the following line if you run out of memory
    my $run_big_test = 1;
    if (defined($run_big_test)) {
	$ripemd160->reset();
	my @tmp = split(//, $str);
	foreach my $c (@tmp) {
	    $ripemd160->add($c);
	}
	print "RESULT 3: " . $ripemd160->hexdigest() . "\n";
    }
}

my %opt;
getopts('s:x', \%opt);

my $ripemd160 = Crypt::RIPEMD160->new;

if (defined($opt{s})) {
    $ripemd160->add($opt{s});
    print("RIPEMD160(\"$opt{s}\") = " . $ripemd160->hexdigest() . "\n");
} elsif ($opt{x}) {
    print "Running RIPEMD-160 test vectors:\n";
    print "\n";
    do_test("test1 (\"abc\")",
	    "abc",
	    "8eb208f7e05d987a9b044a8e98c6b087f15a0bfc");

    do_test("test2 (\"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq\")",
	    "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
	    "12a053384a9c0c88e405a06c27dcf49ada62eb2b");

    do_test("test3 (\"a\" x 1000000)",
	    "a" x 1000000,
	    "52783243c1697bdbe16d37f97f68f08325dc1528");
} else {
    if (@ARGV) {
	foreach my $file (@ARGV) {
	    open(my $fh, '<', $file) or die "Can't open file '$file' ($!)\n";
	    $ripemd160->reset();
	    $ripemd160->addfile($fh);
	    print "RIPEMD160($file) = " . $ripemd160->hexdigest() . "\n";
	    close($fh);
	}
    } else {
	$ripemd160->reset();
	$ripemd160->addfile(\*STDIN);
	print "RIPEMD160(STDIN) = " . $ripemd160->hexdigest() . "\n";
    }
}

exit 0;
