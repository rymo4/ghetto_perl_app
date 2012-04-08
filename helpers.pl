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
		if (int($numseats) > 0){
			$html_options = $html_options . '<option value="' . $play_id . '">' . $play . '</option>'
		}
	}
	return $html_options;
}

sub add_user { # takes username and hashed password
	open (FILE, ">>users.txt") || die "Problem opening users.txt $1";
	my $username = $_[0];
	my $hashed_password = $_[1];
	print FILE "$username=$hashed_password\n";
	close FILE;
}

sub parse_form { # used to parse raw form date into a hash of name => input
	my $raw_form = $_[0];
	my @parted = split(/&/, $raw_form);
	my %form;
	foreach my $part (@parted) {
		my @split = split(/=/, $part);
		$form{$split[0]}=$split[1];
	}
	return %form;
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
    	@tempData = split(/=/,$line);
    	chomp ($tempData[0]);
    	if($username eq $tempData[0])
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
    @tempData = split(/=/,$line);
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

sub isLoggedIn {

	my $user_ip = $ENV{REMOTE_ADDR}; 
	my $loggedIn = 0;

	open (FILE, "sessions.txt") || die "Problem opening sessions.txt $1";
	while($line=<FILE>)
  	{
      @tempData = split(/=/,$line);
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
    @tempData = split(/=/,$line);
    chomp ($tempData[0]);
    if($play_id eq $tempData[0])
    {
      chomp ($tempData[1]);
      my $seatsAvailable = int($tempData[1]);
      if(numSeats <= seatsAvailable)
      {
        $available = 1;
      }
    }
  }
	close FILE;
	return $available;
}

sub getPlayName
{
  my $play_id = $_[0];
  my $playName;
  open (FILE, "availability.txt") || die "Problem opening availability.txt $1";
  while($line=<FILE>)
  {
    @tempData = split(/=/,$line);
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
  my $play_id = $_[0]
  my $numSeats;
  open (FILE, "availability.txt") || die "Problem opening availability.txt $1";
  while($line=<FILE>)
  {
    @tempData = split(/=/,$line);
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


  print "$replace;"
  my $replace = "$play_id=$playName=$newNumSeats";

    local @ARGV = ($filename);
    local $^I = '.bac';
    while( <> ){
      if( s/$play_id=$play_id=$numSeats/$replace/ig ) {
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

