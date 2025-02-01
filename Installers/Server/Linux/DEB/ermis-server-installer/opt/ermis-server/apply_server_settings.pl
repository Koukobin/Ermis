#!/usr/bin/perl

# Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

use strict;
use File::Find;

# Extract the address from the config file
my $address;
my $port;
open my $fh, '<', '/opt/ermis-server/configs/server-settings/general-settings.cnf' or die "Cannot open config file: $!\n";
while (my $line = <$fh>) {
    if ($line =~ /^address=(.*)$/) {
        $address = $1;
    }
    if ($line =~ /^port=(\d+)$/) {
        $port = $1;
    }
}
close $fh;

# Ensure address is not empty
die "Error: Could not extract address from config file!\n" unless $address;

# Ensure address is invalid
if ($address eq " ------") {
    die "Error: Address is invalid!\n";
}

# Ensure address is not empty
die "Error: Could not extract port from config file!\n" unless $port;

# Ensure address is invalid
if ($port eq " ------") {
    die "Error: Port is invalid!\n";
}

my $paypal_client_id;
my $bitcoin_address;
my $monero_address;
open $fh, '<', '/opt/ermis-server/configs/donation-settings/general-settings.cnf' or die "Cannot open config file: $!\n";
while (my $line = <$fh>) {
    if ($line =~ /^paypal-client-id=(.*)$/) {
 	$paypal_client_id= $1;
    }
    if ($line =~ /^bitcoin-address=(.*)$/) {
        $bitcoin_address = $1;
    }
    if ($line =~ /^monero-address=(.*)$/) {
        $monero_address = $1;
    }
}
close $fh;

# Find all files in the target directories
my @dirs = ('/opt/ermis-server/configs/', '/var/ermis-server/www', '/etc/nginx/');
find(sub {
    return unless -f $_;  # Only process files
    # Replace SERVER_ADDRESS and SERVER_PORT with the extracted address
    open my $in, '<', $_ or die "Cannot open file $_: $!\n";
    my @lines = <$in>;
    close $in;

    open my $out, '>', $_ or die "Cannot write to file $_: $!\n";
    foreach my $line (@lines) {
        $line =~ s/SERVER_ADDRESS/$address/g;
        $line =~ s/IP_ADDRESS/$address/g;
        $line =~ s/SERVER_PORT/$port/g;
        $line =~ s/PORT/$port/g;
        $line =~ s/PAYPAL_CLIENT_ID/$paypal_client_id/g;
        $line =~ s/BTC_ADDRESS/$bitcoin_address/g;
        $line =~ s/XMR_ADDRESS/$monero_address/g;
        print $out $line;
    }
    close $out;
}, @dirs);

