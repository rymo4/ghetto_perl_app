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
			if (length $params{'new_password'} < 6)
			{
				&render('landing', { errors => 'The password has to be 6 or more charactes!'});
			}
			else 
			{
					&add_user($params{'new_username'}, md5_hex($params{'new_password'}), $params{'email'});
					&signin($params{'new_username'});
					&log_data("New user $params{'new_username'} registered");
					&log_data("$params{'new_username'} logged in");
					&render('home', { username => &getUsername });
			}
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
	elsif(exists $params{'play_name'} && exists $params{'play_time'} && exists $params{'numseats'}) # PLACED ORDER
	{
		
		$params{'play_name'} =~ s/\+/" "/seg;
		my $playName = $params{'play_name'}."+".$params{'play_time'};
		my $play_id = &getPlayID($playName);
		my $available = &checkAvailability($play_id, $params{'numseats'});		
		if($available)
		{
			&makeReservation($playName, $params{'numseats'});
			&log_data("$username new reservation, $params{'numseats'} seats for $playName");
			&render('home', { success => 'Reservation succesfully made'});
		}
		else
		{
			&log_data("$username failed reservation, $params{'numseats'} seats for $playName insufficient availability");
			&render('home', { errors => 'Not enough seats available for your play and time selection.' });
		}
	}
	elsif(exists $params{'stats'}) # STATS PAGE
	{
		my $numUsers = &getNumUsers();
		my $numReservations = &getNumReservations();
		&render('stats', { numUsers => $numUsers , stats => &get_stats_html,  tickets_available => &output_availability_html });
	}
	elsif(exists $params{'delete_reservation_id'} && exists $params{'delete_reservation_tickets'})
	{
		my $username = &getUsername();
		my $email = &getEmail();
		my $playName = &getPlayName($params{'delete_reservation_id'});
		my $ip_address = $ENV{REMOTE_ADDR};
		&cancelReservation($params{'delete_reservation_id'}, $params{'delete_reservation_tickets'});
		&log_data("$username canceled reservation, $params{'numseats'} seats for $playName");
		&render('profile', { email => $email , username => $username, ip_address => $ip_address, reservations => &output_reservations_html, PDF_options => &getPDFoptions, success => 'Reservation succesfully canceled' });
	}
	elsif(exists $params{'profile'})
	{
		my $username = &getUsername();
		my $email = &getEmail();
		my $ip_address = $ENV{REMOTE_ADDR};
		&log_data("$username viewd their profile");
		&render('profile', { email => $email , username => $username, ip_address => $ip_address, reservations => &output_reservations_html, PDF_options => &getPDFoptions, });
	}
	elsif(exists $params{'generate_pdf'})
	{
		my @reservations = &getReservations();
		#&generate_pdf_reservations(@reservations, $params{'PDF_options'});
		&generate_pdf_reservations(@reservations);
		my $username = &getUsername();
		my $email = &getEmail();
		my $ip_address = $ENV{REMOTE_ADDR};
		&log_data("$username generated a PDF of his reservations");
		&render('profile', { email => $email , username => $username, ip_address => $ip_address, reservations => &output_reservations_html, PDF_options => &getPDFoptions, success => 'PDF generated succesfully'});
	}
	elsif(exists $params{'forgot_username'})
	{
		my $username = &getUsername();
		my $email = &getEmail();
		my $ip_address = $ENV{REMOTE_ADDR};
		my $reservations = &output_reservations_html();
		if ($params{'confirm_password'} eq $params{'new_password'})
		{
			my $password = $params{'new_password'};
			&resetPassword($username, $password);
			&log_data("$username manually changed password");
			&render('profile', { email => $email , username => $username, ip_address => $ip_address, reservations => $reservations, PDF_options => &getPDFoptions, success => 'Password succesfully changed!'});
		}
		else
		{
			&render('profile', { email => $email , username => $username, ip_address => $ip_address, reservations => $reservations, PDF_options => &getPDFoptions, errors => 'Passwords entered dont match :('});
		}
	}
	elsif(exists $params{'home'})
	{
		&render('home', { username => &getUsername});
	}
	else
	{
		&render('home', { username => &getUsername});
	}	
}

