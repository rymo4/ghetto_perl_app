
use Digest::MD5 qw(md5 md5_hex md5_base64);

#DATABASE CONSTANTS

#USER DATABASE
my $USER_COLUMN = 0;
my $PASSWORD_COLUMN = 1;
my $EMAIL_COLUMN = 2;

#SESSIONS DATABASE
my $IP_COLUMN = 0;
my $IPUSER_COLUMN = 1;

#RESERVATION DATABASE
my $USER_COLUMN = 0;
my $RESID_COLUMN = 1;
my $NUMTICKS_COLUMN = 2;

#AVAILABILITY DATABASE
my $PLAYID_COLUMN = 0;
my $PLAYNAME_COLUMN = 1;
my $NUMTICKS_COLUM = 2;

sub send_password_reset_email {
	my $username = shift;
	my $email = &getEmail($username);
	my $password = &generate_random_string(10);
	&resetPassword($username, $password);
	my $message = "You have requested to reset your password. Your new password is $password. Please use this once and then change your password for security.";
	open (MAILH, "|mail -s \"Reset Your Password\" $email") || die "cant open mail handle, quitting";
	print MAILH "$message";
	close(MAILH);
}

sub generate_random_string
{
	my $length = shift;
	my @chars=('a'..'z','A'..'Z','0'..'9','_', '!'..'*');
	my $random_string;
	foreach (1..$length) 
	{
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}

sub output_reservations_html {
	my @parts = &getUserHistory;
	my @reservation_ids = $parts[0];
	my @num_tickets = $parts[1];
	my $formatted;
	my $index = 0;
	foreach my $play_id (@reservation_ids) {
		$formatted .= '<tr><td>' . &getPlayName($play_id) . ' - ' . $num_tickets[$index] . ' tickets</td>';
		$formatted .= <<"END_OF_PRINTING";
					<td>
						<form action="main.pl.cgi" method=POST>
						<input type="hidden" name="delete_reservation_id" value="$play_id">
						<input type="hidden" name="delete_reservation_tickets" value="$num_tickets[$index]">
						<input type="submit" value="Delete" class="btn btn-danger">
						</form>
					</td>
				</tr>
END_OF_PRINTING
	$index++;
	}
	return $formatted;
}

sub getUserHistory
{
  my $username = &getUsername();
  my (@reservation_ids, @num_tickets);
  open (FILE, "reservations.txt") || die "Problem opening reservations.txt $1";
	my @lines = <FILE>;
	close FILE;
  foreach my $line (@lines)
  {
    my @reservationDatabase = split(/=/,$line);
    chomp ($reservationDatabase[$USER_COLUMN]);
    if($username eq $reservationDatabase[$USER_COLUMN])
    {
      chomp ($reservationDatabase[$PLAYID_COLUMN]);
      chomp ($reservationDatabase[$NUMTICKS_COLUMN]);
      $numTickets = $reservationDatabase[$NUMTICKS_COLUMN];
			push(@reservation_ids, $reservationDatabase[$RESID_COLUMN]);
			push(@num_tickets, $numTickets);
    }
  }
	return (@reservation_ids, @num_tickets);
}

sub getPlayOptions {
	open (FILE, "availability.txt") || die "Problem opening availability.txt $1";
	@lines = <FILE>;
	close FILE;
	$html_options;
	foreach my $line (@lines) {
		my @parts = split(/=/, $line);
		my $play_id = @parts[0];
		my $play = @parts[1];
		my $numseats = @parts[2];
		
		if (int($numseats) > 0)
		{
			$html_options .= '<option value="' . $play_id . '">' . $play . '</option>';			
		}
		else
		{
				$html_options .= '<option value="' . $play_id . '">' . $play .' (SOLD OUT)' . '</option>';
		}
	}
	return $html_options;
}



sub add_user { # takes username and hashed password
	open (FILE, ">>users.txt") || die "Problem opening users.txt $1";
	my $username = $_[0];
	my $hashed_password = $_[1];
  my $email = $_[2];
	print FILE "$username=$hashed_password=$email\n";
	close FILE;
}

sub parse_form { # used to parse raw form date into a hash of name => input
	my $raw_form = $_[0];
	my @parted = split(/&/, $raw_form);
	my %form;
	foreach my $part (@parted) {
		my @split = split(/=/, $part);
		$split[1] =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
		$form{$split[0]}=$split[1];
	}
	return %form;
}



sub cancelReservation
{
  my $play_id = $_[0];
  my $numTickets = $_[1];
  my $username = &getUsername();

  my $numSeatsAvailable = &getNumSeats($play_id);
  my $newNumSeats = $numSeatsAvailable + $numTickets;
  my $playName = &getPlayName($play_id);

  #updates database adding th enew number of seats available
  my $filename = 'availability.txt';
  my $replace = "$play_id=$playName=$newNumSeats";

    local @ARGV = ($filename);
    local $^I = '.bac';
    while( <> ){
      if( s/$play_id=$playName=$numSeatsAvailable/$replace/ig ) {
         print;
      }
      else {
         print;
      }
   }

  my $filename = 'reservations.txt';
  my $replace = "";

    local @ARGV = ($filename);
    local $^I = '.bac';
    while( <> ){
      if( s/$username=$play_id=$numTickets/$replace/ig ) {
         print;
      }
      else {
         print;
      }
   }

}

sub log_data {
  open (FILE, ">>logfile.txt") || die "Problem opening logfile.txt $1";
  my $time = localtime;
  my $user_ip = $ENV{REMOTE_ADDR}; 
  print FILE "$_[0] at $time from IP:$user_ip\n";
  close FILE;
}

sub isNameAvailable{
	my $available = 1;
	my $username = $_[0];
	open (FILE, ">>users.txt") || die "Problem opening users.txt $1";
	while($line=<FILE>)
  	{
    	my @userDatabase = split(/=/,$line);
    	chomp ($userDatabase[$USER_COLUMN]);
    	if($username eq $userDatabase[$USER_COLUMN])
    	{
      		$available = 0;
    	}
  	}
  	close FILE;
  	return $available;
}

sub getUsername{
  my $user_ip = $ENV{REMOTE_ADDR};
  my $username;
  open (FILE, "sessions.txt") || die "Problem opening sessions.txt $1";
  while($line = <FILE>)
  {
    my @tempData = split(/=/,$line);
    chomp ($tempData[0]);
    if($tempData[0] eq $user_ip)
    {
      chomp ($tempData[1]);
      $username = $tempData[1];
    }
  }
  close FILE;
  return $username;
}

sub checkValidEmail{
  my $email = $_[0];
  my $valid = 0;
  if ($email=~/(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/)
  {
    $valid = 1;
  }
  return $valid;
}

sub getEmail{
  my $email;
  my $username;
  if($_[0])
  {
    $username = $_[0];
  }
  else
  {
    $username = &getUsername();
  }
  open (FILE, "users.txt") || die "Problem opening users.txt $1";
  my @lines = <FILE>;
  close FILE;
  foreach my $line (@lines)
  {
    @userDatabase = split(/=/,$line);
    chomp ($userDatabase[$EMAIL_COLUMN]);
    $email = $userDatabase[$EMAIL_COLUMN];
  }
  return $email;
}

sub resetPassword{
  my $newPassword = md5_hex($_[1]);
  my $username = $_[0];
  my $email = &getEmail();

  my $filename = 'users.txt';

    local @ARGV = ($filename);
    local $^I = '.bac';
    while( <> ){
      if( s/$username=.*/$username=$newPassword=$email/ig ) {
         print;
      }
      else {
         print;
      }
   }

  open (FILE, ">>users.txt") || die "Problem opening users.txt $1";
  my @lines = <FILE>;
  close FILE;
  foreach my $line (@lines)
  {
      @userDatabase = split(/=/,$line);
	}

}

sub isLoggedIn {

	my $user_ip = $ENV{REMOTE_ADDR}; 
	my $loggedIn = 0;

	open (FILE, "sessions.txt") || die "Problem opening sessions.txt $1";
	while($line=<FILE>)
  	{
      my @tempData = split(/=/,$line);
      chomp ($tempData[0]);
    	if($tempData[0] eq $user_ip)
    	{
      		$loggedIn = 1;
    	}
  	}
  	close FILE;
  	return $loggedIn;  	

}

sub checkAvailability {
  my $play_id = $_[0];
  my $numSeats = $_[1];
  my $available = 0;
  open (FILE, "availability.txt") || die "Problem opening availability.txt $1";
  while($line=<FILE>)
  {
    my @tempData = split(/=/,$line);
    chomp ($tempData[0]);
    if($play_id eq $tempData[0])
    {
      chomp ($tempData[2]);
      my $seatsAvailable = int($tempData[2]);
      if($numSeats <= $seatsAvailable)
      {
        $available = 1;
      }
    }
  }
	close FILE;
	return $available;
}

sub getNumUsers
{
  my $numUsers =0;
  open (FILE, "users.txt") || die "Problem opening users.txt $1";
  while($line=<FILE>)
  {
    $numUsers++;
  }
  close FILE;
  return $numUsers;
}

sub getNumReservations
{
  my $numReservations = 0;
  open (FILE, "reservations.txt") || die "Problem opening reservations.txt $1";
  while($line=<FILE>)
  {
    $numReservations++;
  }
  close FILE;
  return "$numReservations";

}

sub getPlayName
{
  my $play_id = $_[0];
  my $playName;
  open (FILE, "availability.txt") || die "Problem opening availability.txt $1";
  while($line=<FILE>)
  {
    my @tempData = split(/=/,$line);
    chomp ($tempData[0]);
    if($play_id eq $tempData[0])
    {
      $playName = $tempData[1];
    }
  }
  close FILE;
  return $playName;
}

sub getNumSeats
{
  my $play_id = $_[0];
  my $numSeats;
  open (FILE, "availability.txt") || die "Problem opening availability.txt $1";
  while($line=<FILE>)
  {
    my @tempData = split(/=/,$line);
    chomp ($tempData[0]);
    if($play_id eq $tempData[0])
    {
      $numSeats = int($tempData[2]);
    }
  }
  close FILE;
  return $numSeats;
}

sub makeReservation
{
  my $username = &getUsername();
  my $play_id = $_[0];
  my $numSeatsOrder = $_[1];
  my $numSeatsAvailable = &getNumSeats($play_id);
  my $newNumSeats = $numSeatsAvailable - $numSeatsOrder;
  my $playName = &getPlayName($play_id);

  #replaces info with new number of available seats
  my $filename = 'availability.txt';


  print "$replace";
  my $replace = "$play_id=$playName=$newNumSeats";

    local @ARGV = ($filename);
    local $^I = '.bac';
    while( <> ){
      if( s/$play_id=$playName=$numSeatsAvailable/$replace/ig ) {
         print;
      }
      else {
         print;
      }
   }

   open (FILE, ">>reservations.txt") || die "Problem opening availability.txt $1";
   print FILE "$username=$play_id=$numSeatsOrder\n";
   close FILE;
}

sub signin { #
	open (FILE, ">>sessions.txt") || die "Problem opening sessions.txt $1";
	my $username = $_[0];
	my $user_ip = $ENV{REMOTE_ADDR};
	print FILE "$user_ip=$username\n";
	close FILE;
}

sub signout {
	my $user_ip = $ENV{REMOTE_ADDR};
	my $filename = 'sessions.txt';
	my $replace = ' ';

   	local @ARGV = ($filename);
   	local $^I = '.bac';
   	while( <> ){
      if( s/$user_ip=$_[0]/$replace/ig ) {
         print;
      }
      else {
         print;
      }
   }
}
	
	# remove the line with the username in it from sessions.txt


#subroutine that checks whether the supplied password and username match an entry in the database. It relies on the MD5 algorithm to do so.
sub password_check
{
  my $line;
  my $username = $_[0];
  my $password = md5_hex($_[1]);
  my $valid = 0;
  chomp ($password);
  chomp ($username);
  my @tempData;
  open(FH1, "users.txt");
  while($line=<FH1>)
  {
    @tempData = split(/=/,$line);
    chomp ($tempData[0]);
    chomp ($tempData[1]);
    if($username eq $tempData[0]  &&  $password eq $tempData[1])
    {
      $valid = 1;
    }
  }
  close FH1;
  return $valid;
}


1;

