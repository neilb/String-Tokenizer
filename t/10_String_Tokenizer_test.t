#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;

BEGIN { 
    use_ok('String::Tokenizer') 
};

# parse a nested expression
my $STRING1 = "((5 + 10)-100) * (15 + (23 / 300))";

# expected output with no delimiters
my @expected1 = qw{((5 + 10)-100) * (15 + (23 / 300))};
# expected output with () as delimiters
my @expected2 = qw{( ( 5 + 10 ) -100 ) * ( 15 + ( 23 / 300 ) )};
# expected output with ()+-*/ as delimiters
my @expected3 = qw{( ( 5 + 10 ) - 100 ) * ( 15 + ( 23 / 300 ) )};

can_ok("String::Tokenizer", 'new');

my $st = String::Tokenizer->new();

isa_ok($st, 'String::Tokenizer');
can_ok($st, 'tokenize');
can_ok($st, 'getTokens');
can_ok($st, 'iterator');

$st->tokenize($STRING1);

ok(eq_array(scalar $st->getTokens(),
            \@expected1),
  '... this is the output we would expect');

$st->tokenize($STRING1, '()');

ok(eq_array([ $st->getTokens() ],
            \@expected2),
  '... this is the output we would expect');
  
my $st2 = String::Tokenizer->new($STRING1, '()=-*/');

ok(eq_array(scalar $st2->getTokens(),
            \@expected3),
  '... this is the output we would expect');  
 
# it can also parse reasonably well formated perl code  
my $STRING2 = <<STRING_TO_TOKENIZE;
sub test {
    my (\$arg) = \@_;
	if (\$arg == 10){
		return 1;
	}
	return 0;
}

STRING_TO_TOKENIZE

my @expected4 = qw(sub test { my ( $arg ) = @_ ; if ( $arg == 10 ) { return 1 ; } return 0 ; });

my $st3 = String::Tokenizer->new($STRING2, '();{}');

ok(eq_array(scalar $st3->getTokens(),
            \@expected4),
  '... this is the output we would expect'); 

