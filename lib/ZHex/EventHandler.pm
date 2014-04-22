#!/usr/bin/perl -w

package ZHex::EventHandler;

use 5.006;
use strict;
use warnings FATAL => 'all';

use ZHex::Common 
  qw(new 
     init 
     obj_init 
     check_args 
     ZHEX_VERSION
     EDT_CTXT_DEFAULT 
     EDT_CTXT_INSERT 
     EDT_CTXT_SEARCH);

BEGIN { require Exporter;
	our $VERSION   = ZHEX_VERSION;
	our @ISA       = qw(Exporter);
	our @EXPORT    = qw();
	our @EXPORT_OK = qw();
}

# Functions: Event Handling Functions.
#
#   ____				___________
#   NAME				DESCRIPTION
#   ____				___________
#   register_evt_callbacks()		Define callback subroutines for named functions.

sub register_evt_callbacks {

	my $self = shift;

	my $objCharMap = $self->{'obj'}->{'charmap'};
	my $objEvent   = $self->{'obj'}->{'event'};

	# ______________________________________________________________________
	# Event handlers for EDT_CTXT_DEFAULT (DEFAULT context events).

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'QUIT', 
	    'evt_cb'   => sub { $self->quit(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER Q'}) }) ] });

	# Previously defined within Console.pm module.

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'CONSCURS_INVIS', 
	    'evt_cb'   => sub { $self->w32cons_cursor_invisible(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER V'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'CONSCURS_VIS', 
	    'evt_cb'   => sub { $self->w32cons_cursor_visible(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN CAPITAL LETTER V'}) }) ] });

	# Previously defined within Cursor.pm module.

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_BEG', 
	    'evt_cb'   => sub { $self->curs_move_beg(); }, 
	     'evt' => [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'CIRCUMFLEX ACCENT'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_END', 
	    'evt_cb'   => sub { $self->curs_move_end(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'DOLLAR SIGN'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'INCR_CURS_CTXT', 
	    'evt_cb'   => sub { $self->curs_ctxt_incr(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'CARRIAGE RETURN (CR)'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'DECR_CURS_CTXT', 
	    'evt_cb'   => sub { $self->curs_ctxt_decr(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'ESCAPE'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_FORWARD', 
	    'evt_cb'   => sub { $self->curs_mv_fwd(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  9,     # 3
			   '4' => 15,     # 4
			   '5' =>  9,     # 5
			   '6' => 32 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  9,     # 3
			   '4' => 15,     # 4
			   '5' =>  9,     # 5
			   '6' =>  0 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_BACK', 
	    'evt_cb'   => sub { $self->curs_mv_back(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  9,     # 3
			   '4' => 15,     # 4
			   '5' =>  9,     # 5
			   '6' => 48 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  9,     # 3
			   '4' => 15,     # 4
			   '5' =>  9,     # 5
			   '6' => 16 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_UP', 
	    'evt_cb'   => sub { $self->curs_mv_up(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  38,     # 3
			   '4' =>  72,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  38,     # 3
			   '4' =>  72,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_DOWN', 
	    'evt_cb'   => sub { $self->curs_mv_down(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  40,     # 3
			   '4' =>  80,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  40,     # 3
			   '4' =>  80,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_LEFT', 
	    'evt_cb'   => sub { $self->curs_mv_left(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER H'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '3' =>  37,     # 3
			   '4' =>  75,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  37,     # 3
			   '4' =>  75,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'MOVE_CURS_RIGHT', 
	    'evt_cb'   => sub { $self->curs_mv_right(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER L'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '3' =>  39,     # 3
			   '4' =>  77,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  39,     # 3
			   '4' =>  77,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 })   # 6
	                ] });

	# Previously defined within Display.pm module.

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'DEBUG_OFF', 
	    'evt_cb'   => sub { $self->debug_off(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER D'}) }) ]
	   });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'DEBUG_ON', 
	    'evt_cb'   => sub { $self->debug_on(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN CAPITAL LETTER D'}) }) ]
	   });

	# Previously defined within Editor.pm module.

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'VSTRETCH', 
	    'evt_cb'   => sub { $self->vstretch(); },
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  38,     # 3
			   '4' =>  72,     # 4
			   '5' =>   0,     # 5
			   '6' => 264 }),  # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'VCOMPRESS', 
	    'evt_cb'   => sub { $self->vcompress(); },
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '3' =>  40,     # 3
			   '4' =>  80,     # 4
			   '5' =>   0,     # 5
			   '6' => 264 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'SCROLL_UP_1LN', 
	    'evt_cb'   => sub { $self->scroll_up_1x_line(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER K'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '0' => 2,         # 0
	                   '3' => 7864320,   # 3
			   '5' => 4 })       # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'SCROLL_UP_1PG', 
	    'evt_cb'   => sub { $self->scroll_up_1x_page(); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN CAPITAL LETTER J'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '3' =>  33,     # 3
			   '4' =>  73,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  33,     # 3
			   '4' =>  73,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'SCROLL_DOWN_1LN', 
	    'evt_cb'   => sub { $self->scroll_down_1x_line(); },  
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER J'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '0' => 2,          # 0
			   '3' => -7864320,   # 3
			   '5' => 4 }),       # 5
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'SCROLL_DOWN_1PG', 
	    'evt_cb'   => sub { $self->scroll_down_1x_page(); },
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN CAPITAL LETTER K'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'SPACE'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '3' =>  34,     # 3
			   '4' =>  81,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  34,     # 3
			   '4' =>  81,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'INSERT_MODE', 
	    'evt_cb'   => sub { $self->insert_mode(); },
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER I'}) }), 
	                $objEvent->gen_evt_array 
	                ({ '3' =>  45,     # 3
			   '4' =>  82,     # 4
			   '5' =>   0,     # 5
			   '6' => 288 }),  # 6
			$objEvent->gen_evt_array 
	                ({ '3' =>  45,     # 3
			   '4' =>  82,     # 4
			   '5' =>   0,     # 5
			   '6' => 256 })   # 6
	                ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'SEARCH_MODE', 
	    'evt_cb'   => sub { $self->search_mode(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN SMALL LETTER S'}) }) ] });

	# Previously defined within File.pm module.

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'WRITE_DISK', 
	    'evt_cb'   => sub { $self->write_file(); },
	    'evt'      => [ $objEvent->gen_evt_array 
	                      ({ '5' => $objCharMap->chr_map_ord_val 
	                                  ({'lname' => 'LATIN SMALL LETTER W'}) }) ] });

	# Previously defined within Mouse.pm module.

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'L_MOUSE_BUTTON', 
	    'evt_cb'   => sub { $self->lmouse ({ 'evt' => $_[0]->{'evt'} }); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '0' => 2,
	                   '3' => 1 }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'R_MOUSE_BUTTON', 
	    'evt_cb'   => sub { $self->rmouse ({ 'evt' => $_[0]->{'evt'} }); }, 
	    'evt' =>  [ $objEvent->gen_evt_array 
	                ({ '0' => 2,
	                   '3' => 2 }) ] });

	# ______________________________________________________________________
	# UNSUPPORTED

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'JUMP_TO_LINE', 
	    'evt_cb'   => sub { return (0); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN CAPITAL LETTER J'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'COPY_REGION', 
	    'evt_cb'   => sub { return (0); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN CAPITAL LETTER Z'}) }) ] });   # <--- Change to CTRL-C

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'CUT_REGION', 
	    'evt_cb'   => sub { return (0); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN CAPITAL LETTER Z'}) }) ] });   # <--- Change to CTRL-X

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'PASTE_BUFFER', 
	    'evt_cb'   => sub { return (0); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN CAPITAL LETTER Z'}) }) ] });   # <--- Change to CTRL-V

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_DEFAULT, 
	    'evt_nm'   => 'UNDO_LAST', 
	    'evt_cb'   => sub { return (0); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'LATIN CAPITAL LETTER Z'}) }) ] });   # <--- Change to CTRL-Z

	# ______________________________________________________________________
	# Event handlers for EDT_CTXT_INSERT (INSERT context events).

	# _______________   ___________________ _____________________ ____________________                       _________________ 
	# FUNCTION NAME     KEYBOARD MAPPING    |CHAR|VKCD|VSCD|CTRL| FUNCTION DESCRIPTION                       INTERNAL FUNCTION 
	# _______________   ___________________ |____|____|____|____| ____________________                       _________________ 
	# INSERT_ESCAPE     [ESCAPE] Key        | 27 |  - |  - |  - | Decrease Cursor Context/Stop  Editing      insert_escape() 
	# INSERT_BACKSPACE  [BACKSPACE] Key     |    |    |    |    | Delete Character Left Of Cursor            insert_backspace()
	# INSERT_CHAR       <ANY KEY>           |    |    |    |    | Insert Character At Cursor                 insert_char()
	# INSERT_ENTER      [ENTER] Key         |    |    |    |    | Finish Inserting Character(s)              insert_enter()
	# INSERT_L_ARROW    [LEFT ARROW] Key    |    |    |    |    | Move Cursor To The Left One Character      insert_l_arrow()
	# INSERT_R_ARROW    [RIGHT ARROW] Key   |    |    |    |    | Move Cursor To The Right One Character     insert_r_arrow()

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_INSERT, 
	    'evt_nm'   => 'INSERT_ESCAPE', 
	    'evt_cb'   => sub { $self->insert_escape(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'ESCAPE'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_INSERT, 
	    'evt_nm'   => 'INSERT_BACKSPACE', 
	    'evt_cb'   => sub { $self->insert_backspace(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'BACKSPACE'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_INSERT, 
	    'evt_nm'   => 'INSERT_ENTER', 
	    'evt_cb'   => sub { $self->insert_enter(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'CARRIAGE RETURN (CR)'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_INSERT, 
	    'evt_nm'   => 'INSERT_L_ARROW', 
	    'evt_cb'   => sub { $self->insert_l_arrow(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '3' => 37, 
	                                        '4' => 75, 
	                                        '5' => 0, 
	                                        '6' => 288 }), 
	                $objEvent->gen_evt_array ({ '3' => 37, 
	                                        '4' => 75, 
	                                        '5' => 0, 
	                                        '6' => 256 }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_INSERT, 
	    'evt_nm'   => 'INSERT_R_ARROW', 
	    'evt_cb'   => sub { $self->insert_r_arrow(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '3' => 39, 
	                                        '4' => 77, 
	                                        '5' => 0, 
	                                        '6' => 288 }), 
	                $objEvent->gen_evt_array ({ '3' => 39, 
	                                        '4' => 77, 
	                                        '5' => 0, 
	                                        '6' => 256 }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_INSERT, 
	    'evt_nm'   => 'INSERT_CHAR', 
	    'evt_cb'   => sub { $self->insert_char(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'SPACE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'EXCLAMATION MARK' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'QUOTATION MARK' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'NUMBER SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DOLLAR SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'PERCENT SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'AMPERSAND' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'APOSTROPHE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LEFT PARENTHESIS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'RIGHT PARENTHESIS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'ASTERISK' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'PLUS SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'COMMA' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'HYPHEN-MINUS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'FULL STOP' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'SOLIDUS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT ZERO' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT ONE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT TWO' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT THREE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT FOUR' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT FIVE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT SIX' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT SEVEN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT EIGHT' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT NINE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'COLON' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'SEMICOLON' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LESS-THAN SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'EQUALS SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'GREATER-THAN SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'QUESTION MARK' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'COMMERCIAL AT' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER A' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER B' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER C' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER D' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER E' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER F' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER G' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER H' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER I' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER J' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER K' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER L' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER M' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER N' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER O' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER P' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER Q' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER R' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER S' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER T' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER U' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER V' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER W' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER X' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER Y' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER Z' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LEFT SQUARE BRACKET' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'REVERSE SOLIDUS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'RIGHT SQUARE BRACKET' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'CIRCUMFLEX ACCENT' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LOW LINE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'GRAVE ACCENT' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER A' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER B' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER C' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER D' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER E' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER F' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER G' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER H' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER I' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER J' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER K' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER L' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER M' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER N' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER O' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER P' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER Q' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER R' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER S' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER T' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER U' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER V' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER W' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER X' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER Y' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER Z' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LEFT CURLY BRACKET' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'VERTICAL LINE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'RIGHT CURLY BRACKET' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'TILDE' }) }) ] });

	# ______________________________________________________________________
	# Event handlers for EDT_CTXT_SEARCH (SEARCH context events).

	# _______________   ___________________ _____________________ ____________________                       _________________ 
	# FUNCTION NAME     KEYBOARD MAPPING    |CHAR|VKCD|VSCD|CTRL| FUNCTION DESCRIPTION                       INTERNAL FUNCTION 
	# _______________   ___________________ |____|____|____|____| ____________________                       _________________ 
	# SEARCH_BACKSPACE  [BACKSPACE] Key     | 27 |  - |  - |  - | ...                                        search_backspace()
	# SEARCH_CHAR       <ANY KEY>           | 27 |  - |  - |  - | ...                                        search_char()
	# SEARCH_ENTER      [ENTER] Key         | 27 |  - |  - |  - | ...                                        search_enter()
	# SEARCH_ESCAPE     [ESCAPE] Key        | 27 |  - |  - |  - | Decrease Cursor Context/Stop  Editing      search_escape() 
	# SEARCH_L_ARROW    [LEFT ARROW] Key    | 27 |  - |  - |  - | ...                                        search_l_arrow()
	# SEARCH_R_ARROW    [RIGHT ARROW] Key   | 27 |  - |  - |  - | ...                                        search_r_arrow()

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_SEARCH, 
	    'evt_nm'   => 'SEARCH_BACKSPACE', 
	    'evt_cb'   => sub { $self->search_backspace(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'BACKSPACE'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_SEARCH, 
	    'evt_nm'   => 'SEARCH_ENTER', 
	    'evt_cb'   => sub { $self->search_enter(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'CARRIAGE RETURN (CR)'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_SEARCH, 
	    'evt_nm'   => 'SEARCH_ESCAPE', 
	    'evt_cb'   => sub { $self->search_escape(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({'lname' => 'ESCAPE'}) }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_SEARCH, 
	    'evt_nm'   => 'SEARCH_L_ARROW', 
	    'evt_cb'   => sub { $self->search_l_arrow(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '3' => 37, 
	                                        '4' => 75, 
	                                        '5' => 0, 
	                                        '6' => 288 }), 
	                $objEvent->gen_evt_array ({ '3' => 37, 
	                                        '4' => 75, 
	                                        '5' => 0, 
	                                        '6' => 256 }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_SEARCH, 
	    'evt_nm'   => 'SEARCH_R_ARROW', 
	    'evt_cb'   => sub { $self->search_r_arrow(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '3' => 39, 
	                                        '4' => 77, 
	                                        '5' => 0, 
	                                        '6' => 288 }), 
	                $objEvent->gen_evt_array ({ '3' => 39, 
	                                        '4' => 77, 
	                                        '5' => 0, 
	                                        '6' => 256 }) ] });

	$objEvent->register_callback 
	  ({'edt_ctxt' => EDT_CTXT_SEARCH, 
	    'evt_nm'   => 'SEARCH_CHAR', 
	    'evt_cb'   => sub { $self->search_char(); },
	    'evt' =>  [ $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'SPACE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'EXCLAMATION MARK' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'QUOTATION MARK' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'NUMBER SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DOLLAR SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'PERCENT SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'AMPERSAND' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'APOSTROPHE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LEFT PARENTHESIS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'RIGHT PARENTHESIS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'ASTERISK' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'PLUS SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'COMMA' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'HYPHEN-MINUS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'FULL STOP' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'SOLIDUS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT ZERO' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT ONE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT TWO' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT THREE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT FOUR' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT FIVE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT SIX' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT SEVEN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT EIGHT' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'DIGIT NINE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'COLON' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'SEMICOLON' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LESS-THAN SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'EQUALS SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'GREATER-THAN SIGN' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'QUESTION MARK' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'COMMERCIAL AT' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER A' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER B' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER C' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER D' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER E' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER F' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER G' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER H' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER I' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER J' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER K' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER L' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER M' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER N' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER O' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER P' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER Q' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER R' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER S' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER T' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER U' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER V' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER W' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER X' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER Y' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN CAPITAL LETTER Z' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LEFT SQUARE BRACKET' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'REVERSE SOLIDUS' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'RIGHT SQUARE BRACKET' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'CIRCUMFLEX ACCENT' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LOW LINE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'GRAVE ACCENT' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER A' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER B' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER C' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER D' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER E' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER F' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER G' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER H' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER I' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER J' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER K' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER L' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER M' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER N' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER O' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER P' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER Q' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER R' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER S' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER T' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER U' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER V' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER W' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER X' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER Y' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LATIN SMALL LETTER Z' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'LEFT CURLY BRACKET' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'VERTICAL LINE' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'RIGHT CURLY BRACKET' }) }),
	                $objEvent->gen_evt_array ({ '5' => $objCharMap->chr_map_ord_val ({ 'lname' => 'TILDE' }) }) ] });

	return (1);
}

# Functions: EDT_CTXT_DEFAULT context event handlers.
#
#   ____			__________	___________
#   NAME			Event Name	DESCRIPTION
#   ____			__________	___________
#   quit()			QUIT		Break out of event_loop(), clean up, exit().
#   w32cons_cursor_invisible	...		...
#   w32cons_cursor_visible	...		...
#   curs_move_beg		...		...
#   curs_move_end		...		...
#   curs_ctxt_incr		...		...
#   curs_ctxt_decr		...		...
#   curs_mv_back		...		...
#   curs_mv_fwd			...		...
#   curs_mv_up			...		...
#   curs_mv_down		...		...
#   curs_mv_left		...		...
#   curs_mv_right		...		...
#   debug_off			...		...
#   debug_on			...		...
#   vstretch			...		...
#   vcompress			...		...
#   scroll_up_1x_line		...		...
#   scroll_up_1x_page		...		...
#   scroll_down_1x_line		...		...
#   scroll_down_1x_page		...		...
#   insert_mode			...		...
#   search_mode			...		...
#   write_file			...		...
#   lmouse			...		...
#   rmouse			...		...

sub quit {

	my $self = shift;

	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	$objEventLoop->{'FLAG_QUIT'} = 1;

	return (1);
}

# ______________________________________________________________________________
# Previously defined within Console.pm module.

sub w32cons_cursor_invisible {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	$objConsole->w32cons_cursor_invisible();

	return (1);
}

sub w32cons_cursor_visible {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	$objConsole->w32cons_cursor_visible();

	return (1);
}

# ______________________________________________________________________________
# Previously defined within Cursor.pm module.

sub curs_move_beg {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objEditor = $self->{'obj'}->{'editor'};

	$objCursor->set_curs_pos 
	  ({'curs_pos' => 0});
	$objEditor->set_edt_pos 
	  ({'edt_pos' => 0}); 

	return (1);
}

sub curs_move_end { 

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objEditor = $self->{'obj'}->{'editor'};
	my $objFile    = $self->{'obj'}->{'file'};

	$objCursor->set_curs_ctxt 
	  ({'curs_ctxt' => 2});
	$objCursor->set_curs_pos 
	  ({'curs_pos' => ($objFile->file_len() - 1)});
	$objEditor->dsp_pos_adjust 
	  ({'curs_pos' => $objCursor->{'curs_pos'} }); 

	return (1);
}

sub curs_ctxt_incr {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};

	$objCursor->curs_ctxt_incr();

	return (1);
}

sub curs_ctxt_decr {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};

	$objCursor->curs_ctxt_decr();

	return (1);
}

sub curs_mv_back {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objEditor = $self->{'obj'}->{'editor'};

	$objCursor->curs_mv_back();
	$objEditor->dsp_pos_adjust 
	  ({'curs_pos' => $objCursor->{'curs_pos'} }); 

	return (1);
}

sub curs_mv_fwd {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objEditor = $self->{'obj'}->{'editor'};
	my $objFile   = $self->{'obj'}->{'file'};

	$objCursor->curs_mv_fwd ({'file_len' => $objFile->file_len()});
	$objEditor->dsp_pos_adjust 
	  ({'curs_pos' => $objCursor->{'curs_pos'} }); 

	return (1);
}

sub curs_mv_up {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objEditor = $self->{'obj'}->{'editor'};

	$objCursor->curs_mv_up();
	$objEditor->dsp_pos_adjust 
	  ({'curs_pos' => $objCursor->{'curs_pos'} }); 

	return (1);
}

sub curs_mv_down {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objEditor = $self->{'obj'}->{'editor'};
	my $objFile   = $self->{'obj'}->{'file'};

	$objCursor->curs_mv_down ({'file_len' => $objFile->file_len()});
	$objEditor->dsp_pos_adjust 
	  ({'curs_pos' => $objCursor->{'curs_pos'} }); 

	return (1);
}

sub curs_mv_left {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};

	$objCursor->curs_mv_left();

	return (1);
}

sub curs_mv_right {

	my $self = shift;

	my $objCursor = $self->{'obj'}->{'cursor'};
	my $objFile   = $self->{'obj'}->{'file'};

	$objCursor->curs_mv_right ({'file_len' => $objFile->file_len()});

	return (1);
}

# Previously defined within Display.pm module.

sub debug_off {

	my $self = shift;

	my $objDisplay = $self->{'obj'}->{'display'};

	$objDisplay->debug_off();

	return (1);
}

sub debug_on {

	my $self = shift;

	my $objDisplay = $self->{'obj'}->{'display'};

	$objDisplay->debug_on();

	return (1);
}

# Previously defined within Editor.pm module.

sub vstretch { 

	my $self = shift;

	my $objCursor  = $self->{'obj'}->{'cursor'};
	my $objEditor  = $self->{'obj'}->{'editor'};
	my $objDisplay = $self->{'obj'}->{'display'};
	my $objFile    = $self->{'obj'}->{'file'};

	$objEditor->vstretch 
	  ({'max_columns' => $objDisplay->max_columns(), 
	    'file_len'    => $objFile->file_len()});
	$objCursor->set_sz_column 
	  ({'sz_column' => $objEditor->{'sz_column'}});
	$objDisplay->adjust_display(); 

	return (1);
}

sub vcompress { 

	my $self = shift;

	my $objCursor  = $self->{'obj'}->{'cursor'};
	my $objEditor  = $self->{'obj'}->{'editor'};
	my $objDisplay = $self->{'obj'}->{'display'};
	my $objFile    = $self->{'obj'}->{'file'};

	$objEditor->vcompress();
	$objCursor->set_sz_column 
	  ({'sz_column' => $objEditor->{'sz_column'}});
	$objCursor->curs_adjust 
	  ({'edt_pos' => $objEditor->{'edt_pos'}});
	$objDisplay->adjust_display(); 

	return (1);
}

sub scroll_up_1x_line { 

	my $self = shift;

	my $objCursor  = $self->{'obj'}->{'cursor'};
	my $objEditor  = $self->{'obj'}->{'editor'};

	$objEditor->scroll_up_1x_line(); 
	$objCursor->curs_adjust 
	  ({'edt_pos' => $objEditor->{'edt_pos'}}); 

	return (1);
}

sub scroll_up_1x_page { 

	my $self = shift;

	my $objCursor  = $self->{'obj'}->{'cursor'};
	my $objEditor  = $self->{'obj'}->{'editor'};

	$objEditor->scroll_up_1x_page();
	$objCursor->curs_adjust 
	  ({'edt_pos' => $objEditor->{'edt_pos'}}); 

	return (1);
}

sub scroll_down_1x_line { 

	my $self = shift;

	my $objCursor  = $self->{'obj'}->{'cursor'};
	my $objEditor  = $self->{'obj'}->{'editor'};
	my $objFile    = $self->{'obj'}->{'file'};

	$objEditor->scroll_down_1x_line
	  ({'file_len' => $objFile->file_len()});
	$objCursor->curs_adjust 
	  ({'edt_pos' => $objEditor->{'edt_pos'}}); 

	return (1);
}

sub scroll_down_1x_page { 

	my $self = shift;

	my $objCursor  = $self->{'obj'}->{'cursor'};
	my $objEditor  = $self->{'obj'}->{'editor'};
	my $objFile    = $self->{'obj'}->{'file'};

	$objEditor->scroll_down_1x_page
	  ({'file_len' => $objFile->file_len()});
	$objCursor->curs_adjust 
	  ({'edt_pos' => $objEditor->{'edt_pos'}}); 

	return (1);
}

sub insert_mode { 

	my $self = shift;

	my $objEditor = $self->{'obj'}->{'editor'};

	$objEditor->insert_mode(); 

	return (1);
}

sub search_mode { 

	my $self = shift;

	my $objEditor = $self->{'obj'}->{'editor'};

	$objEditor->search_mode(); 

	return (1);
}

# Previously defined within File.pm module.

sub write_file { 

	my $self = shift;

	my $objFile = $self->{'obj'}->{'file'};

	$objFile->write_file ({'fn' => $objFile->{'fn'}});

	return (1);
}

# Previously defined within Mouse.pm module.

sub lmouse { 

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'lmouse',
	     'test' => 
		[{'evt' => 'arrayref'}] });

	my $objMouse = $self->{'obj'}->{'mouse'};

	$objMouse->lmouse ({ 'xpos'=>$arg->{'evt'}->[1], 'ypos'=>$arg->{'evt'}->[2] }); 

	return (1);
}

sub rmouse { 

	my $self = shift;
	my $arg  = shift;

	$self->check_args 
	  ({ 'arg'  => $arg,
	     'func' => 'rmouse',
	     'test' => 
		[{'evt' => 'arrayref'}] });

	my $objMouse = $self->{'obj'}->{'mouse'};

	$objMouse->rmouse ({ 'xpos'=>$arg->{'evt'}->[1], 'ypos'=>$arg->{'evt'}->[2] }); 

	return (1);
}

# Functions: 'INSERT' context event handlers.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   insert_backspace()		Delete character to the left of the cursor.
#   insert_char()		Insert character at the cursor position.
#   insert_enter()		Begin search using the search string specified by user.
#   insert_escape()		Cancel search operation, switch context to EDT_CTXT_DEFAULT.
#   insert_l_arrow()		Move the cursor to the left within the text string inside the search box.
#   insert_r_arrow()		Move the cursor to the right within the text string inside the search box.

sub insert_backspace {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	if (exists  $self->{'insert_str'} && 
	    defined $self->{'insert_str'} && 
	          ! $self->{'insert_str'} eq '') {

		$self->{'insert_str'} =~ s/.$//;   # Remove last character from string.
		$self->{'insert_pos'}--;

		$objConsole->w32cons_cursor_move
		  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} - 1), 
		     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });
	}

	return (1);
}

sub insert_char {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDebug     = $self->{'obj'}->{'debug'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};
	my $objFile      = $self->{'obj'}->{'file'};

	my $char = chr ($objEventLoop->{'evt'}->[5]);

	# If inserting in hex mode, make sure character is: 1 - 9 or A - F.

	if (! ($char =~ /^[1234567890abcdefABCDEF]$/)) {

		$objDebug->errmsg ("Bad value for char: '" . $char . "'.");
		return (undef);
	}

	# If inserting in hex mode, check to see if the first character 
	# (of a two character string) was already entered.

	if (! exists  $self->{'first_hex_char'} || 
	    ! defined $self->{'first_hex_char'} || 
	           ! ($self->{'first_hex_char'} =~ /^[1234567890abcdefABCDEF]$/)) {

		$self->{'first_hex_char'} = $char;

		my ($xpos, $ypos) = 
		  $objCursor->dsp_coord 
		    ({ 'curs_pos' => $objCursor->{'curs_pos'}, 
		       'edt_pos'  => $objEditor->{'edt_pos'}, 
		       'dsp_ypad' => $objDisplay->{'dsp_xpad'}, 
		       'dsp_xpad' => $objDisplay->{'dsp_ypad'} });

		$xpos++;
		$objConsole->w32cons_cursor_move 
		  ({ 'xpos' => ($xpos + $objDisplay->{'dsp_xpad'}), 
		     'ypos' => ($ypos + $objDisplay->{'dsp_ypad'}) });
	}
	else {

		my $ord  = hex ($self->{'first_hex_char'} . $char);
		my $byte = chr ($ord);

		$self->{'first_hex_char'} = undef;

		# Insert character into place in file (at cursor position).

		my $rv = 
		  $objFile->insert_str 
		    ({ 'pos' => $objCursor->{'curs_pos'}, 
		       'str' => $byte });

		if (defined $rv && 
			    $rv == 1) 
		     { $objDebug->errmsg ("Call to insert_str() returned w/ success."); } 
		else { $objDebug->errmsg ("Call to insert_str() returned w/ failure.");
		       return (undef); }

		# Update editor cursor position.

		$objCursor->{'curs_pos'}++;

		# Update Win32 Console cursor position.

		my ($xpos, $ypos) = 
		  $objCursor->dsp_coord 
		    ({ 'curs_pos' => $objCursor->{'curs_pos'}, 
		       'edt_pos'  => $objEditor->{'edt_pos'}, 
		       'dsp_ypad' => $objDisplay->{'dsp_xpad'}, 
		       'dsp_xpad' => $objDisplay->{'dsp_ypad'} });

		$objConsole->w32cons_cursor_move 
		  ({ 'xpos' => ($xpos + $objDisplay->{'dsp_xpad'}), 
		     'ypos' => ($ypos + $objDisplay->{'dsp_ypad'}) });
	}

	return (1);
}

sub insert_enter {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# Switch editor context to EDT_CTXT_DEFAULT.

	$objEditor->{'edt_ctxt'} = EDT_CTXT_DEFAULT;

	# Change cursor context to 2 (byte mode).

	if (! ($objCursor->{'curs_ctxt'} == 2)) 
		{ $objCursor->{'curs_ctxt'} = 2; }

	# Set Win32 console cursor to invisible.
	# Move Win32 console cursor to top/left corner of display console.

	$objConsole->w32cons_cursor_invisible();
	$objConsole->w32cons_cursor_tleft_dsp();

	return (1);
}

sub insert_escape {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# Switch editor context to EDT_CTXT_DEFAULT.

	$objEditor->{'edt_ctxt'} = EDT_CTXT_DEFAULT;

	# Change cursor context to 2 (byte mode).

	if (! ($objCursor->{'curs_ctxt'} == 2)) 
		{ $objCursor->{'curs_ctxt'} = 2; }

	# Set Win32 console cursor to invisible.
	# Move Win32 console cursor to top/left corner of display console.

	$objConsole->w32cons_cursor_invisible();
	$objConsole->w32cons_cursor_tleft_dsp();

	return (1);
}

sub insert_l_arrow {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# ...

	return (1);
}

sub insert_r_arrow {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# ...

	return (1);
}

# Functions: EDT_CTXT_SEARCH context event handlers.
#
#   ____			___________
#   NAME			DESCRIPTION
#   ____			___________
#   search_backspace()
#   search_char()
#   search_enter()
#   search_escape()
#   search_l_arrow()
#   search_r_arrow()

sub search_backspace {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	         ! ($self->{'search_str'} eq '') && 
	    exists  $self->{'search_pos'} && 
	    defined $self->{'search_pos'} && 
	           ($self->{'search_pos'} > 0)) {

		if ($self->{'search_pos'} < length ($self->{'search_str'})) {

			substr $self->{'search_str'}, ($self->{'search_pos'} - 1), 1, '';
		}
		else {

			$self->{'search_str'} =~ s/.$//;   # Remove last character from string.
		}

		$self->{'search_pos'}--;

		# Update position of Win32 console cursor.

		$objConsole->w32cons_cursor_move
		  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} - 1), 
		     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });
	}

	return (1);
}

sub search_char {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	my $char = chr ($objEventLoop->{'evt'}->[5]);

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	         ! ($self->{'search_str'} eq '') && 
	    exists  $self->{'search_pos'} && 
	    defined $self->{'search_pos'} && 
	           ($self->{'search_pos'} =~ /^\d+?$/) && 
	           ($self->{'search_pos'} < (length ($self->{'search_str'})))) {

		substr $self->{'search_str'}, $self->{'search_pos'}, 0, $char;
	}
	else {

		$self->{'search_str'} .= $char;
	}

	$self->{'search_pos'}++;

	# Update position of Win32 console cursor.

	$objConsole->w32cons_cursor_move 
	  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} + 1), 
	     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });

	return (1);
}

sub search_enter {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDebug     = $self->{'obj'}->{'debug'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};
	my $objFile      = $self->{'obj'}->{'file'};

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	         ! ($self->{'search_str'} eq '')) {

		# index STR, SUBSTR, POSITION
		# index STR, SUBSTR
		#   The index function searches for one string within another, but
		#   without the wildcard-like behavior of a full regular-expression
		#   pattern match. It returns the position of the first occurrence
		#   of SUBSTR in STR at or after POSITION. If POSITION is omitted,
		#   starts searching from the beginning of the string. POSITION
		#   before the beginning of the string or after its end is treated
		#   as if it were the beginning or the end, respectively. POSITION
		#   and the return value are based at zero. If the substring is not
		#   found, "index" returns -1.

		$objDebug->errmsg 
		  ("Call to function file_bytes() returned w/ '" . 
		   scalar (@{ $objFile->file_bytes 
		                ({ 'ofs' => $objCursor->{'curs_pos'}, 
		                   'len' => (($objFile->file_len() - 1) - $objCursor->{'curs_pos'}) }) }) . "' bytes.");

		# Search for user specified string within file.

		my $rv = 
		  index ((join '', @{ $objFile->file_bytes 
		                        ({ 'ofs' => $objCursor->{'curs_pos'}, 
		                           'len' => (($objFile->file_len() - 1) - $objCursor->{'curs_pos'}) }) }), 
		         $self->{'search_str'}, 
		         1);

		if ($rv > 0) {

			# Move cursor to the beginning position where string was matched.

			$objCursor->{'curs_pos'} = ($objCursor->{'curs_pos'} + $rv);

			# Set cursor context to '2' (byte context).

			$objCursor->{'curs_ctxt'} = 2;

			# If cursor is positioned beyond the editor display, 
			# move the editor display so that cursor is in view.

			while ($objEditor->{'edt_pos'} < 
			         ($objCursor->{'curs_pos'} - 
			            (($objEditor->{'sz_line'} * $objEditor->{'sz_column'}) -
			                length ($self->{'search_str'})))) {

				$objEditor->{'edt_pos'} += $objEditor->{'sz_line'};
			}
		}
		else {

			# Restore cursor context to previous value (or byte mode).

			if (exists  $self->{'curs_ctxt_prev'} && 
			    defined $self->{'curs_ctxt_prev'} && 
				   ($self->{'curs_ctxt_prev'} =~ /^[012]$/)) {

				$objCursor->{'curs_ctxt'} = $self->{'curs_ctxt_prev'};
			}
			elsif (! ($objCursor->{'curs_ctxt'} =~ /^[012]$/)) {

				$objCursor->{'curs_ctxt'} = 2;
			}
		}
	}
	else {

		# Restore cursor context to previous value (or byte mode).

		if (exists  $self->{'curs_ctxt_prev'} && 
		    defined $self->{'curs_ctxt_prev'} && 
			   ($self->{'curs_ctxt_prev'} =~ /^[012]$/)) {

			$objCursor->{'curs_ctxt'} = $self->{'curs_ctxt_prev'};
		}
		elsif (! ($objCursor->{'curs_ctxt'} =~ /^[012]$/)) {

			$objCursor->{'curs_ctxt'} = 2;
		}
	}

	# Switch editor context to EDT_CTXT_DEFAULT.

	$objEditor->{'edt_ctxt'} = EDT_CTXT_DEFAULT;

	# Disable search box display.

	$objDisplay->{'d_elements'}->{'search_box'}->{'enabled'} = 0;

	# Set Win32 console cursor to invisible.
	# Move Win32 console cursor to top/left corner of display console.

	$objConsole->w32cons_cursor_invisible();
	$objConsole->w32cons_cursor_tleft_dsp();

	# Erase variables used to manage search user interface.

	$self->{'search_str'} = '';
	$self->{'search_pos'} = 0;

	return (1);
}

sub search_escape {

	my $self = shift;

	my $objConsole   = $self->{'obj'}->{'console'};
	my $objCursor    = $self->{'obj'}->{'cursor'};
	my $objDisplay   = $self->{'obj'}->{'display'};
	my $objEditor    = $self->{'obj'}->{'editor'};
	my $objEventLoop = $self->{'obj'}->{'eventloop'};

	# Switch editor context to EDT_CTXT_DEFAULT.

	$objEditor->{'edt_ctxt'} = EDT_CTXT_DEFAULT;

	# Restore cursor context to previous value (or 2: byte mode).

	if (exists  $self->{'curs_ctxt_prev'} && 
	    defined $self->{'curs_ctxt_prev'} && 
	           ($self->{'curs_ctxt_prev'} =~ /^[012]$/)) {

		$objCursor->{'curs_ctxt'} = $self->{'curs_ctxt_prev'};
	}
	elsif (! ($objCursor->{'curs_ctxt'} =~ /^[012]$/)) {

		$objCursor->{'curs_ctxt'} = 2;
	}

	# Disable search box display.

	$objDisplay->{'d_elements'}->{'search_box'}->{'enabled'} = 0;

	# Set Win32 console cursor to invisible.
	# Move Win32 console cursor to top/left corner of display console.

	$objConsole->w32cons_cursor_invisible();
	$objConsole->w32cons_cursor_tleft_dsp();

	# Erase variables used to manage search user interface.

	$self->{'search_str'} = '';
	$self->{'search_pos'} = 0;

	return (1);
}

sub search_l_arrow {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	          ! $self->{'search_str'} eq '' && 
	    exists  $self->{'search_pos'} && 
	    defined $self->{'search_pos'} && 
	            $self->{'search_pos'} =~ /^\d+?$/ && 
	            $self->{'search_pos'} > 0) {

		$self->{'search_pos'}--;

		# Update position of Win32 console cursor.

		$objConsole->w32cons_cursor_move
		  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} - 1), 
		     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });
	}

	return (1);
}

