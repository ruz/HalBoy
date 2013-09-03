use strict;
use warnings;

use Test::More;

use_ok('HalBoy::Resource');
use JSON qw();

my $json_data = JSON::from_json(<<'END');
   {
     "_links": {
       "self": { "href": "/orders" },
       "next": { "href": "/orders?page=2" },
       "find": { "href": "/orders{?id}", "templated": true }
     },
     "_embedded": {
       "orders": [{
           "_links": {
             "self": { "href": "/orders/123" },
             "basket": { "href": "/baskets/98712" },
             "customer": { "href": "/customers/7809" }
           },
           "total": 30.00,
           "currency": "USD",
           "status": "shipped"
         },{
           "_links": {
             "self": { "href": "/orders/124" },
             "basket": { "href": "/baskets/97213" },
             "customer": { "href": "/customers/12369" }
           },
           "total": 20.00,
           "currency": "USD",
           "status": "processing"
       }]
     },
     "currentlyProcessing": 14,
     "shippedToday": 20
   }
END

my $resource = HalBoy::Resource->new->from_json( $json_data );
use Data::Dumper::Concise;
print STDERR Dumper($resource);

my $json_res = $resource->to_json;
print STDERR Dumper($json_res);

print STDERR $resource->to_html, "\n";

done_testing;