#
# winswitch.pl
# switch windows faster and without saying messed up commands like "oh/win 23" to a channel
#
# usage:	just type the window numer + TAB and you are where you wanted to be
#			ie. "23<TAB>" or "leche: hey i got something for you23<TAB>"
#			both will change to window 23, and "23" will be removed from the input line
#			if there is no window 23, it will change to window 3 and "3" will be removed from the imput line
#			if there is no window 3, nothing will be done...
#			if there is an user named "you23foobar" this will be completed in the second case
#
#	special thanks to all the persons who inspired me to write that script by being unable to switch windows properly ;P
#
#	changelog:
#	r1		first release, main functionality only
#	r2		other completions got more priority now
#	r3		per_window_prompt-fix
#   r4		completion priority via settings value
#
#	todo:
#			o nothing


use strict;
use Irssi;
use POSIX;
use vars qw($VERSION %IRSSI);

$VERSION = "r4";
%IRSSI = (
    authors     => "Max \'sdx23\' Voit",
    contact     => "max.voit+dvis@with-eyes.net",
    name        => "winswitch",
    description => "switch windows using tab-completion...",
    license     => "GPLv3",
    url         => "http://irssi.org/",
    changed     => "Sat June 25 19:00 CEST 2009"
);

sub sig_complete {
	my ($comp_words, $win_rec, $word, $linestart, $want_space) = @_;

	# check if this completion is for us
	if($word =~ /(\d+)$/){
		# look out for a window with fitting refnum
		my @windows = Irssi::windows();
		my $found_num = 0;
		my $complete_num = $1;

		while( !$found_num and $complete_num != ''){
			for(@windows){
				$found_num = $complete_num if($_->{'refnum'} == $complete_num);
			}
			$complete_num =~ s/^\d//;
		}

		# switch to fitting window, delete digits and stop signal
		unless($found_num == -1){
			$$want_space = 0;
			$word =~ s/${found_num}$//;
			@$comp_words = $word;

			Irssi::signal_stop();

			Irssi::command("window $found_num");
		}

	}
}

# main
Irssi::settings_add_bool('winswitch','winswitch_complete_prio',1);

Irssi::signal_add_first('complete word', 'sig_complete') if (Irssi::settings_get_bool('winswitch_complete_prio'));
Irssi::signal_add_last('complete word', 'sig_complete') unless (Irssi::settings_get_bool('winswitch_complete_prio'));

# vim:set ts=4 sw=4 et:
