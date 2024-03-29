#!/usr/bin/perl
#
# Copyright 2010 Gabriele Sales <gbrsales@gmail.com>
# Copyright 2010 Ivan Molineris <ivan.molineris@gmail.com>

use warnings;
use strict;
use File::Basename;
use lib dirname (__FILE__);
use MakefileParser;
use Getopt::Long;
use File::Basename;
#$,="\t";
#$\="\n";


$SIG{__WARN__} = sub {die @_};

my $usage = "$0 [--debug] [-f makefile] [-e|extended] [-v|assing var=val] [-M|meta] '{awk program}' data_filename\n

-e	change the regexp used to identify named fields: a named field like \$\$NF (with a double \$)
	is passed to awk as \$NF ad doesn't trigger the logic of named fields.
	Be careful with the -e option: do not confuse \$NF with NF. It is useful only if you want 
	to use a variable to indicate a field number or if you wont to pass shell variables to awk.

-M	print the .META for the given file and exit

-v|assign var=val
	Assign the val to the variable var inside the bawk program
";

my $debug=0;
my $extended =  0;
my $help=0;
my $print_META_only = 0;
my $print_META_only_header = 0;
my @assign = ();
GetOptions (
	'debug' => \$debug,
	'e' => \$extended,
	'v|assign=s' => \@assign,
	'h|help' => \$help,
	'M|meta' => \$print_META_only,
	'header' => \$print_META_only_header,
) or die($usage);

if($help){
	print $usage;
	exit(0);
}

$print_META_only=1 if $print_META_only_header;

my $meta_re = '\$([\w\.]*(?:[a-z]|[A-Z])[\w\.]*)\W'; 	#the regexp match a $ followed by a word (including one dots) with at least 1 non \d char
my $meta_in_header_or_makefile=".META in makefiles";

if($extended){
	$meta_re = "[^\$]$meta_re"; 	#the regexp match a single $
	#a double $$ can be used to skip the parsing of the variable, as for $NF to print the last field of a row.
}

my $awk_prog = undef;

if(!$print_META_only){
	$awk_prog = shift;
	die($usage) if !$awk_prog;
	$awk_prog = "$awk_prog ";
}

my $data_filename = shift;

die("Wrong argument number (".join("\t",@ARGV).")") if scalar(@ARGV) != 0;

my $needs_meta = 0;

$needs_meta = 1 if $print_META_only or $awk_prog =~ /$meta_re/; #the regexp match a $ followed by a word with at least 1 non \d char

die("meta data required but there is no filename as second argument") if $needs_meta and !$data_filename;

