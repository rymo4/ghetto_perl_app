sub layout { # takes 1 string that contains what to insert in $yield
	my $yield = $_[0];
	print <<"END_OF_PRINTING";
	<!DOCTYPE html>
	<html>
		<head>
			<title>Step5 webpage</title>
			<link href="http://twitter.github.com/bootstrap/assets/css/bootstrap.css" rel="stylesheet">
			<style type="text/css">
				.container {
					margin-top: 50px;
				}
			</style>
		</head>
		<body>
			<div class="container">
				$yield
			</div>
		</body>
	</html>
END_OF_PRINTING
}
1;