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

sub isLoggedIn {

	my $user_ip = $ENV{REMOTE_ADDR}; 
	my $loggedIn = 0;
	open (FILE, ">>sessions.txt") || die "Problem opening sessions.txt $1";
	while($line=<FILE>)
  	{
    	if($line eq $user_ip)
    	{
      		$loggedIn = 1;
    	}
  	}
  	close FILE;
  	return $loggedIn;  	

}

sub signin { #
	open (FILE, ">>users.txt") || die "Problem opening sessions.txt $1";
	my $username = $_[0];
	my $user_ip = $ENV{REMOTE_ADDR};
	print FILE "$user_ip\n";
	close FILE;
}

sub signout {
	my $user_ip = $ENV{REMOTE_ADDR};
	my $filename = 'sessions.txt';
	my $replace = ' ';

   	local @ARGV = ($filename);
   	local $^I = '.bac';
   	while( <> ){
      if( s/$user_ip/$replace/ig ) {
         print;
      }
      else {
         print;
      }
   }
}
	
	# remove the line with the username in it from sessions.txt

sub generate_random_string
{
	my $length_of_randomstring=shift;
	my @chars=('a'..'z','A'..'Z','0'..'9','_');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}

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

