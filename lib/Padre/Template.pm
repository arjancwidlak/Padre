package Padre::Template;

use 5.008;
use strict;
use warnings;
use File::Spec      ();
use Padre::Util     ();
use Padre::Constant ();
use Padre::Current  ();

our $VERSION = '0.91';

use constant TEMPLATE_DIRECTORY => Padre::Util::sharedir('templates');





######################################################################
# Main Methods

sub render {
	my $class = shift;
	my $path  = shift;
	my $name  = $path;

	# Resolve the full path if it is a core template
	unless ( File::Spec->file_name_is_absolute($path) ) {
		my $full = File::Spec->catfile( TEMPLATE_DIRECTORY, $path );
		unless ( -f $full ) {
			die "The core template '$path' does not exist";
		}
		$path = $full;
	}

	# Load the template file
	my $input = Padre::Util::slurp($path);
	unless ( $input ) {
		die "Failed to load template file '$name'";
	}

	# Hand off to Template::Tiny
	require Template::Tiny;
	require Padre::Util::Template;
	my $output = '';
	my $params = {
		config => Padre::Current->config,
		util   => Padre::Util::Template->new,
		@_,
	};
	Template::Tiny->new->process( $input, $params, \$output );

	return $output;
}

1;