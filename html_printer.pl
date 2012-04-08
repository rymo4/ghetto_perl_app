require 'layout.pl';

sub render {
	my $filename = $_[0];
	if ($_[1]){
		my %params = $_[1];
	}
	open( FILE, "views/$filename.html" ) || die "problem opening $filename.html $!";
	my @html = <FILE>; 
	close FILE;
	my $html;
	foreach my $line (@html)
	{
		$line =~ s/\$([\w-]+)/$params{$1}/g;
		$html = $html . $line;
	}
	
	&layout($html);
}

1; # cause this hash to return a true value...