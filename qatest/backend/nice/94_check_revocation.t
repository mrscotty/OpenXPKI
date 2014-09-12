#!/usr/bin/perl
#
# 045_activity_tools.t
#
# Tests misc workflow tools like WFObject, etc.
#
# Note: these tests are non-destructive. They create their own instance
# of the tools workflow, which is exclusively for such test purposes.

use strict;
use warnings;

use lib qw(
  ../../lib
);

use Carp;
use English;
use Data::Dumper;
use Config::Std;
use File::Basename;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($WARN);

use OpenXPKI::Test::More;
use TestCfg;

my $dirname = dirname($0);

our @cfgpath = ( $dirname );
our %cfg = ();

my $testcfg = new TestCfg;
$testcfg->read_config_path( '9x_nice.cfg', \%cfg, @cfgpath );

my $test = OpenXPKI::Test::More->new(
    {
        socketfile => $cfg{instance}{socketfile},
        realm => $cfg{instance}{realm},
    }
) or die "Error creating new test instance: $@";

$test->set_verbose($cfg{instance}{verbose});

$test->plan( tests => 3 );
 
my $buffer = do { # slurp
	local $INPUT_RECORD_SEPARATOR;
    open my $HANDLE, '<', $cfg{instance}{buffer};
    <$HANDLE>;
};

my $serializer = OpenXPKI::Serialization::Simple->new();
my $input_data = $serializer->deserialize( $buffer );

my $cert_identifier = $input_data->{'cert_identifier'};
my $wf_id = $input_data->{'wf_id'};

$test->like( $cert_identifier , "/^[0-9a-zA-Z-_]{27}/", 'Certificate Identifier')
 || die "Unable to proceed without Certificate Identifier: $@";
 

# Login to use socket
$test->connect_ok(
    user => $cfg{operator}{name},
    password => $cfg{operator}{role},
) or die "Error - connect failed: $@";

$test->set_wftype ( 'I18N_OPENXPKI_WF_TYPE_CERTIFICATE_REVOCATION_REQUEST' );
$test->set_wfid ( $wf_id );

$test->reset();

# We might need to wait for the watchdog
my $i = 25;

while ($test->state() eq 'CHECK_FOR_REVOCATION' && $i--) {    
    sleep 1;
    $test->reset();
}

$test->state_is('SUCCESS');

$test->disconnect();
 
