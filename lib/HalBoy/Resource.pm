package HalBoy::Resource;

use Moo;
use HalBoy::Link;
use HalBoy::Utils;

has client => (is => 'ro');

has base_uri => ( is => 'rw' );

has props    => ( %HalBoy::Utils::hash_ref_attr );
sub has_props { return !!keys %{ $_[0]->props || {} } }
has links    => ( %HalBoy::Utils::hash_ref_attr );
sub has_links { return !!keys %{ $_[0]->links || {} } }
has embedded => ( %HalBoy::Utils::hash_ref_attr );
sub has_embedded { return !!keys %{ $_[0]->embedded || {} } }

sub from_json {
    my $self = shift;
    my $json = shift;

    $self->links( HalBoy::Utils->transform_hash(
        delete $json->{'_links'},
        sub {
            my $rtype = shift;
            return map HalBoy::Link->new(
                resource => $self,
                relation => $rtype,
            )->from_json($_), @_;
        },
    ) );
    $self->embedded( HalBoy::Utils->transform_hash(
        delete $json->{'_embedded'},
        sub {
            my $rtype = shift;
            my $uri = $self->base_uri;
            my $client = $self->client;
            return map $self->new( client => $client, base_uri => $uri )->from_json($_),
                @_
            ;
        },
    ) );
    $self->props( $json );
    return $self;
}

sub to_json {
    my $self = shift;

    my %res = %{ $self->props || {} };

    $res{'_links'} = HalBoy::Utils->transform_hash(
        $self->links, sub { shift; return map $_->to_json, @_ }
    ) if $self->has_links;
    $res{'_embedded'} = HalBoy::Utils->transform_hash(
        $self->embedded, sub { shift; return map $_->to_json, @_ }
    ) if $self->has_embedded;

    return \%res;
}

sub to_html {
    my $self = shift;

    require JSON;

    my $esc = \&HalBoy::Utils::escape_html;

    my $res = '';
    $res .= '<div class="resource">';

    if ( $self->has_props ) {
        $res .= '<h2>Properties</h2>';
        $res .= '<pre class="prettyprint properties"><code class="language-js">';
        $res .= $esc->( JSON::to_json($self->props || {}, {utf8 => 1, pretty => 1}) );
        $res .= '</code></pre>';
    }

    if ( $self->has_links ) {
        $res .= '<h2>Links</h2>';
        HalBoy::Utils->transform_hash(
            $self->links, sub {
                my ($type, @links) = @_;
                $res .= '<h3>'. $esc->( $type ) .'</h3>';

                $res .= '<ul class="links">';
                foreach my $l ( @links ) {
                    $res .= '<li>';
                    $res .= $l->to_html;
                    $res .= '</li>';
                }
                $res .= '</ul>';
                return ();
            },
        );
    }
    if ( $self->has_embedded ) {
        $res .= '<h2>Objects</h2>';
        HalBoy::Utils->transform_hash(
            $self->links, sub {
                my ($type, @objs) = @_;
                $res .= '<h3>'. $esc->( $type ) .'</h3>';

                $res .= '<ul class="links">';
                foreach my $o ( @objs ) {
                    $res .= '<li>';
                    $res .= $o->to_html;
                    $res .= '</li>';
                }
                $res .= '</ul>';
                return ();
            },
        );
    }
    $res .= '</div>';
    return $res;
}

1;
