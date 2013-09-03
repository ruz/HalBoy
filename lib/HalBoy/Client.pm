use v5.10;
use strict;
use warnings;

package HalBoy::Client;

use Moo;
use JSON qw(decode_json);

use HalBoy::Resource;

has ua => ( is => 'ro' );

sub resource {
    my $self = shift;
    my $uri = shift;

    my $res = $self->ua->get($uri);
    return HalBoy::Resource->new(
        client => $self,
        base_uri => $uri
    )->from_json( decode_json( $res->content ) );
}

1;