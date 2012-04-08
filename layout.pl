sub layout { # takes 1 string that contains what to insert in $yield
	my $yield = $_[0];
	my $errors = $_[1];
	my $success = $_[2];
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
			<div class="navbar">
			  <div class="navbar-inner">
			    <div class="container">
			      <ul class="nav">
						  <li><a href="#">Link</a></li>
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
		</body>
	</html>
END_OF_PRINTING
}
1;