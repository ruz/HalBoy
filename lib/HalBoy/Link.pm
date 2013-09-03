package HalBoy::Link;
use v5.10;
use Moo;

has resource => ( is => 'rw' );
has relation => ( is => 'rw' );

has href => (is => 'rw');

has type => (is => 'rw');
has name => (is => 'rw');
has title => (is => 'rw');

has templated => (is => 'rw');
has profile => (is => 'rw');
has hreflan => (is => 'rw');

has deprecation => (is => 'rw');

sub from_json {
    my $self = shift;
    my $json = shift;

    $self->$_( $json->{$_} ) foreach grep exists $json->{$_},
        qw(href type name title templated relation profile hreflan deprecation);
    return $self;
}

sub to_json {
    my $self = shift;
    my %res = (
        href => $self->href,
        type => $self->type,
        name => $self->name,
        title => $self->title,
        templated => $self->templated? \1 : undef,
        profile => $self->profile,
        hreflan => $self->hreflan,
        deprecation => $self->deprecation,
    );
    delete @res{ grep !defined $res{$_}, keys %res };
    return \%res;
}

sub to_html {
    my $self = shift;

    my $esc = \&HalBoy::Utils::escape_html;

    my $res = '';
    $res .= '<a href="'. $esc->( $self->href ) .'"'.'>';
    $res .= $esc->($self->title // $self->name // $self->href );
    $res .= '</a>';
    return $res;
}

1;
