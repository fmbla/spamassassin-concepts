package Mail::SpamAssassin::Plugin::Concepts;
my $VERSION = 0.01;

### Blah:
#
# Author: Paul Stead <paul.stead@gmail.com>
# Copyright 2016 Paul Stead
#
# <@LICENSE>
# TBD
# </@LICENSE>
#

### Changelog:
#
# 0.01 - first public version
#

use strict;
use Mail::SpamAssassin::Plugin;
use File::Basename;

use vars qw(@ISA);
@ISA = qw(Mail::SpamAssassin::Plugin);

sub dbg { Mail::SpamAssassin::Plugin::dbg ("Concepts: @_"); }

sub new
{
    my ($class, $mailsa) = @_;

    $class = ref($class) || $class;
    my $self = $class->SUPER::new($mailsa);
    bless ($self, $class);

    $self->set_config($mailsa->{conf});
    $self->register_eval_rule("check_concepts");

    $self;
}

sub set_config {
    my ($self, $conf) = @_;
    my @cmds = ();
    push(@cmds, {
        setting => 'concepts_dir',
        default => '/opt/concepts',
        type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
        }
    );
    $conf->{parser}->register_commands(\@cmds);
}

sub check_start {
  my ($self, $params) = @_;
  my $pms = $params->{permsgstatus};

  $self->{concepts} = $self->read_concept_files($pms);
}

sub extract_metadata {
  my ($self, $opts) = @_;
  my $pms = $opts->{permsgstatus};
  my $msg = $opts->{msg};

  return unless ($msg->can ("put_metadata"));

  my $body = [];
  push $body, $pms->get('From:name'); 
  push @$body, @{$pms->get_decoded_stripped_body_text_array()};

  foreach (@$body) { 
    dbg($_);
  }

  my $bodyc = join("\n", @$body);
  my $matched_concepts={};

  foreach my $key (keys $self->{concepts}) {
    foreach my $breg (@{$self->{concepts}{$key}{'body_rules'}}) {
      $matched_concepts->{$key}+=grep (/\b$breg\b/ig, $bodyc);
    }
  }

  my $concepts = '';

  foreach my $key (keys $matched_concepts) {
    if ($matched_concepts->{$key} >= $self->{concepts}{$key}{'count'}) {
      $concepts .= "$key ";
    }
  }

  chop $concepts;

  if ($concepts ne '') {
    $msg->put_metadata("X-SA-Concepts", $concepts);
    dbg("metadata: X-SA-Concepts: $concepts");
  }

  return 1;
}

sub parsed_metadata {
  my ($self, $opts) = @_;

  my $concepts =
    $opts->{permsgstatus}->get_message->get_metadata('X-SA-Concepts');

  return unless $concepts;

  my @c_list = split(' ', $concepts);

  $opts->{permsgstatus}->set_tag("CONCEPTS", 
		@c_list == 1 ? $c_list[0] : \@c_list
	);

  return 1;
}

sub read_concept_files {
   my ($pms) = @_;

    my $dir = $pms->{main}->{conf}->{concepts_dir};
    my @files = glob("$dir/*");

    my $concepts = {};

    foreach my $file (@files) {

        next unless ( -e $file );

        unless ( -r $file ) {
            warnlog("Cannot read \"$file\"\n Please check file path and permissions are correct");
            next;
        }
    
        open RELIST, "<$file";

        my ($conceptname) = basename $file;
        $conceptname =~ s/[\s]/_/g;

        $concepts->{$conceptname} = {};

        my ($count) = split /:/, <RELIST>, 1;

        $concepts->{$conceptname}->{'count'} = $count;
        $concepts->{$conceptname}->{'body_rules'} = [];

        while(my $re = <RELIST>) {
            chomp $re;
            push $concepts->{$conceptname}->{'body_rules'}, $re if $re ne '';
        }
    }

    my $lcount = keys $concepts;
    dbg("$lcount concepts loaded");

    $concepts;
}

sub check_concepts
{
    return 0;
}

1;
