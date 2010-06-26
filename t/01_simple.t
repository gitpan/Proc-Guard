use strict;
use warnings;
use Test::More;
use Test::Requires qw/File::Which Test::TCP/;
use Proc::Guard;

my $memcached_bin = File::Which::which('memcached');
plan skip_all => "This test requires memcached binary" unless $memcached_bin;

my $port = Test::TCP::empty_port();
my $proc = proc_guard($memcached_bin, '-p', $port);
ok $proc->pid, 'memcached: ' . $proc->pid;
Test::TCP::wait_port($port);

my $sock = IO::Socket::INET->new(
		      PeerAddr => '127.0.0.1',
		      PeerPort => $port,
		      Proto => 'tcp',
) or die $!;
print $sock "version\r\n";
my $version = <$sock>;
like $version, qr/VERSION \d\.\d\.\d/;
note $version;

done_testing;
