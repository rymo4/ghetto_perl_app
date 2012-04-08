use String::Random;

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
	%form;
}

sub signin {
	my $username = $_[0];
	open (FILE, ">>sessions.txt") || die "Problem opening sessions.txt $1";
	my $random_string = &generate_random_string(11);
	print FILE "$username=$random_string\n";
	close FILE;
}

sub signout {
	my $username = $_[0];
	
	# remove the line with the username in it from sessions.txt
}

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

1;

