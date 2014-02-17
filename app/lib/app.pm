package app;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Serializer::JSON;
use Dancer::Plugin::DBIC qw(schema resultset rset);
use Dancer::Template::TemplateToolkit;
use Data::Dumper;
use Try::Tiny;

set serializer => 'JSON';

my $bookstore_schema = schema 'root';
my $status_ok = 1;

get '/' => sub {
     template 'index';
};

get '/index.html' => sub {
     template 'index';
};

##API Interface 

get '/api/books' => sub {
    try {
          content_type 'application/json';
          my $books =$bookstore_schema->resultset('Book')->search();
          #$books->result_class('DBIx::Class::ResultClass::HashRefInflator');
          return $books;
    }
    catch {
        error $_;
        send_error({ error => $_, status => "Books not found" });
    };

};

post '/api/books' => sub {
    try {
         content_type 'application/json';
         my $params = request->params;
         $bookstore_schema->resultset('Book')->create({
            title           => $params->{'title'},
            edition_date    => $params->{'edition_date'},
            isbn_no         => $params->{'isbn_no'},
            author_id       => $params->{'author_id'},
         });

         return { 
                 status => "OK. Posted successfully",
         };
    }
    catch {
            error $_;
            send_error({ 
                         error => $_, 
                         status => "Could not post" 
            });
    };
};

del '/api/books/:id' => sub {
    my $params;
    try {
          content_type 'application/json';
          my $book = $bookstore_schema->resultset('Book')->search({
             id    => param('id'),
          });
        
          my $books_amount = $book->count;
          $book->delete if $books_amount;

          return { 
                  status => "OK",
                  deleted_rows => $books_amount,
          };
    }
    catch {
           error $_;
           send_error({ 
                       error => $_, 
                       status => "Could not delete",
           });
    };
};

get '/api/books/:id' => sub {
    try {
         content_type 'application/json';
         my $params = request->params;
         my $book = $bookstore_schema->resultset('Book')->search({
            id              => $params->{'id'},
         });
         return $book;
    }
    catch {
           error $_;
           send_error({ 
                       error => $_, 
                       status => "Book not found" 
           });
    };

};

put '/api/books/:id' => sub {
    try {
         content_type 'application/json';
         my $params = request->params;
         my $book =$bookstore_schema->resultset('Book')->search({ 
            id    => $params->{'id'},
         });

         my $hash_params = {};

         $hash_params->{'title'} = $params->{'title'} if $params->{'title'};
         $hash_params->{'edition_date'} = $params->{'edition_date'} if $params->{'edition_date'};
         $hash_params->{'isbn_no'} = $params->{'isbn_no'} if $params->{'isbn_no'};
         $hash_params->{'author_id'} = $params->{'author_id'} if $params->{'author_id'};
     
         my $update_status = $book->update($hash_params);
         
         if ($update_status eq $status_ok){ 
            return { 
                    status => "OK. Updated",
            };
         }
         else {
                die "Error";
         }
    }
    catch {
           error $_;
           send_error({ 
                       error => $_, 
                       status => "Book could not be updated" 
           });
    };

};



#End user functions

get '/authors' => sub {
    my @results = ();
    @results = _search_authors();
    template 'authors', { 
                         results => \@results,
    };
};


get '/authors/:id' => sub {
    my @author = ();
    my @books = ();
    my $author_id = params->{id};
    @author = _search_author ($author_id);
    @books = _search_books_by_author ($author_id);
    
    template 'author', { 
                         author => \@author,
                         books => \@books,
    };
};

get '/books' => sub {
    my @results = ();
    @results = _search_books();
    template 'books', { 
                         results => \@results,
    };
};

get '/books/:id' => sub {
    my @results = ();
    my $book_id = params->{id};
    @results = _search_book($book_id);
    

#    return Dumper(@results);
    template 'book', { 
                         results => \@results,
    };
};


# subroutines section

sub _search_authors {
    my @authors = $bookstore_schema->resultset('Author')->search(
      {},
      {
        order_by => { -asc => 'surname' },
      }
    );
    return @authors;
};


sub _search_author {
    my ($author_id) = @_;
    my @author = $bookstore_schema->resultset('Author')->search(
      {
        'id' => $author_id,
      },
    );
    return @author;
};

sub _search_books_by_author {
    my ($author_id) = @_;
    my @books = $bookstore_schema->resultset('Book')->search(
      {
        'author_id' => $author_id,
      },
    );
    return @books;
};

sub _search_books {
    my @books = $bookstore_schema->resultset('Book')->search(
      {},
      {
        order_by => { -asc => 'title' },
      }
    );
    return @books;
};


sub _search_book {
    my ($book_id) = @_;

    my @result = $bookstore_schema->resultset('Author')->search(
      {
        'books.id' => $book_id,
      },
      {
        '+columns' => ['books.title'],
        join => 'books',
      }
    );
    return @result;
};


true;
