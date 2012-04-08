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
			&log_data("$params{'new_username'} logged in");

			&render('home', { username => &getUsername });
		}
		else # FAILED REGISTRATION
		{
			&log_data("Failed registration attempt");	# TODO: add errors sine your password didnt match or the username was taken
			&render('landing', { errors => 'Make sure the password confirmation match!'});
		}
	}
	elsif ( exists $params{'username'} && exists $params{'password'} ) # Signin
	{	
		my $valid = &password_check( $params{'username'}, $params{'password'});
		if($valid == 1)
		{
			&signin( $params{'username'});
			&log_data("$params{'username'} logged in");
			&render('home', { username => &getUsername });
		}
		else
		{
			&log_data("$params{'username'} invalid login attempt");
			&render('landing', { errors => 'Invalid username/password combo!'});
		}
	}
	# LANDING PAGE
	else
	{
		&render('landing');
	}
}
else # you ARE logged in
{
	my $username = &getUsername();
	if (exists $params{'logout'}) # LOGGED OUT
	{
		&log_data("$username logged out");
		&signout(&getUsername());
		&render('landing');
	}
	elsif(exists $params{'play_id'} && exists $params{'numseats'}) # PLACED ORDER
	{
	
		my $available = &checkAvailability($params{'play_id'}, $params{'numseats'});
		my $play = &getPlayName($params{'play_id'});
		if($available)
		{
			&makeReservation($params{'play_id'}, $params{'numseats'});
			&log_data("$username new reservation, $params{'numseats'} seats for $play");
			&render('home', { success => 'Reservation succesfully made'});
		}
		else
		{
			&log_data("$username failed reservation, $params{'numseats'} seats for $play insufficient availability");
			&render('home', { errors => 'Not enough seats available for your play and time selection' });

		}
	}
	elsif(exists $params{'about'})
	{
		my $numUsers = &getNumUsers();
		my $numReservations = &getNumReservations();
		&render('stats', { numUsers => $numUsers , numReservations => $numReservations, reservations => &output_reservations_html });
	}
	else
	{
		
		&render('home', { username => &getUsername});

	}
	
}

