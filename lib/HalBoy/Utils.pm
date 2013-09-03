use strict;
use warnings;

package HalBoy::Utils;

our %hash_ref_attr = (
    is => 'rw',
    clearer => 1,
    coerce => sub { $_[0] || {}  },
    default => sub { {} },
);

sub transform_hash {
    my $self = shift;
    my $hash = shift or return undef;
    my $cb = shift;

    my %res;
    foreach my $key ( sort keys %$hash ) {
        my $list = $hash->{$key};
        $res{ $key } = ref $list eq 'ARRAY'
            ? [ $cb->($key, @$list) ]
            : ($cb->($key, $list))[0]
        ;
    }
    return \%res;
}

sub escape_html {
    my $v = shift;
    $v =~ s/&/&#38;/g;
    $v =~ s/</&lt;/g;
    $v =~ s/>/&gt;/g;
    $v =~ s/"/&#34;/g;
    $v =~ s/'/&#39;/g;
    return $v;
}

1;
