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

# Extract address and port
my $address;
my $port;
open my $fh, '<', '/etc/ermis-server/configs/server-settings/general-settings.cnf' or die "Cannot open config file: $!\n";
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

# Ensure address is valid
if ($address eq " ------") {
    die "Error: Address is invalid!\n";
}

# Ensure port is not empty
die "Error: Could not extract port from config file!\n" unless $port;

# Ensure port is valid
if ($port eq " ------") {
    die "Error: Port is invalid!\n";
}

# Extract SSL certificate data
my $ssl_certificate;
my $ssl_certificate_key;
open $fh, '<', '/etc/ermis-server/configs/server-settings/ssl-settings.cnf' or die "Cannot open config file: $!\n";
while (my $line = <$fh>) {
    if ($line =~ /^ssl-certificate=(.*)$/) {
	    $ssl_certificate= $1;
    }
    if ($line =~ /^ssl-certificate-key=(.*)$/) {
        $ssl_certificate_key = $1;
    }
}
close $fh;

# Ensure ssl certificate is configured
die "Error: Could not extract ssl certificate path from config file!\n" unless $ssl_certificate;

# Ensure ssl certificate key is configured
die "Error: Could not extract ssl certificate key path from config file!\n" unless $ssl_certificate_key;

# Extract donation data
my $paypal_client_id;
my $bitcoin_address;
my $monero_address;
open $fh, '<', '/etc/ermis-server/configs/donation-settings/general-settings.cnf' or die "Cannot open config file: $!\n";
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

# Unlike a priori - do not perform checks to validate 
# donation data integrity since it isn't sine qua non.


# Find all files in the target directories
my @dirs = ('/var/ermis-server/www', '/etc/nginx/sites-enabled', '/etc/nginx/modules-enabled');
find(sub {
    return unless -f $_;  # Only process files
    # Replace placeholders with the extracted values
    open my $in, '<', $_ or die "Cannot open file $_: $!\n";
    my @lines = <$in>;
    close $in;

    open my $out, '>', $_ or die "Cannot write to file $_: $!\n";
    foreach my $line (@lines) {
        $line =~ s/SERVER_ADDRESS/$address/g;
        $line =~ s/IP_ADDRESS/$address/g;
        $line =~ s/SERVER_PORT/$port/g;
        $line =~ s/PORT/$port/g;
        $line =~ s/SSL_CERTIFICATE/$ssl_certificate/g;
        $line =~ s/SSL_CERTIFICATE_KEY/$ssl_certificate_key/g;
        $line =~ s/PAYPAL_CLIENT_ID/$paypal_client_id/g;
        $line =~ s/BTC_ADDRESS/$bitcoin_address/g;
        $line =~ s/XMR_ADDRESS/$monero_address/g;
        print $out $line;
    }

    close $out;
}, @dirs);

