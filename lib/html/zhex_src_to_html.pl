#!/usr/bin/perl

# ______________________________________________________________________
# markup_zhex_src.pl
# Generate HTML markup from Perl source code (w/ PPI::Prettify).
# ______________________________________________________________________

use warnings;
use strict;

use PPI::Prettify;
use File::Slurp;

my @fn = 
  qw(../zhex.pl 
     ../ZHex.pm 
     ../ZHex/Common.pm 
     ../ZHex/CharMap.pm 
     ../ZHex/Console.pm 
     ../ZHex/Cursor.pm 
     ../ZHex/Debug.pm 
     ../ZHex/Display.pm 
     ../ZHex/Editor.pm 
     ../ZHex/Event.pm 
     ../ZHex/EventHandler.pm 
     ../ZHex/EventLoop.pm 
     ../ZHex/File.pm
     ../ZHex/Mouse.pm);

my $template;
READ_HTML_TEMPLATE: {

	while (read (main::DATA, my $buf, 1024)) 
		{ $template .= $buf; }
}

GENERATE_HTML_DOCUMENTS: {

	print "Generating html documents (w/ PPI::Prettify):\n";

	foreach my $src_fn (@fn) {

		if (-f $src_fn) {

			my $src = read_file ($src_fn);
			my $html_fn = &src_fn_to_html_fn ($src_fn);
			my $src_fn_markup = "ZHex Editor source code filename: " . $src_fn;
			my $src_markup = prettify ({ 'code' => $src });

			my $html_fc = $template;
			$html_fc =~ s/<FILENAME GOES HERE>/$src_fn_markup/;
			$html_fc =~ s/<SOURCE CODE GOES HERE>/$src_markup/;

			print sprintf ("  Writing new HTML document to disk %-22.22s -> %-22.22s\n", $src_fn, $html_fn);

			my $fh;
			open ($fh, ">" . $html_fn);
			print $fh $html_fc;
			close $fh;
		}
	}
	print "\n";
}

GENERATE_INDEX_PAGE: {

	print "Generating index page:\n";

	my $html_index;
	foreach my $src_fn (@fn) {

		my $html_fn = &src_fn_to_html_fn ($src_fn);
		print sprintf ("  Adding link to markup file %-22.22s for source code file %-22.22s to index page.\n", $html_fn, $src_fn);
		$html_index .= "<p><a href=\"" . $html_fn . "\">" . $src_fn . "</a></p>\n";
	}

	my $html_fn = "index.html";
	my $src_fn_markup = "ZHex source code index filename: " . $html_fn;
	my $src_markup = $html_index;

	my $html_fc = $template;
	$html_fc =~ s/<FILENAME GOES HERE>/$src_fn_markup/;
	$html_fc =~ s/<SOURCE CODE GOES HERE>/$src_markup/;

	print sprintf ("  Writing new HTML file %s to disk.\n", $html_fn);

	my $fh;
	open ($fh, (">" . $html_fn));
	print $fh $html_fc;
	close $fh;
}

exit (0);

sub src_fn_to_html_fn {

	my $fn_src = shift;

	my $fn_html = $fn_src;
	$fn_html =~ s/^.*[\\\/](\w+?).(p[lm])$/src-$1_$2.html/i;

	return ($fn_html);
}


__DATA__

<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>ZHex Editor v0.02: Project Source Code</title>
	<link rel="stylesheet" type="text/css" href="desert.css"/>
</head>
<body>
	<h2>ZHex Editor v0.02</h2>
	<p><FILENAME GOES HERE></p>
	<div><SOURCE CODE GOES HERE></div>
</body>
</html>