sub search_r_arrow {

	my $self = shift;

	my $objConsole = $self->{'obj'}->{'console'};

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	          ! $self->{'search_str'} eq '' && 
	    exists  $self->{'search_pos'} && 
	    defined $self->{'search_pos'} && 
	            $self->{'search_pos'} =~ /^\d+?$/ && 
	            $self->{'search_pos'} < (length ($self->{'search_str'}))) {

		$self->{'search_pos'}++;

		# Update position of Win32 console cursor.

		$objConsole->w32cons_cursor_move
		  ({ 'xpos' => ($objConsole->{'w32cons_curs_xpos'} + 1), 
		     'ypos' =>  $objConsole->{'w32cons_curs_ypos'} });
	}

	return (1);
}

# Functions: Display element routines.
#
#   ____		___________
#   NAME		DESCRIPTION
#   ____		___________
#   search_box()	Return a "search box" formatted for display console.

sub search_box {

	my $self = shift;

	# Display box 140 chars wide x 12 chars tall.

	my @search_box = 
	  ( '_' x 140, 
	    '|' . (' ' x 138) . '|', 
	    '_' x 140 );

	# If search string already defined, add it to the search box display.

	if (exists  $self->{'search_str'} && 
	    defined $self->{'search_str'} && 
	          ! $self->{'search_str'} eq '') {

		my $replaced_str = 
		  substr $search_box[1], 
		         2, 
		         length ($self->{'search_str'}), 
		         $self->{'search_str'};
	}

	return (\@search_box);
}


