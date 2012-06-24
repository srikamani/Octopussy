#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_ServiceGroup.t - Octopussy Source Code Checker for Octopussy::ServiceGroup

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 12;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use Octopussy::FS;
use Octopussy::ServiceGroup;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $PREFIX          => 'Octo_TEST_';
Readonly my $SG_FILE         => Octopussy::FS::File('servicegroups');
Readonly my $SG_ID           => "${PREFIX}servicegroup";
Readonly my $SG_DESC         => "${PREFIX}servicegroup Description";
Readonly my $DIR_SERVICES    => Octopussy::FS::Directory('services');
Readonly my @SERVICES_KERNEL => (
  {sid => 'Linux_Kernel', rank => '01'},
  {
    sid  => 'Linux_Kernel_Bluetooth',
    rank => '02'
  },
  {sid => 'Linux_Kernel_USB', rank => '03'},
);
Readonly my $SERVICE_TO_ADD => 'Linux_Kernel_FS_Ext3';

my %conf = (
  sg_id       => $SG_ID,
  description => $SG_DESC,
  service     => \@SERVICES_KERNEL,
);

my @list1 = Octopussy::ServiceGroup::List();

my $error1 = Octopussy::ServiceGroup::Add(\%conf);
my $error2 = Octopussy::ServiceGroup::Add(\%conf);
ok(((!defined $error1) && (defined $error2)), 'Octopussy::ServiceGroup::Add()');

my $new_conf = Octopussy::ServiceGroup::Configuration($SG_ID);
ok($new_conf->{sg_id} eq $SG_ID, 'Octopussy::ServiceGroup::Configuration()');

my @list2 = Octopussy::ServiceGroup::List();
ok(scalar @list1 + 1 == scalar @list2, 'Octopussy::ServiceGroup::List()');

my @services = Octopussy::ServiceGroup::Services($SG_ID);
ok(
  scalar @SERVICES_KERNEL == scalar @services,
  'Octopussy::ServiceGroup::Services()'
);

my $service_added =
  Octopussy::ServiceGroup::Add_Service($SG_ID, $SERVICE_TO_ADD);
ok($service_added eq $SERVICE_TO_ADD, 'Octopussy::ServiceGroup::Add_Service()');

my $rank = Octopussy::ServiceGroup::Move_Service($SG_ID, $service_added, 'up');
ok($rank eq '03', 'Octopussy::ServiceGroup::Move_Service()');

Octopussy::ServiceGroup::Remove_Service($SG_ID, $service_added);
my @services2 = Octopussy::ServiceGroup::Services($SG_ID);
ok(
  scalar @services == scalar @services2,
  'Octopussy::ServiceGroup::Remove_Service()'
);

Octopussy::ServiceGroup::Remove($SG_ID);
my @list4 = Octopussy::ServiceGroup::List();
ok(scalar @list4 == scalar @list1, 'Octopussy::ServiceGroup::Remove()');

my $is_valid = Octopussy::ServiceGroup::Valid_Name(undef);
ok(!$is_valid, 'Octopussy::ServiceGroup::Valid_Name(undef)');

$is_valid = Octopussy::ServiceGroup::Valid_Name('servicegroup with space');
ok(!$is_valid, "Octopussy::ServiceGroup::Valid_Name('servicegroup with space')");

$is_valid = Octopussy::ServiceGroup::Valid_Name('valid-servicegroup');
ok($is_valid, "Octopussy::ServiceGroup::Valid_Name('valid-servicegroup')");

$is_valid = Octopussy::ServiceGroup::Valid_Name('valid_servicegroup');
ok($is_valid, "Octopussy::ServiceGroup::Valid_Name('valid_servicegroup')");

unlink $SG_FILE;

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