if($needs_meta){
	#die("File ($data_filename) do not exists") if !-e $data_filename;
	
	my $data_path = $ENV{'PWD'};
	my $data_filename_only = undef;
	$data_filename = './'.$data_filename if $data_filename !~ /\//;
	$data_filename =~ /^(.*)\/([^\/]+)$/;
	if(defined($1) and $1 ne "" and $1 ne "." ){
		$data_path = $1;
	}
	$data_filename_only = $2;
	my $meta = get_metadata_without_bmake_query($data_path, $data_filename_only);

	if($print_META_only){
		my @rows = map{s/^\t//;$_} split(/\n/,$meta);
		#my @cols = map{ my @F=split($_); $_=$F[1]} @rows;
		if($print_META_only_header==0){
			print join("\n",@rows)."\n"
		}else{
			print join("\t",
				map{
					my @F=split(/\s+/,$_); 
					$_=$F[1]
				} @rows
			)."\n"
		}
		exit(0);
	}
	
	my %fields = ();
	while($awk_prog =~ /$meta_re/g){
		$fields{$1}=0;
	}
	
	for(keys %fields){
		$meta =~ /^\t(\d+)\s+$_(?:\s|$)/m or die("metadata not found for field ($_) in file ($data_filename) using $meta_in_header_or_makefile.");
		$fields{$_}=$1;
	}
	
	for(keys %fields){
		my $col = $fields{$_};
		$awk_prog =~ s/\$$_(\W)/\$$col$1/g;
	}
}

###############################

if($extended){
	# convert al $$ to single $, $$ are used to skip te standard bawk parsing, as in $$NF
	$awk_prog =~ s/\$\$/\$/g;
}

###############################
#
#	read compressed files
#

$data_filename = "" if not defined $data_filename;
$data_filename = "<(gunzip -c $data_filename)" if $data_filename =~ /.gz$/;
$data_filename = "<(xzcat $data_filename)" if $data_filename =~ /.xz$/;

###############################
#
#	-v options
#

my $assigend_vars = '';
for(@assign){
	$assigend_vars .= " -v $_"
}

###############################
#
#	extensions
#

while($awk_prog =~ /\$(\d+~\d+)[^\w]/){
	my $from = $1;
	my @to = ();
	$from =~/(\d+)~(\d+)/;
	my $range_b = $1;
	my $range_e = $2;
	for(my $i=$range_b; $i<=$range_e; $i++){
		push(@to,$i);
	}
	my $to_string = join(', $',@to);
	$awk_prog =~ s/$from/$to_string/;
}

###############################


my $cmd ="export LC_ALL=POSIX; gawk $assigend_vars -F'\\t' -v OFS='\\t' --re-interval '$awk_prog' $data_filename";
if($debug){
	print "$cmd\n";
	exit(0);
}else{
	exec '/bin/bash', '-c',$cmd;
}


###############################
#
#	subrutines
#

sub get_metadata{
        my $path = shift;
	my $filename = shift;
	return `cd "$path"; bmake_query "__bmake_meta_$filename"`;
}

sub find_metadata{
	my $makefile=shift;
	my $data_filename_only=shift;
	###############################
	#   search for metadata
	###############################
	
	#print "found" if $makefile =~ /^.META:\s+$data_filename_only(.*?)\n^$/sm;
	#print $1;
	#whit the following multiline regex we wont to keep all the META block
	my $meta = undef;
	if($makefile =~ /^.META:[^\n]*\s$data_filename_only(?:[ \t][^\n]*)?\n(.*?)\n^$/sm){ #? is for lazy match
		$meta = $1;
	}else{# if a .META for te $data_filename_only is not found search for .META with * glob
		my @all_META = ($makefile =~ /^.META:\s+([^\n]+)\n(.*?)\n^$/gsm); # get all .META, header and body in subcessive elements
		OUTER: for(my $i=0; $i<scalar(@all_META); $i++){
			my $patterns = $all_META[$i];
			if($patterns !~ m/^\s/){ # if the pattern start whit a space is the body of a .META, whe search for header
				my @pattern = split(/\s+/,$patterns);# for rows like .META *file1 *file2
				for(@pattern){
					$_ =~ s/\./\\./g; # the pattern will be interpreted as a regexp, so the "." must be slashed
					$_ =~ s/\*/.*/g; # * -> .*
					if($data_filename_only =~ /^$_$/){
						$meta = $all_META[$i + 1]; # the element subsequent the matched header is the required body
						last OUTER;
					}
				}
			}
		}
		if(not defined($meta)){
			if($debug){
				print $makefile;
			}
			#die("metadata not found for file ($data_filename_only) in makefile");# ($makefile)");
		}
	}
	return $meta;
}

sub get_makefile_content{
	my $makefile_name = shift;
	my $optional=shift;
	#configure and use the MakefileParser module to read the makefile
	my $fh;
	my @errors=();
	my $basename=basename($makefile_name);
	my $dirname=dirname($makefile_name)."/";
	while(not -r $makefile_name and $dirname and $dirname ne "/" and $dirname ne "."){
		push(@errors,$makefile_name);
		$dirname=dirname(dirname($makefile_name));
		$makefile_name="$dirname/$basename";
	}
	return "" if not -r $makefile_name and $optional;

	open $fh, $makefile_name or die("Can't open makefiles, tryed: " . join(" ",@errors));
	set_makefile_name($makefile_name);
	my $makefile = readmakefile($fh);
	close $fh;
	return $makefile;
}

sub get_metadata_without_bmake_query{
        my $path = shift;
	my $filename = shift;
	my $makefile_content="";
	foreach my $filetype ("makefile","rules.mk","prj_rules.mk","Snakefile"){
		$makefile_content .= get_makefile_content("$path/$filetype",1);
	}
	my $meta = find_metadata($makefile_content,$filename);
	return $meta if defined($meta);

	$meta_in_header_or_makefile="first line of the file as header or .META block searched in makefiles.";
	$meta="";
	if($filename=~m/.gz$/){
		open(FH,"-|","zcat $path/$filename") or die("Can't uncompress $path");
	}else{
		open(FH,"<$path/$filename") or die("Can't open $path");
	}
	my $header = <FH>;
	if($header){#FH can be empty
		my @F=split(/\t/,$header);
		my $i=1;
		for(@F){
			$meta.="\t$i\t$_\n";
			$i++;
		}
	}
	return $meta;
}