END { undef; }
1;


__END__


=head1 NAME

ZHex::EventHandler (ZHex/EventHandler.pm) - Event Handler Module, ZHex Editor.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

ZHex::EventHandler contains event handler callback subroutines for the 
ZHex Editor. Events (in this context) are almost entirely related user 
actions within the interface provided by the hex editor (accessed via 
the console). 

Usage:

    use ZHex::Common qw(new obj_init $VERS);
    my $objEventHandler = $self->{'obj'}->{'eventhandler'};
    $objEventHandler->evt_read();

=head1 EXPORT

No functions are exported.

=head1 SUBROUTINES/METHODS

=head2 new
Method new()...
= cut

=head2 init
Method init()...
= cut

=head2 obj_init
Method obj_init()...
= cut

=head2 debug_off
Method debug_off()...
= cut

=head2 debug_on
Method debug_on()...
= cut

=head2 insert_backspace
Method insert_backspace()...
= cut

=head2 insert_char
Method insert_char()...
= cut

=head2 insert_enter
Method insert_enter()...
= cut

=head2 insert_escape
Method insert_escape()...
= cut

=head2 insert_l_arrow
Method insert_l_arrow()...
= cut

=head2 insert_r_arrow
Method insert_r_arrow()...
= cut

=head2 move_to_beginning
Method move_to_beginning()...
= cut

