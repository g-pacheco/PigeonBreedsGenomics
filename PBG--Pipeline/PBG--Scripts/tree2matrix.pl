#!/usr/local/bin/perl
#
# Cared for by Filipe G. Vieira <>
#
# Copyright Filipe G. Vieira
#
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

    tree2matrix.pl v1.0.1

=head1 SYNOPSIS

    perl tree2matrix.pl [OPTIONS]

    OPTIONS:
       --help
       --infile FILE   = input tree file in any supported BioPerl format
       --out_matrix    = output format in either (l)ist [default], (m)atrix, or (lm) lower matrix
    
=head1 DESCRIPTION

This script will parse a tree file and output the pairwise distance between all
leaf nodes.

=head1 AUTHOR - Filipe G. Vieira

Email

Describe contact details here

=cut

# Let the code begin...


use strict;
use Getopt::Long;
use Bio::TreeIO;

my ($tree_file, $out_matrix);
my ($treeI, $tree, $n_nodes, @nodes);

$out_matrix = 'l';

#Get the command-line options
&GetOptions('h|help'       => sub { exec('perldoc',$0); exit; },
            'i|infile=s'   => \$tree_file,
	    'out_matrix:s' => \$out_matrix,
            );


$treeI = Bio::TreeIO->new(-file => $tree_file, -format => "newick");
$tree = $treeI->next_tree;

@nodes = $tree->get_nodes;
$n_nodes = $#nodes;
print("Sp1\tSp2\tDistance\n") if($out_matrix eq 'l');

for(my $i=0; $i<=$#nodes; $i++)
{
    my $node1 = $nodes[$i];
    next unless($node1->is_Leaf);

    print($node1->id) if($out_matrix ne 'l');
    $n_nodes = $i if($out_matrix ne 'm');

    for(my $j=0; $j<=$n_nodes; $j++)
    {
        my $node2 = $nodes[$j];
        next unless($node2->is_Leaf);

        my $dist = $tree->distance(-nodes => [$node1,$node2]);

	if($out_matrix ne 'l'){
	    print("\t".$dist);
	}else{
	    print($node1->id."\t".$node2->id."\t".$dist."\n");
	}
    }
    print("\n") if($out_matrix ne 'l');
}

exit(0);
