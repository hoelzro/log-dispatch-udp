## no critic (RequireUseStrict)
package Log::Dispatch::UDP;

## use critic (RequireUseStrict)
use strict;
use warnings;
use parent 'Log::Dispatch::Output';

use Carp qw(croak);
use IO::Socket::INET;
use Socket qw(SOCK_DGRAM);
use Readonly;

use namespace::clean;

Readonly::Array my @VALID_PARAMS => qw(host port);

sub new {
    my ( $class, %params ) = @_;

    my $host = $params{'host'} or croak 'host parameter required';
    my $port = $params{'port'} or croak 'port parameter required';

    my $sock = IO::Socket::INET->new(
        Proto    => 'udp',
        Type     => SOCK_DGRAM,
        PeerAddr => $host,
        PeerPort => $port,
    );

    croak $! unless $sock;

    my $self = bless {
        sock => $sock,
    }, $class;

    $self->_basic_init(%params);

    return $self;
}

sub log_message {
    my ( $self, %params ) = @_;

    my $message = $params{'message'};
    my $sock    = $self->{'sock'};

    $sock->send($message, 0);
}

1;

__END__

# ABSTRACT: Log messages to a remote UDP socket

=head1 SYNOPSIS

  use Log::Dispatch;

  my log = Log::Dispatch->new(
    outputs => [
        [
            'UDP'
            host      => $destination_host,
            port      => $destination_port,
            min_level => 'info',
        ],
    ],
  );

  $log->info('my message');

=head1 DESCRIPTION

This class can be used to write messages to a UDP socket
listening on some remote host.  The datagrams themselves
contain only the messages (there's no real structure to them),
so you can easily listen in using netcat.

=head1 SEE ALSO

L<Log::Dispatch>

=cut