=head2 move_to_end
Method move_to_end()...
= cut

=head2 quit
Method quit()...
= cut

=head2 register_evt_callbacks
Method register_evt_callbacks()...
= cut

=head2 search_backspace
Method search_backspace()...
= cut

=head2 search_box
Method search_box()...
= cut

=head2 search_char
Method search_char()...
= cut

=head2 search_enter
Method search_enter()...
= cut

=head2 search_escape
Method search_escape()...
= cut

=head2 search_l_arrow
Method search_l_arrow()...
= cut

=head2 search_mode
Method search_mode()...
= cut

=head2 search_r_arrow
Method search_r_arrow()...
= cut

=head2 vstretch
Method vstretch()...
= cut

=head2 vcompress
Method vcompress()...
= cut

=head2 curs_ctxt_decr
Method curs_ctxt_decr()...
= cut

=head2 curs_ctxt_incr
Method curs_ctxt_incr()...
= cut

=head2 curs_move_beg
Method curs_move_beg()...
= cut

=head2 curs_move_end
Method curs_move_end()...
= cut

=head2 curs_mv_back
Method curs_mv_back()...
= cut

=head2 curs_mv_down
Method curs_mv_down()...
= cut

=head2 curs_mv_fwd
Method curs_mv_fwd()...
= cut

