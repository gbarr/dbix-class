use strict;
use warnings;

use Test::More;
use lib qw(t/lib);
use DBICTest;

plan tests => 43;

my $schema = DBICTest->init_schema();
my $rs = $schema->resultset('Artist');

RETURN_RESULTSETS: {

	my ($crap, $girl, $damn, $xxxaaa) = $rs->populate( [
	  { artistid => 4, name => 'Manufactured Crap', cds => [ 
		  { title => 'My First CD', year => 2006 },
		  { title => 'Yet More Tweeny-Pop crap', year => 2007 },
		] 
	  },
	  { artistid => 5, name => 'Angsty-Whiny Girl', cds => [
		  { title => 'My parents sold me to a record company' ,year => 2005 },
		  { title => 'Why Am I So Ugly?', year => 2006 },
		  { title => 'I Got Surgery and am now Popular', year => 2007 }

		]
	  },
	  { artistid=>6, name => 'Like I Give a Damn' },
	  
	  { artistid => 7, name => 'bbbb', cds => [
		  { title => 'xxxaaa' ,year => 2005 },
		]
	  },

	] );
	
	isa_ok( $crap, 'DBICTest::Artist', "Got 'Artist'");
	isa_ok( $damn, 'DBICTest::Artist', "Got 'Artist'");
	isa_ok( $girl, 'DBICTest::Artist', "Got 'Artist'");	
	isa_ok( $xxxaaa, 'DBICTest::Artist', "Got 'Artist'");	
	
	ok( $crap->name eq 'Manufactured Crap', "Got Correct name for result object");
	ok( $girl->name eq 'Angsty-Whiny Girl', "Got Correct name for result object");
	ok( $xxxaaa->name eq 'bbbb', "Got Correct name for result object");
		
	ok( $crap->cds->count == 2, "got Expected Number of Cds");
	ok( $girl->cds->count == 3, "got Expected Number of Cds");
}

RETURN_VOID: {

	$rs->populate( [
	  { artistid => 8, name => 'Manufactured CrapB', cds => [ 
		  { title => 'My First CDB', year => 2006 },
		  { title => 'Yet More Tweeny-Pop crapB', year => 2007 },
		] 
	  },
	  { artistid => 9, name => 'Angsty-Whiny GirlB', cds => [
		  { title => 'My parents sold me to a record companyB' ,year => 2005 },
		  { title => 'Why Am I So Ugly?B', year => 2006 },
		  { title => 'I Got Surgery and am now PopularB', year => 2007 }

		]
	  },
	  { artistid =>10,  name => 'XXXX' },
	  { artistid =>11, name => 'wart', cds =>{ title => 'xxxaaa' ,year => 2005 }, },
	] );
	
	my $artist = $rs->find(8);

	ok($artist, 'Found artist');
	is($artist->name, 'Manufactured CrapB', "Got Correct Name");
	is($artist->cds->count, 2, 'Has CDs');

	my @cds = $artist->cds;

	is($cds[0]->title, 'My First CDB', 'A CD');
	is($cds[0]->year,  2006, 'Published in 2006');

	is($cds[1]->title, 'Yet More Tweeny-Pop crapB', 'Another crap CD');
	is($cds[1]->year,  2007, 'Published in 2007');

	$artist = $rs->find(9);
	ok($artist, 'Found artist');
	is($artist->name, 'Angsty-Whiny GirlB', "Another correct name");
	is($artist->cds->count, 3, 'Has CDs');
	
	@cds = $artist->cds;


	is($cds[0]->title, 'My parents sold me to a record companyB', 'A CD');
	is($cds[0]->year,  2005, 'Published in 2005');

	is($cds[1]->title, 'Why Am I So Ugly?B', 'A Coaster');
	is($cds[1]->year,  2006, 'Published in 2006');

	is($cds[2]->title, 'I Got Surgery and am now PopularB', 'Selling un-attainable dreams');
	is($cds[2]->year,  2007, 'Published in 2007');

	$artist = $rs->search({name => 'XXXX'})->single;
	ok($artist, "Got Expected Artist Result");

	is($artist->cds->count, 0, 'No CDs');
	
	$artist = $rs->find(10);
	is($artist->name, 'XXXX', "Got Correct Name");
	is($artist->cds->count, 0, 'Has NO CDs');
	
	$artist = $rs->find(11);
	is($artist->name, 'wart', "Got Correct Name");
	is($artist->cds->count, 1, 'Has One CD');
}

RETURN_RESULTSETS_AUTOPK: {

	my ($crap, $girl, $damn, $xxxaaa) = $rs->populate( [
	  { name => 'Manufactured CrapC', cds => [ 
		  { title => 'My First CD', year => 2006 },
		  { title => 'Yet More Tweeny-Pop crap', year => 2007 },
		] 
	  },
	  { name => 'Angsty-Whiny GirlC', cds => [
		  { title => 'My parents sold me to a record company' ,year => 2005 },
		  { title => 'Why Am I So Ugly?', year => 2006 },
		  { title => 'I Got Surgery and am now Popular', year => 2007 }

		]
	  },
	  { name => 'Like I Give a DamnC' },
	  
	  { name => 'bbbbC', cds => [
		  { title => 'xxxaaa' ,year => 2005 },
		]
	  },

	] );
	
	isa_ok( $crap, 'DBICTest::Artist', "Got 'Artist'");
	isa_ok( $damn, 'DBICTest::Artist', "Got 'Artist'");
	isa_ok( $girl, 'DBICTest::Artist', "Got 'Artist'");	
	isa_ok( $xxxaaa, 'DBICTest::Artist', "Got 'Artist'");	
	
	ok( $crap->name eq 'Manufactured CrapC', "Got Correct name for result object");
	ok( $girl->name eq 'Angsty-Whiny GirlC', "Got Correct name for result object");
	ok( $xxxaaa->name eq 'bbbbC', "Got Correct name for result object");
	
	ok( $crap->cds->count == 2, "got Expected Number of Cds");
	ok( $girl->cds->count == 3, "got Expected Number of Cds");
}

## Test from a belongs_to perspective, should create artist first, then CD with artistid in:
my $cd_rs = $schema->resultset('CD');
$cd_rs->populate([ 
                   { title => 'Some CD',
                     year => 1997,
                     artist => { name => 'Fred Bloggs'},
                 }] );
my $cd = $schema->resultset('CD')->find({title => 'Some CD'});

isa_ok($cd, 'DBICTest::CD', 'Created CD');
isa_ok($cd->artist, 'DBICTest::Artist', 'Set Artist');
is($cd->artist->name, 'Fred Bloggs', 'Set Artist to Fred');
