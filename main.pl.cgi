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
	if ( exists $params{'new_username'} && exists $params{'new_password'} && exists $params{'confirm_password'} && exists $params{'email'}) # Registration
	{
		my $available = &isNameAvailable( $params{'new_username'});
		my $validEmail = &checkValidEmail( $params{'email'});
		if ($params{'confirm_password'} eq $params{'new_password'} && $available && $validEmail)
		{
			# TODO: validations to make sure username does not exist, etc.
			&add_user($params{'new_username'}, md5_hex($params{'new_password'}), $params{'email'});
			&signin($params{'new_username'});
			&log_data("New user $params{'new_username'} registered");
			&log_data("$params{'new_username'} logged in");

			&render('home', { username => &getUsername });
		}
		elsif (!$validEmail)
		{
			&log_data("Failed registration attempt");
			&render('landing', { errors => 'Make sure the email entered is a valid one!'});
		}
		else # FAILED REGISTRATION
		{
			&log_data("Failed registration attempt");	# TODO: add errors sine your password didnt match or the username was taken
			&render('landing', { errors => 'Make sure the passwords match!'});
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
	elsif (exists $params{'forgot_username'})
	{
		&send_password_reset_email($params{'forgot_username'});
		&log_data("$params{'forgot_username'} requested automatic password change");
		&render('landing', { success => 'Great! Now check your email for your new password! Remember to change it right away!' });
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
		&render('stats', { numUsers => $numUsers , numReservations => $numReservations});
	}
	elsif(exists $params{'delete_reservation_id'} && exists $params{'delete_reservation_tickets'})
	{
		my $username = &getUsername();
		my $email = &getEmail();
		&cancelReservation($params{'delete_reservation_id'}, $params{'delete_reservation_tickets'});
		&render('profile', { email => $email , username => $username, reservations => &output_reservations_html });
	}
	elsif(exists $params{'profile'})
	{
		my $username = &getUsername();
		my $email = &getEmail();
		&render('profile', { email => $email , username => $username, reservations => &output_reservations_html });
	}
	elsif(exists $params{'forgot_username'})
	{
		my $username = &getUsername();
		my $email = &getEmail();
		my $reservations = &output_reservations_html();
		if ($params{'confirm_password'} eq $params{'new_password'})
		{
			my $password = $params{'new_password'};
			&resetPassword($username, $password);
			&log_data("$username manually changed password");
			&render('profile', { email => $email , username => $username, reservations => $reservations,  success => 'Password succesfully changed'});
		}
		else
		{
			&render('profile', { email => $email , username => $username, reservations => $reservations,  errors => 'Passwords entered dont match'});
		}
		
	}
	else
	{
		&render('home', { username => &getUsername});
	}	
}

