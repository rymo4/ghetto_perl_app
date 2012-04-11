require 'helpers.pl';
sub layout { # takes 1 string that contains what to insert in $yield
	my $yield = $_[0];
	my $errors = $_[1];
	my $success = $_[2];
	my $logout_button;
	if (&isLoggedIn){
		$logout_button = '<li><a href="javascript:document.logout.submit()">Logout</a></li>';
		$profile_button = '<li><a href="javascript:document.profile.submit()">My Profile</a></li>';
		$stats_button =  '<li><a href="javascript:document.stats.submit()">Stats</a></li>';
	}
		
	if ($errors){
		$errors = '<div class="alert alert-error">' . $errors . '</div>';
	}
	if ($success){
		$success =  '<div class="alert alert-success">' . $success . '</div>'; 
	}
	print <<"END_OF_PRINTING";
	<!DOCTYPE html>
	<html>
		<head>
			<title>Step5 webpage</title>
			<link href="http://twitter.github.com/bootstrap/assets/css/bootstrap.css" rel="stylesheet">
		</head>
		<body>
			<div class="navbar ">
			  <div class="navbar-inner">
			    <div class="container">
			      <ul class="nav nav-pills">
						 	$logout_button
							$profile_button
							$stats_button
						  <li><a href="#">Link</a></li>
						</ul>
			    </div>
			  </div>
			</div>
			<div class="container">
				$success
				$errors
				$yield
			</div>
			<div class="hidden">
					<form name="logout" action="main.pl.cgi" method=POST class="unstyled"><input type="hidden" name="logout"></form>
					<form name="profile" action="main.pl.cgi" method=POST><input type="hidden" name="profile"></form>
					<form name="stats" action="main.pl.cgi" method=POST><input type="hidden" name="Stats"></form>
					
					
			</div>
		</body>
	</html>
END_OF_PRINTING
}
1;