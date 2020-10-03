#!/usr/bin/perl

use strict;
use YAML::XS qw(LoadFile DumpFile);
use HTTP::Tiny;
use Email::Send;
use Email::Send::Gmail;
use Email::Simple::Creator;

my $config_file  = "ip_monitor.yml";
my $log_filename = "ip_monitor.log";

open(my $log_fh, '>>', $log_filename) or die "Cannot open log file ($log_filename) for appending.\n$!\n";

my $config = LoadFile($config_file);

sub output {
    my $action = shift;
    my $message = shift;
    my $out = sprintf("%04d-%02d-%02d %02d:%02d:%02d: %s\n", (localtime)[5]+1900, (localtime)[4]+1, (localtime)[3,2,1,0], sprintf($message, @_));

    print $log_fh $out;

    if($action eq 'email' or $action eq 'warn' or $action eq 'die') {
        my $email = Email::Simple->create(
            header => [
                From    => $config->{config}->{email_from},
                To      => $config->{config}->{email_to},
                Subject => sprintf("IP Address Monitor"),
                ],
            body => sprintf("%s", $out)
            );

        my $sender = Email::Send->new(
            {   mailer      => 'Gmail',
                mailer_args => [
                    username => $config->{config}->{username},
                    password => $config->{config}->{password},
                ]
            }
        );
        $sender->send($email) or warn "Error sending email: $@";
    }

    if($action eq 'warn') { warn $out; }
    elsif($action eq 'die') { die $out; }
    else { print $out; }

    return;
}

my $url = $config->{api_url};

my $response = HTTP::Tiny->new->get($url);
output('warn', 'IP API call failed.') unless $response->{success};

my $new_address = $response->{content}; 

my $last_address = $config->{last_address};


unless ( $last_address eq $new_address ) {
    output('email', "The Public IP Address has changed from %s to %s.", $last_address, $new_address);
    $config->{last_address} = $new_address;
    DumpFile($config_file, $config);
} else {
    output('print', "Public IP unchanged: %s", $new_address);
}

