#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_TimePeriod.t - Octopussy Source Code Checker for Octopussy::TimePeriod

=cut

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(any);
use Test::More tests => 9;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use Octopussy::FS;
use Octopussy::TimePeriod;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $FILE_TIMEPERIOD   => Octopussy::FS::File('timeperiods');
Readonly my $PREFIX            => 'Octo_TEST_';
Readonly my $TP_LABEL          => "${PREFIX}timeperiod_label";
Readonly my $TP_RESULT_PERIODS => 'Mon: 08:00-20:00, Tue: 08:00-20:00';

my @dts = ({'Monday' => '08:00-20:00'}, {'Tuesday' => '08:00-20:00'},);

my @list = Octopussy::TimePeriod::List();

my $file = Octopussy::TimePeriod::New({label => $TP_LABEL, dt => \@dts});
my @list2 = Octopussy::TimePeriod::List();

ok(
  $file eq $FILE_TIMEPERIOD
    && scalar @list + 1 == scalar @list2,
  'Octopussy::TimePeriod::New()'
);

ok((any { $_ eq $TP_LABEL } @list2), 'Octopussy::TimePeriod::List()');

my $conf = Octopussy::TimePeriod::Configuration($TP_LABEL);
ok($conf->{label} eq $TP_LABEL && $conf->{periods} eq $TP_RESULT_PERIODS,
  'Octopussy::TimePeriod::Configuration()');

my $match       = Octopussy::TimePeriod::Match($TP_LABEL, 'Tuesday 14:00');
my $dont_match1 = Octopussy::TimePeriod::Match($TP_LABEL, 'Tuesday 21:30');
my $dont_match2 = Octopussy::TimePeriod::Match($TP_LABEL, 'Saturday 14:00');
ok($match && !$dont_match1 && !$dont_match2, 'Octopussy::TimePeriod::Match()');

$file = Octopussy::TimePeriod::Remove($TP_LABEL);
my @list3 = Octopussy::TimePeriod::List();

ok(($file eq $FILE_TIMEPERIOD) &&  (scalar @list == scalar @list3),
  'Octopussy::TimePeriod::Remove()');

my $is_valid = Octopussy::TimePeriod::Valid_Name(undef);
ok(!$is_valid, 'Octopussy::TimePeriod::Valid_Name(undef)');

$is_valid = Octopussy::TimePeriod::Valid_Name('timeperiod with space');
ok(!$is_valid, "Octopussy::TimePeriod::Valid_Name('timeperiod with space')");

$is_valid = Octopussy::TimePeriod::Valid_Name('valid-timeperiod');
ok($is_valid, "Octopussy::TimePeriod::Valid_Name('valid-timeperiod')");

$is_valid = Octopussy::TimePeriod::Valid_Name('valid_timeperiod');
ok($is_valid, "Octopussy::TimePeriod::Valid_Name('valid_timeperiod')");

unlink $FILE_TIMEPERIOD;

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
