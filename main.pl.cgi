#!/usr/bin/perl
use strict;
use Digest::MD5 qw(md5 md5_hex md5_base64);
require 'html_printer.pl';
require 'helpers.pl';

open( FILE, "users.txt" ) || die "problem opening users.txt $!";
my @userInfo = <FILE>; 
close FILE;

read STDIN, my $POST_data, $ENV{'CONTENT_LENGTH'}; # anything that come from a POST request goes here
print "Content-type: text/html\n\n";

my %params = &parse_form($POST_data);

# SIGNED UP AND SIGNED IN (unless errors)
if ( exists $params{'new_username'} && exists $params{'new_password'} && exists $params{'confirm_password'} ) # Registration
{
	if ($params{'confirm_password'} eq $params{'new_password'})
	{
		# TODO: validations to make sure username does not exist, etc.
		&add_user($params{'new_username'}, md5_hex($params{'new_password'}));
		&signin($params{'new_username'});
		# user is now signed in, so render the same HTML as the Signin branch of the statement
		&render('home', { username => 'testing' });
	}
	else # FAILED REGISTRATION
	{
		# TODO: add errors since your password didnt match or the username was taken
		print($params{'new_password'});
		print($params{'confirm_password'});
		&render('landing');
	}
}
elsif ( exists $params{'username'} && exists $params{'password'} ) # Signin
{
	&render('home', { username => $params{'new_username'} });
}
# LANDING PAGE
else
{
		&render('landing');
}