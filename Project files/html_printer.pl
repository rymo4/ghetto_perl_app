require 'layout.pl';
require 'helpers.pl';

sub render {
	my $filename = shift;
	my $params_ref = shift;
	my %params = %{$params_ref};
	my $play_options = &getPlayOptions;
	my $play_times = &getPlayTimes;
	$params{'play_options'} = $play_options;
	$params{'play_times'} = $play_times;
	open( FILE, "views/$filename.html" ) || die "problem opening $filename.html $!";
	my @html_raw = <FILE>; 
	close FILE;
	my $html;
	foreach my $line (@html_raw)
	{
			if ($line =~ /\$([\w-]+)/)
			{
				my $replace = $params{$1};		
				$line =~ s/\$([\w-]+)/$replace/g;
			}
			$html = $html . $line;
	}
	&layout($html, $params{'errors'},$params{'success'});
}

1; # cause this has to return a true value...