package app;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Serializer::JSON;

set serializer => 'JSON';

our $VERSION = '0.1';

get '/' => sub {
     template 'index';
};

get '/index.html' => sub {
     template 'index';
};

get '/books' => sub {
     content_type 'application/json';
     my $books = {};
     return to_json($books);
};

get '/authors' => sub {
     content_type 'application/json';
     my $authors = {};
     return to_json($authors);
};


true;
