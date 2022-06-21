#!/usr/local/bin/perl
#
# Cared for by Filipe G. Vieira <>
#
# Copyright Filipe G. Vieira
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

    tsv_merge.pl v1.1.17

=head1 SYNOPSIS

    perl tsv_merge.pl [OPTIONS] tsv_file1 tsv_file2 tsv_file3.gz ... tsv_fileN

    OPTIONS:
       --h help            This help screen
       --id INT[,INT]      Column to be used as matching ID (must have unique labels!).
                           If not defined, rows will be matched according to input order (default)
                           If several comma-sepparated values, columns will be merged.
       --rem_id INT[,INT]  Comma-separated list of columns to be removed from final file.
       --ifs CHAR          Input field separator [\t]
       --ofs CHAR          Output field separator [\t]
       --na CHAR           NA character [undef]
       --header            Treat first line in all files as a header (no column match)
       --max_lines INT     Only read first INT lines
       --transp            Transpose file
       --quiet             Run quietly
       fileN               Input files. If '-' input is read from STDIN

=head1 DESCRIPTION

    This script will merge provided TSV files according to "-id" fields, taking into 
    account filed sepparators and potential headers.
    Lines with no matching ID on other files are discarded or, if option "--na" was 
    provided, filled in with given character.
    Optionally, output TSV can be transposed if "-transp" option is provided.

=head1 AUTHOR

    Filipe G. Vieira - fgarrettvieira _at_ gmail _dot_ com

=head1 CONTRIBUTORS

    Additional contributors names and emails here

=cut

# Let the code begin...

use strict;
use warnings;
use Getopt::Long;
use IO::Zlib;
$| = 1;

my ($IDs, $rem_IDs, $ifs, $ofs, $NA, $header, $max_lines, $transp, $quiet);
my (@IDs, @rem_IDs, $n_fields, @t_out, @out, %out);

# Default values
$IDs = '';
$rem_IDs = '';
$ifs = "\t";
$ofs = "\t";
$max_lines = -1;

#Get the command-line options
&GetOptions('h|help'      => sub { exec('perldoc',$0); exit; },
	    "id=s"        => \$IDs,
	    "rem_id:s"    => \$rem_IDs,
	    "ifs=s"       => \$ifs,
	    "ofs=s"       => \$ofs,
	    "na=s"        => \$NA,
	    "header!"     => \$header,
	    "max_lines:i" => \$max_lines,
	    "t|transp!"   => \$transp,
	    "q|quiet!"    => \$quiet,
    );

# Convert ID column to 0-based
@IDs = sort {$a <=> $b} split(/,/,$IDs);
map {$_--} @IDs;
@rem_IDs = sort {$a <=> $b} split(/,/,$rem_IDs);
map {$_--} @rem_IDs;

# Check if any file provided
if($#ARGV < 0) {
    print(STDERR "ERROR: no file(s) provided!\n");
    exit(-1);
}


###############################################################################

# Read and Merge files
foreach my $in_tsv (@ARGV) {
    next unless(-s $in_tsv || $in_tsv eq "-");
    print(STDERR "# Processing file $in_tsv ...\n") if(!$quiet);
    &add_file($in_tsv, \@IDs, \@rem_IDs, \$n_fields, $ifs, $header, $max_lines, \%out);
}

# After adding all files, check to see if all have same length and fill in with $NA
print(STDERR "# Check if all lines have same length ...\n") if(!$quiet);
foreach my $key (keys(%out)) {
    my $n_extra_fields = $n_fields - ($#{$out{$key}} + 1);
    
    # Skip if fields are OK
    next if($n_extra_fields == 0);
    
    if( defined($NA) ) {
	push( @{$out{$key}}, ($NA) x $n_extra_fields );
    } else {
	delete($out{$key});
    }
}



# Convert Hash to Array
if($#IDs == -1) {
    push(@out, ($out{$_})) foreach (sort {$a <=> $b} keys(%out));
}
else {
    foreach (sort keys(%out)) {
	unshift(@{$out{$_}}, $_);
	push(@out, ($out{$_}));
    }
}


# Transpose Array
if ($transp) {
    print(STDERR "# Transposing file ...\n") if(!$quiet);
    my @t_out;
    foreach my $i (0..$#{$out[0]}) {
	push(@t_out, [map $_->[$i], @out]);
    }
    @out = @t_out;
}


# Print File
print(STDERR "# Printing to STDOUT ...\n") if(!$quiet);
print(join($ofs, @{$_})."\n") foreach (@out);

exit(0);


###############################################################################
sub add_file($$$$$$$) {
    my ($in_tsv, $key_IDs, $rem_IDs, $n_fields, $ifs, $header, $n_lines, $output) = @_;
    my ($cnt, $key, $nf, @line) = 0;

    my $FILE = new IO::Zlib;
    $FILE->open($in_tsv, "r") or die("ERROR: cannot read file $in_tsv");

    while(<$FILE>) {
	chomp;
	next if ($_ !~ m/\S+/);
	@line = split(m/$ifs/, $_);

	die("ERROR: only one field found! Please check if the input field separator (\"-ifs\") is correctly specified.\n") if($#line == 0);

	# Pick key
	my @keys;
	if($#{$key_IDs} == -1) {
	    $key = $cnt;
	} else {
	    foreach my $id (@$key_IDs)
	    {
		if($id < 0 || $id > $#line) {
		    printf(STDERR "ERROR: selected ID (".($id+1).") outside of file columns (".($#line+1).") range!\n");
		    exit(-1);
		}
		push(@keys, $line[$id]);
	    }
	    $key = join("_", @keys);
	    $key = '###' if($header && $cnt == 0);
	}

	# Remove key_IDs and rem_IDs from @line
	foreach my $id (reverse sort {$a <=> $b} (@$key_IDs,@$rem_IDs) ) {
	    splice(@line,$id,1);
	}

	# Update max number of fields
	$nf = $#line if(!defined($nf) || $nf < $#line);
	
	# Check previous files to see if they all have the same lines 
	if( defined($$n_fields) && defined($NA) ) {
            unshift( @line, ($NA) x ($$n_fields - $#{$$output{$key}} - 1) );
        }

	# Add current line to hash
	push(@{$$output{$key}}, @line);

	$cnt++;
	last if($cnt == $n_lines);
    }
    $FILE->close;
    $$n_fields += $nf + 1;

    return 0;
}

##############################################################################
