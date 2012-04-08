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

if (!&isLoggedIn) 
{
	if ( exists $params{'new_username'} && exists $params{'new_password'} && exists $params{'confirm_password'} ) # Registration
	{
		my $available = &isNameAvailable( $params{'new_username'});
		if ($params{'confirm_password'} eq $params{'new_password'} && $available)
		{
			# TODO: validations to make sure username does not exist, etc.
			&add_user($params{'new_username'}, md5_hex($params{'new_password'}));
			&signin($params{'new_username'});
			&log_data("New user $params{'new_username'} registered");
			# user is now signed in, so render the same HTML as the Signin branch of the statement
			&render('home', { username => $params{'new_username'} });
		}
		else # FAILED REGISTRATION
		{
			&log_data("Failed registration attempt");	# TODO: add errors sine your password didnt match or the username was taken
			&render('landing');
		}

	}
	elsif ( exists $params{'username'} && exists $params{'password'} ) # Signin
	{	
		my $valid = &password_check( $params{'username'}, $params{'password'});
		if($valid == 1)
		{
			&signin( $params{'username'});
			&log_data("$params{'username'} logged in");
			&render('home', { username => $params{'username'} });
		}
		else
		{
			&log_data("$params{'username'} invalid login attempt");
			&render('invalidlogin', { username => $params{'username'} });
		}
	}
	elsif (exists $params{'logout'})
	{
		my $username = &getUsername();
		&log_data("$username logged out");
		&signout();
	}
	# LANDING PAGE
	else
	{
		
		&render('landing');
	}

}
else
{
	&render('home');
}