=head2 curs_mv_left
Method curs_mv_left()...
= cut

=head2 curs_mv_right
Method curs_mv_right()...
= cut

=head2 curs_mv_up
Method curs_mv_up()...
= cut

=head2 insert_mode
Method insert_mode()...
= cut

=head2 lmouse
Method lmouse()...
= cut

=head2 rmouse
Method rmouse()...
= cut

=head2 scroll_down_1x_line
Method scroll_down_1x_line()...
= cut

=head2 scroll_down_1x_page
Method scroll_down_1x_page()...
= cut

=head2 scroll_up_1x_line
Method scroll_up_1x_line()...
= cut

=head2 scroll_up_1x_page
Method scroll_up_1x_page()...
= cut

=head2 w32cons_cursor_invisible
Method w32cons_cursor_invisible()...
= cut

=head2 w32cons_cursor_visible
Method w32cons_cursor_visible()...
= cut

=head2 write_file
Method write_file()...
= cut

=head1 AUTHOR

Double Z, C<< <zacharyz at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ZHex at rt.cpan.org>, or 
via the web interface: L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ZHex>.  
I will be notified, and then you'll automatically be notified of progress on 
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ZHex

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ZHex>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ZHex>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ZHex>

=item * Search CPAN

L<http://search.cpan.org/dist/ZHex/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Double Z.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1;

