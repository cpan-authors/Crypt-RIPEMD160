#!perl

use strict;
use warnings;

use Test::More;
use Config;
use Scalar::Util 'blessed';

use Crypt::RIPEMD160;
use Crypt::RIPEMD160::MAC;

subtest 'CLONE_SKIP declared' => sub {
    ok(Crypt::RIPEMD160->can('CLONE_SKIP'),
       'Crypt::RIPEMD160 has CLONE_SKIP');
    is(Crypt::RIPEMD160->CLONE_SKIP, 1,
       'CLONE_SKIP returns 1');

    ok(Crypt::RIPEMD160::MAC->can('CLONE_SKIP'),
       'Crypt::RIPEMD160::MAC has CLONE_SKIP');
    is(Crypt::RIPEMD160::MAC->CLONE_SKIP, 1,
       'MAC CLONE_SKIP returns 1');
};

SKIP: {
    skip 'threads not available', 1
        unless $Config{useithreads} && eval { require threads; 1 };

    subtest 'objects not cloned into child thread' => sub {
        my $ctx = Crypt::RIPEMD160->new;
        $ctx->add('abc');

        my $mac = Crypt::RIPEMD160::MAC->new('key');
        $mac->add('data');

        # List context so thread return values are preserved as a list
        my ($thr) = threads->create(sub {
            my @results;

            push @results, blessed($ctx) ? 0 : 1;
            push @results, blessed($mac) ? 0 : 1;

            my $child_ctx = Crypt::RIPEMD160->new;
            $child_ctx->add('abc');
            push @results, unpack("H*", $child_ctx->digest);

            my $child_mac = Crypt::RIPEMD160::MAC->new('key');
            $child_mac->add('data');
            push @results, length($child_mac->mac);

            return @results;
        });

        my @results = $thr->join;
        is($results[0], 1, 'RIPEMD160 object not blessed in child (CLONE_SKIP)');
        is($results[1], 1, 'MAC object not blessed in child (CLONE_SKIP)');
        is($results[2], '8eb208f7e05d987a9b044a8e98c6b087f15a0bfc',
           'new RIPEMD160 object works in child thread');
        is($results[3], 20, 'new MAC object works in child thread');

        is(unpack("H*", $ctx->digest),
           '8eb208f7e05d987a9b044a8e98c6b087f15a0bfc',
           'parent RIPEMD160 object unaffected');
    };
}

done_testing;
