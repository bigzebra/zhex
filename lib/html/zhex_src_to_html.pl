#!/usr/bin/perl

# ______________________________________________________________________
# markup_zhex_src.pl             Generate "pretty" HTML markup from Perl 
#                                source code (w/ PPI::Prettify).
# ______________________________________________________________________


use warnings;
use strict;

use PPI::Prettify;
use File::Slurp;

my @fn = 
  qw(../zhexsh.pl 
     ../ZHex.pm 
     ../ZHex/Common.pm 
     ../ZHex/CharMap.pm 
     ../ZHex/Console.pm 
     ../ZHex/Cursor.pm 
     ../ZHex/Debug.pm 
     ../ZHex/Display.pm 
     ../ZHex/Editor.pm 
     ../ZHex/Event.pm 
     ../ZHex/EventLoop.pm 
     ../ZHex/File.pm);

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

			my $src_fn_markup = "ZHex Editor source code filename: " . $fn_src;
			my $src_markup = prettify ({ 'code' => $src_code_raw });

			my $html_fc = $template;
			$html_fc =~ s/<FILENAME GOES HERE>/$src_fn_markup/;
			$html_fc =~ s/<SOURCE CODE GOES HERE>/$src_markup/;

			print "  Writing new HTML document to disk (" . $src_fn . " -> " . $html_fn . ").\n";

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

	my $links;
	foreach my $fn_src (@fn) {

		my $fn_html = &src_fn_to_html_fn ($fn_src);
		print "  Linking HTML document to index page (" . $fn_src . " -> " . $fn_html . ").\n";
		$links .= "<p><a href=\"" . $fn_html . "\">" . $fn_src . "</a></p>\n";
	}

	my $fn_index = "index.html";
	my $index_html_code = $template;
	$index_html_code =~ s/<FILENAME GOES HERE>/Index page: $fn_index/;
	$index_html_code =~ s/<SOURCE CODE GOES HERE>/$links/;

	print "  Writing new HTML file (index page: '" . $fn_index . "') to disk.\n";

	my $fh;
	open ($fh, (">" . $fn_index));
	print $fh $index_html_code;
	close $fh;
}

exit (0);

sub src_fn_to_html_fn {

	my $fn_src = shift;

	my $fn_html = $fn_src;
	$fn_html =~ s/^.*[\\\/](\w+?).p[lm]$/src-$1.html/i;

	return ($fn_html);
}


__DATA__

<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>ZHex - ZebraHex Editor v0.01: Project Source Code</title>
	<link rel="stylesheet" type="text/css" href="desert.css"/>
</head>
<body>
	<h2>ZHex - ZebraHex Editor v0.01</h2>
	<p><FILENAME GOES HERE></p>
	<div><SOURCE CODE GOES HERE></div>
</body>
</html>

