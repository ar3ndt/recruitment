use Test::More tests => 6;
use strict;
use warnings;

# the order is important
use app;
use Dancer::Test;

route_exists [GET => '/books'], 'a route handler is defined for /books';
route_exists [GET => '/authors'], 'a route handler is defined for /authors';

route_exists [POST => '/api/books'], 'a route handler is defined for /api/books';
route_exists [POST => '/api/authors'], 'a route handler is defined for /api/authors';

response_status_is ['GET' => '/books'], 200, 'response status is 200 for /';
response_status_is ['GET' => '/authors'], 200, 'response status is 200 for /';
