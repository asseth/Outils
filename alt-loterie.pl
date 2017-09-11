#!/usr/bin/perl -w

# alt-loterie.pl
# filtertron - jzu@free.fr
# Donne exactement les mêmes résultats avec la même syntaxe que loterie.sh
# (https://github.com/asseth/Outils/blob/master/loterie.sh)
# sans nécessiter de blockchain Ethereum synchronisée
# Le hash du bloc est obtenu par HTML scraping sur etherscan 
# Le package Digest::Keccak sert à calculer les hashes des emails, 
# à chercher sur le CPAN
# Math::BigInt est nécessaire pour dépasser la limite des int en Perl


use strict;

use Math::BigInt;
use LWP::UserAgent;
use Digest::Keccak qw (keccak_256_hex);

my $url = "http://etherscan.io/block";

my $debug = $ENV{'DEBUG'};

my $blockh;
my %delta;

my $block = shift;

# HTML scrapping (erk, mais évite de gérer un token d'API etherscan)

my $ua = LWP::UserAgent->new;
$ua->agent ("Mozilla/5.0 Gecko/20100101 Firefox/55.0");

my $page = $ua->get ("$url/$block");

$page->is_success or
    die ("$url/$block introuvable");

# Conversion de hex en int

$blockh = $page->decoded_content;
$blockh =~ s/.*;Hash:[^0]*0x([0-9a-f]*).*/$1/s;
$debug and 
    print STDERR uc $blockh, " eth.getBlock($block).hash\n";

# Calcul des deltas (hash_email - hash_bloc) en valeur absolue

foreach my $arg (@ARGV) {
    $delta {$arg} = Math::BigInt->from_hex (keccak_256_hex ($arg));
    $delta {$arg} = $delta {$arg}->bsub (Math::BigInt->from_hex ($blockh));
    $delta {$arg} = $delta {$arg}->babs();
    $debug and 
        print STDERR uc keccak_256_hex ($arg), " $arg\n";
}

# Tri ascendant selon le delta 

foreach my $key (sort { $delta {$a} <=> $delta {$b} } keys %delta) {
    $debug and
        print $delta {$key}, ' ';
    print "$key\n";
}

