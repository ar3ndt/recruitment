package app;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Serializer::JSON;
use Dancer::Plugin::DBIC qw(schema resultset);
use Dancer::Template::TemplateToolkit;
#use Data::Dumper;
use Try::Tiny;

set serializer => 'JSON';

my $bookstore_schema = schema 'root';
my $status_ok = 1;
my $status_not_ok = 0;

get '/' => sub {
     redirect '/index.html';
};

get '/index.html' => sub {
     template 'index';
};

##START## API Interface 

##START## API for BOOKS
get '/api/books' => sub {
    try {
          content_type 'application/json';
          my @books =$bookstore_schema->resultset('Book')->search();

          my $books_hash={};
          foreach my $book ( @books)
          {
            $books_hash->{$book->id}->{"title"} = $book->title;
            $books_hash->{$book->id}->{"date"} = $book->edition_date;
            $books_hash->{$book->id}->{"isbn_no"} = $book->isbn_no;
            $books_hash->{$book->id}->{"author_id"} = $book->author_id;
          }
         
          return $books_hash;
    }
    catch {
        error $_;
        send_error({ 
                    error => $_, 
                    status => "Books not found" 
        });
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
         my @book = $bookstore_schema->resultset('Book')->search({
            id  => $params->{'id'},
         });
        
         my $book_hash={};

         if (@book){
           $book_hash->{"title"} = $book[0]->title;
           $book_hash->{"date"} = $book[0]->edition_date;
           $book_hash->{"isbn_no"} = $book[0]->isbn_no;
           $book_hash->{"author_id"} = $book[0]->author_id;
         }

         return $book_hash;
    }
    catch {
           error $_;
           send_error({ 
                       error => $_, 
                       status => "Book not found" 
           });
    };

};

any ['put','patch'] => '/api/books/:id' => sub {
    try {
         content_type 'application/json';
         my $params = request->params;
         my $book =$bookstore_schema->resultset('Book')->search({ 
            id    => $params->{'id'},
         });

         my $hash_book_params = {};

         $hash_book_params->{'title'} = $params->{'title'} if $params->{'title'};
         $hash_book_params->{'edition_date'} = $params->{'edition_date'} if $params->{'edition_date'};
         $hash_book_params->{'isbn_no'} = $params->{'isbn_no'} if $params->{'isbn_no'};
         $hash_book_params->{'author_id'} = $params->{'author_id'} if $params->{'author_id'};
     
         my $update_status = $book->update($hash_book_params);
         
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
##END## API for BOOKS

##START## API for AUTHORS

get '/api/authors' => sub {
    try {
          content_type 'application/json';
          my @authors =$bookstore_schema->resultset('Author')->search();

          my $authors_hash={};
          foreach my $author ( @authors)
          {
            $authors_hash->{$author->id}->{"name"} = $author->name;
            $authors_hash->{$author->id}->{"surname"} = $author->surname;
            $authors_hash->{$author->id}->{"country"} = $author->country;
          }
         
          return $authors_hash;
    }
    catch {
        error $_;
        send_error({ 
                    error => $_, 
                    status => "Authors not found" 
        });
    };

};

post '/api/authors' => sub {
    try {
         content_type 'application/json';
         my $params = request->params;
         $bookstore_schema->resultset('Author')->create({
            name           => $params->{'name'},
            surname        => $params->{'surname'},
            country        => $params->{'country'},
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

del '/api/authors/:id' => sub {
    try {
          content_type 'application/json';
          my $author = $bookstore_schema->resultset('Author')->search({
             id    => param('id'),
          });
        
          my $authors_amount = $author->count;
          $author->delete if $authors_amount;

          return { 
                  status => "OK",
                  deleted_rows => $authors_amount,
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

get '/api/authors/:id' => sub {
    try {
         content_type 'application/json';
         my $params = request->params;
         my @author = $bookstore_schema->resultset('Author')->search({
            id  => $params->{'id'},
         });
        
         my $author_hash={};
         
         if (@author){
           $author_hash->{"name"} = $author[0]->name;
           $author_hash->{"surname"} = $author[0]->surname;
           $author_hash->{"country"} = $author[0]->country;
         }

         return $author_hash;
    }
    catch {
           error $_;
           send_error({ 
                       error => $_, 
                       status => "Author not found" 
           });
    };

};

any ['put','patch'] => '/api/authors/:id' => sub {
    try {
         content_type 'application/json';
         my $params = request->params;
         my $author = $bookstore_schema->resultset('Author')->search({ 
            id    => $params->{'id'},
         });

         my $hash_author_params = {};

         $hash_author_params->{'name'} = $params->{'name'} if $params->{'name'};
         $hash_author_params->{'surname'} = $params->{'surname'} if $params->{'surname'};
         $hash_author_params->{'country'} = $params->{'country'} if $params->{'country'};
     
         my $update_status = $author->update($hash_author_params);
         
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


##END## API for AUTHORS

##END## API Interface 


##START## End user functions

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
    my $result = _search_book($book_id);

    template 'book', { 
                         result => $result,
    };
};

##END## End user functions

##START## subroutines section

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

    my @book = $bookstore_schema->resultset('Author')->search(
      {
        'books.id' => $book_id,
      },
      {
        join => 'books',
        '+columns' => [{'title' => 'books.title',
                        'isbn_no' => 'books.isbn_no',
                        'edition_date' => 'books.edition_date'
                      }],
      }
    );
    
    if (@book){
      my $title = $book[0]->get_column('title');
      my $fullname = $book[0]->name." ".$book[0]->surname;
      my $isbn_no = $book[0]->get_column('isbn_no');
      my $edition_date = $book[0]->get_column('edition_date');
    
      my $book_params_hash = {
         title => $title,
         fullname => $fullname,
         isbn_no => $isbn_no,
         edition_date => $edition_date,
      };    

      return $book_params_hash;
    }
    else {
      return $status_not_ok;
    }
};

##END## subroutines section

true;
