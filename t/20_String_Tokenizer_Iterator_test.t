#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 69;

BEGIN { 
    use_ok('String::Tokenizer') 
};

# first check that our inner class 
# cannot be called from outside
eval {
    String::Tokenizer::Iterator->new();
};
like($@, qr/Insufficient Access Priviledges/, '... this should have died');

# it can also parse reasonably well formated perl code  
my $STRING = <<STRING_TO_TOKENIZE;
sub test {
    my (\$arg) = \@_;
	if (\$arg == 10){
		return 1;
	}
	return 0;
}

STRING_TO_TOKENIZE

my @expected4 = qw(sub test { my ( $arg ) = @_ ; if ( $arg == 10 ) { return 1 ; } return 0 ; });

my $st = String::Tokenizer->new($STRING, '();{}');

can_ok("String::Tokenizer::Iterator", 'new');

my $i = $st->iterator();

isa_ok($i, "String::Tokenizer::Iterator");

can_ok($i, 'reset');
can_ok($i, 'hasNextToken');
can_ok($i, 'hasPrevToken');
can_ok($i, 'nextToken');
can_ok($i, 'prevToken');
can_ok($i, 'currentToken');
can_ok($i, 'lookAheadToken');
can_ok($i, 'skipToken');
can_ok($i, 'skipTokens');

my @iterator_output;
push @iterator_output => $i->nextToken() while $i->hasNextToken();

ok(!defined($i->nextToken()), '... this is undefined');
ok(!defined($i->lookAheadToken()), '... this is undefined');

ok(eq_array(\@iterator_output,
            \@expected4),
  '... this is the output we would expect'); 
  
my @reverse_iterator_output;
push @reverse_iterator_output => $i->prevToken() while $i->hasPrevToken();  

ok(!defined($i->prevToken()), '... this is undefined');
ok(!defined($i->lookAheadToken()), '... this is undefined');
  
ok(eq_array(\@reverse_iterator_output,
            [ reverse @expected4 ]),
  '... this is the output we would expect'); 

my $look_ahead;
while ($i->hasNextToken()) {  
    my $next = $i->nextToken();
    my $current = $i->currentToken();
    is($look_ahead, $next, '... our look ahead matches out next') if defined $look_ahead;
    is($current, $next, '... our current matches out next');
    $look_ahead = $i->lookAheadToken();  
}

$i->reset();
            
my @expected5 = qw({ ( ) @_ if $arg 10 { 1 } 0 });              
  
my @skip_output;
$i->skipTokens(2); 
while ($i->hasNextToken()) {
    push @skip_output => $i->nextToken();
    $i->skipToken();    
}

ok(eq_array(\@skip_output,
            \@expected5),
  '... this is the output we would expect');  
  