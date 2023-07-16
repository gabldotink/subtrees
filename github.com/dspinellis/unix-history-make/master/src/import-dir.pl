#!/usr/bin/perl
#
# Import directory snapshots or directories containing SCCS VCS data.
#
# Import the specified directory as a series of time-ordered commits on the
# specified branch name with a -Snapshot-Development suffix.
# Importing SCCS VCS adds all commits found in the tree in a time-ordered
# fashion.
# When starting, specified parts are copied into a reference
# directory to allow log/blame to work across releases.
# When done:
# - the branch is merged with the -Release branch (not for SCCS imports),
# - the reference directories are deleted, and
# - the release is tagged with the specified version name. (-END for SCCS)
#

use strict;
use warnings;

use Date::Parse;
use File::Copy;
use File::Find;
use Getopt::Std;
use Git::FastExport;
use Git::Repository;
use Time::Local;
use VCS::SCCS;

# A map from contributor ids to full names
my %full_name;

# A map from contributor ids to emails
my %email;

# A map containing paths of files to ignore
my %ignore_map;

# A map containing paths of files to add when merging
my %merge_add_map;

# Subsitute $ with an id to get a contributor's email address
my $address_template;

# Email address substitutions
my %address_substitute;

# Map from file paths to committers, ordered in terms of precedence
my @committer_map;

# Committer responsible for releases. Set for path .*
my $release_master;

$main::VERSION = '0.1';

# Exit after command processing error
$Getopt::Std::STANDARD_HELP_VERSION = 1;

# Time difference (in seconds) to squash together commits from snapshots
my $squash_snapshot_dt = 10;

# Time difference (in seconds) to squash together commits from SCCS
my $squash_sccs_dt = 60 * 60;

sub
main::HELP_MESSAGE
{
	my ($fh) = @_;
	print $fh qq{
Usage: $0 [options ...] directory branch_name [ version_name tz_offset ]
-b T	Before import keep the specified files
-C date	Ignore commits after the specified cutoff date
-c file	Map of the tree's parts written by specific contributors
-G str	Import directory through git. Argument is author and timestamp
	to use for the reference files commit.
-i file	Comma-separated list of files containing pathnames of files to ignore
-I file	Comma-separated list of files containing SCCS pathnames to merge
	during incremental import, and add when merging
-l	When importing symbolic links use linked file's date
-m T	The commit(s) from which the import will be merged
-n file	Map between contributor login names and full names
-P path	Path to prepend to file paths (branches for git) being committed
-p re	Regular expression of files to process
-R date	Remove reference files after the specified date (for git import)
-r T	During import keep by side a reference copy of the specified files
-S	Import directory through SCCS
-s path	Leading path to strip from file paths being committed
	By default this is the supplied directory
-u file	File to write unmatched paths (paths matched with a wildcard)
-v	Enable verbose output

T is a tree-ish series of comma-seperated specifications, normally tag names.
Each reference directory has .ref- prepended to its name.

version_name and tz_offset are not required for SCCS imports
};
}

our($opt_b, $opt_C, $opt_c, $opt_G, $opt_i, $opt_I, $opt_l, $opt_m, $opt_n, $opt_P, $opt_p, $opt_R, $opt_r, $opt_S, $opt_s, $opt_u, $opt_v);
$opt_b = $opt_m = $opt_r = '';

if (!getopts('b:C:c:G:i:I:lm:n:P:p:R:r:Ss:t:u:v')) {
	main::HELP_MESSAGE(*STDERR);
	exit 1;

}

# Expected arguments
my $ea;
if (($opt_S && $#ARGV + 1 != ($ea = 2)) ||
    (!$opt_S && !$opt_G && $#ARGV + 1 != ($ea = 4)) ||
    ($opt_G && $#ARGV + 1 < ($ea = 2))) {
	print STDERR "Expected $ea required arguments\n";
	main::HELP_MESSAGE(*STDERR);
	exit 1;
}

my $unmatched;
if ($opt_u) {
	open($unmatched, '|-', "LC_COLLATE=C sort -u >$opt_u") || die "Unable to open $opt_u: $!\n";
}

my $cutoff_time;
if ($opt_C) {
	$cutoff_time = str2time($opt_C);
}

my $reference_stop_time;
if ($opt_R) {
	$reference_stop_time = str2time($opt_R);
}

my $directory = shift;
my $source_dir = $directory;
$source_dir =~ s/\.\.\/archive\///;
my $branch = shift;
my $version = '';
$version = shift unless ($opt_S || $opt_G);
my $tz_offset = shift unless ($opt_S || $opt_G);

# Prepare for issuing fast-export blocks
binmode STDOUT;
my $mark = $opt_G ? 1000000 : 1;

my $dev_branch = ($opt_S || $opt_G) ? "$branch-Import" : "$branch-$version-Snapshot-Development";
$dev_branch = $opt_P . $dev_branch if ($opt_P);

print STDERR "\n\n\nImport $dev_branch from $directory\n" if ($opt_v);

create_name_map() if (defined($opt_n));

# Fast exit for git import
if ($opt_G) {
	git_import();
	exit 0;
}

$opt_s = $directory unless defined($opt_s);
$opt_s .= '/' unless ($opt_s =~ m|/$|);
$opt_s =~ s/([^\w])/\\$1/g;
$opt_s = '^' . $opt_s;

create_map($opt_i, \%ignore_map);
create_map($opt_I, \%merge_add_map);
create_committer_map();

# Create branch
system "git branch $dev_branch" || die "git branch: $!\n";

# Collect text files
if (! -d $directory) {
	print STDERR "$directory is not a directory\n";
	exit 1;
}

my @sccs;

# File information for text files
# ->{mtime} The date each file was last modified
my %fi;

sub
gather_text_files
{
	# Skip over unreadable directories; e.g. CSRG/cd2/net.2/var/spool/ftp/hidden
	if (-d && !-r) {
		$File::Find::prune = 1;
		return;
	}
	return if ($opt_p && !m|/$opt_p$|);
	if ($opt_i || $opt_I) {
		my $commit_path = $_;
		$commit_path =~ s/$opt_s// if ($opt_s);
		if ($ignore_map{$commit_path}) {
			# Ignore all finds below if a directory was specified
			$File::Find::prune = 1 if (-d);
			return;
		}
		$fi{$_}->{commit_at_release} = 1 if ($merge_add_map{$commit_path});
	}
	return unless ((-f && -T) || -l);
	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks) = lstat;
	$fi{$_}->{mtime} = $mtime;
	if (-l) {
		my $target = readlink;
		$fi{$_}->{size} = length($target);
		$fi{$_}->{mode} = '120000';
		if ($opt_l) {
			# Use date of linked file if possible
			my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, @rest);
			print STDERR "Link $_\n" if ($opt_v);
			# Resolve absolute symbolic link paths
			if ($target =~ m|^/|) {
				($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, @rest) = stat($directory . $target);
			} else {
				($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, @rest) = stat;
			}
			if (defined($ino)) {
				$fi{$_}->{mtime} = $mtime;
				print STDERR "Setting mtime to $mtime\n" if ($opt_v);
			} else {
				# Ignore
				delete $fi{$_};
				print STDERR "Ignoring unresolved symlink entry\n" if ($opt_v);
				return;
			}
		}
	} else {
		$fi{$_}->{size} = $size;
		$fi{$_}->{mode} = (-x $_) ? '100755' : '100644';
	}
}

sub
gather_sccs_files
{
	$File::Find::dir =~ m{(?:^|/)SCCS$} and m/^s\./ or return;
	push @sccs, $File::Find::name;
}

# Now start committing them from oldest to newest

# Modification time for first and last commit
my $first_mtime;
my $last_mtime;
# Last commit mark
my $last_devel_mark;

sub
create_text_blobs
{
	# First create the blobs
	for my $name (sort {$fi{$a}->{mtime} <=> $fi{$b}{mtime}} keys %fi) {
		print "# $fi{$name}->{mtime} $name\n";
		$first_mtime = $fi{$name}->{mtime} unless defined($first_mtime);
		$fi{$name}->{id} = $mark;
		print "blob\n";
		print "mark :$mark\n";
		print "data $fi{$name}->{size}\n";
		if ($fi{$name}->{mode} eq '120000') {
			# Symbolic link
			my $target = readlink $name;
			print $target;
		} else {
			# Regular file: flush stdout, and copy contents
			$| = 1;
			$| = 0;
			copy($name, \*STDOUT);
		}
		$mark++;
	}
}

# http://www.kernel.org/pub/software/scm/git/docs/gitattributes.html
# could be explored to write checkout hooks that translate SCCS
# keywords to actual content. Would be hard to translate back
sub
pr_date
{
	my @dt = localtime shift;
	sprintf "%s %02d-%02d-%4d %02d:%02d:%02d",
	(qw( Sun Mon Tue Wed Thu Fri Sat ))[$dt[6]],
	$dt[3], $dt[4] + 1, $dt[5] + 1900,
	$dt[2], $dt[1], $dt[0];
}

# Return the directory name of a path
sub
dirname
{
	my ($n) = @_;

	$n =~ s|/[^/]*$||;
	return $n;
}

# use a best guess at user, hostname, etc.
my $domain = "ucbvax.Berkeley.EDU";
my %tzoffset;
my $tzoffset = sub {
	my $offset_s = timegm (localtime ($_[0])) - $_[0];
	$offset_s = 0 - 800;
	$tzoffset{$offset_s} ||= ( $offset_s >= 0 ? "+" : "-" )
	. sprintf "%.4d", abs $offset_s;
	};

# Submit in the same sequence as the original
my %sccs;
my %file;
my @fail;

sub
create_sccs_blobs
{
	my $now = time();

	foreach my $f (sort @sccs) {
		my $sccs;
		eval { $sccs = VCS::SCCS->new ($f) };
		unless ($sccs) {
			warn "Cannot convert $f\n";
			push @fail, $f;
			next;
		}
		# GIT supports get-hooks, to translate on retrieval
		# But it will be useless as you cannot translate back
		$sccs->set_translate ("SCCS");
		my $fn = $sccs->file ();
		$file{$fn}++;
		foreach my $rm (@{$sccs->revision_map ()}) {
			my ($rev, $vsn) = @{$rm};
			my $delta = $sccs->delta ($rev);
			# Adjust dates lying in the future
			if ($delta->{stamp} > $now && defined($last_mtime)) {
				print STDERR "\n" if ($opt_v);
				printf STDERR "Adjust future date $delta->{stamp} to $last_mtime\n";
				$delta->{stamp} = $last_mtime
			}
			$sccs{pack "NA*", $delta->{stamp}, $fn} = [ $sccs, $rev, $mark ];
			my $data = scalar $sccs->body ($rev);
			print "blob\nmark :", $mark,
					   "\ndata ", length ($data),
					   "\n", $data, "\n";
			printf STDERR "%-20s %3d %8s  %s\r", $fn, $rev, $vsn, pr_date($delta->{stamp}) if ($opt_v);
			$first_mtime = $delta->{stamp} unless defined($first_mtime);
			$last_mtime = $delta->{stamp};
			$tz_offset = $tzoffset->($last_mtime) unless defined($tz_offset);
			$mark++;
		}
		print STDERR "\n" if ($opt_v);
	}
}

sub
issue_pending_sccs_commit
{
	my ($author, $stamp, $all_mr, $all_vsn, $comment, $mod) = @_;

	return if (!defined($stamp));

	print "commit refs/heads/$dev_branch\n";
	print "mark :$mark\n";
	$last_devel_mark = $mark++;
	print "committer ", full_name($author), " <",
		($author, "@", $domain, "> ", $stamp + 64800,
		 " ", $tz_offset = $tzoffset->($stamp), "\n");

	$all_mr and $comment  .= "\n";
	my $msg  = "$comment\n$all_mr$all_vsn";
	print "data ", length ($msg), "\n$msg\n";
	print $mod;
	print "\n";
}

# Issue SCCS commits squashing together those with same
# author, comment, and almost same timestamp.
# For empty comments squash only those that affect files in the
# same directoy.
sub
issue_sccs_commits
{
	my ($previous_stamp, $previous_author, $previous_comment, $previous_fn);
	my ($all_mr, $all_vsn, $mod);

	foreach my $c (sort keys %sccs) {
		my ($sccs, $rev, $commit_mark) = @{$sccs{$c}};

		my $fn	= $sccs->file();
		my %delta = %{$sccs->delta ($rev)};
		my $stamp = $delta{stamp};
		last if (defined($cutoff_time) && $stamp > $cutoff_time);
		$fn =~ s/$opt_s// if ($opt_s);
		my $author = $delta{committer};

		# tradition is to save all potentially useful but
		# uncategorized metadata as RFC822-style headers in the commit
		# message
		my $mr  = $delta{mr} || ""; $mr =~ s/^-$//;
		$mr  and $mr  = "SCCS-mr: $fn $mr\n";
		my $vsn   = $delta{version};
		$vsn and $vsn = "SCCS-vsn: $fn $vsn\n";
		my $comment = $delta{comment} || "";
		$comment ||= "(no message)";
		$comment  .= "\n";

		printf STDERR "%-20s %3d %6s  %s %s %s\n", $fn, $rev, $vsn,
		    pr_date($stamp), $delta{date}, $delta{"time"}
			if ($opt_v);
		if (!defined($previous_stamp) ||
		    $stamp - $previous_stamp > $squash_sccs_dt ||
		    $author ne $previous_author ||
		    $comment ne $previous_comment ||
		    ($comment eq "(no message)\n" && (
			    dirname($previous_fn) ne dirname($fn)))) {
			issue_pending_sccs_commit($previous_author,
				$previous_stamp, $all_mr, $all_vsn,
				$previous_comment,
				$mod);
			$previous_author = $author;
			$previous_comment = $comment;
			$previous_fn = $fn;
			$all_mr = '';
			$all_vsn = '';
			$mod = '';
		}
		$previous_stamp = $stamp;
		$mr and $all_mr .= $mr;
		$vsn and $all_vsn .= $vsn;

		my $mode = $delta{flags}{x} ? "755" : "644";
		$fn =~ s/$opt_s// if ($opt_s);
		$fn = $opt_P . $fn if ($opt_P);
		$mod .= "M $mode :$commit_mark $fn\n";
	}
	issue_pending_sccs_commit($previous_author, $previous_stamp,
		$all_mr, $all_vsn, $previous_comment, $mod);
}

if ($opt_S) {
	$version = '';
	find(\&gather_sccs_files, $directory);
	@sccs or die "No SCCS source files to convert\n";
	create_sccs_blobs();
} else {
	find({wanted => \&gather_text_files, no_chdir => 1 }, $directory);
	create_text_blobs();
}

if (!defined($first_mtime)) {
	print STDERR "No files for import found in $directory\n";
	exit 1;
}

issue_start_commit();

# Add the specified Git files to the repo prefixing their path as specified
sub
add_git_files
{
	my ($ref, $prefix) = @_;

	my $cmd;
	open(my $ls, '-|', $cmd = "git ls-tree -r $ref") || die "Unable to open run $cmd: $!\n";
	while (<$ls>) {
		chop;
		my ($mode, $blob, $sha, $path) = split;
		print "M $mode $sha $prefix$path\n";
	}
}

# Issue the commit that starts development
# Return the commit's mark
sub
issue_start_commit
{
	# Add license blobs
	my $text_license_blob = add_file_blob('../old-code-license');
	my $caldera_license_blob = add_file_blob('../Caldera-license.pdf');
	my $alu_usa_license_blob = add_file_blob('../ALU-USA-statement.pdf');
	my $readme_blob = add_file_blob('../README-SHA.md');

	# The actual development commits
	if ($opt_b) {
		print "# Continue further development commits\n";
	} else {
		print "# Start development commits from a clean slate\n";
	}
	print "commit refs/heads/$dev_branch\n";
	print "mark :$mark\n";
	if ($opt_G) {
		print "author $opt_G\n";
		print "committer $opt_G\n";
	} else {
		print "author $release_master $first_mtime $tz_offset\n";
		print "committer $release_master $first_mtime $tz_offset\n";
	}
	print data("Start development on $branch $version\n" .
		($opt_r ? "Create reference copy of all prior development files\n" : '') .
		($opt_b ? "Keep prior development files\n" : '') .
		"\n\nSynthesized-from: $source_dir");
	# Specify merges
	for my $merge (split(/,/, $opt_m)) {
		print "merge $merge\n";
	}

	# Add reference copies of older files
	for my $ref (split(/,/, $opt_r)) {
		add_git_files($ref, ".ref-$ref/");
	}

	# Add copies of existing files
	for my $ref (split(/,/, $opt_b)) {
		add_git_files($ref, '');
	}

	# Add README and licenses
	print "M 644 :$readme_blob README.md\n";
	print "M 644 :$text_license_blob LICENSE\n";
	print "M 644 :$caldera_license_blob Caldera-license.pdf\n";
	print "M 644 :$alu_usa_license_blob ALU-USA-statement.pdf\n";
	return $mark++;
}

sub
issue_pending_text_commit
{
	my ($author, $mtime, $work, $coauthorship, $mod) = @_;

	return if (!defined($mtime));

	print "commit refs/heads/$dev_branch\n";
	print "mark :$mark\n";
	$last_devel_mark = $mark++;
	print "author $author $mtime $tz_offset\n";
	print "committer $author $mtime $tz_offset\n";
	print data("$branch $version development\n$work$coauthorship\nSynthesized-from: $source_dir");
	print $mod;
}

# Issue text commits squashing thogether those with same author
# and co-author and almost same modification time.
sub
issue_text_commits
{
	my ($previous_mtime, $previous_author, $previous_coauthorship);
	my ($work, $mod);

	print "# Development commits\n";
	for my $name (sort {$fi{$a}->{mtime} <=> $fi{$b}{mtime}} keys %fi) {
		next if (defined($cutoff_time) && $fi{$name}->{mtime} > $cutoff_time);
		printf STDERR "%-20s %s\r", $name, pr_date($fi{$name}->{mtime}) if ($opt_v);
		my $mtime = $fi{$name}->{mtime};
		$last_mtime = $mtime;
		next if ($fi{$name}->{commit_at_release});

		print "# $mtime $name\n";
		my $commit_path = $name;
		$commit_path =~ s/$opt_s// if ($opt_s);
		$commit_path = $opt_P . $commit_path if ($opt_P);
		my ($author, $coauthors) = author($commit_path);
		my $coauthorship = '';
		if (defined($coauthors)) {
			for my $ca (@$coauthors) {
				print STDERR "Added co-author $ca\n" if ($opt_v);
				$coauthorship .= "\nCo-Authored-By: $ca";
			}
		}
		if (!defined($previous_mtime) ||
		    $mtime - $previous_mtime > $squash_snapshot_dt ||
		    $author ne $previous_author ||
		    $coauthorship ne $previous_coauthorship) {
			issue_pending_text_commit($previous_author,
				$previous_mtime, $work,
				$previous_coauthorship,
				$mod);
			$previous_author = $author;
			$previous_coauthorship = $coauthorship;
			$work = '';
			$mod = '';
		}
		$previous_mtime = $mtime;
		$work .= "Work on file $commit_path\n";
		$mod .= "M $fi{$name}->{mode} :$fi{$name}->{id} $commit_path\n";
	}
	issue_pending_text_commit($previous_author, $previous_mtime,
		$work, $previous_coauthorship, $mod);
}

if ($opt_S) {
	issue_sccs_commits();
	$version = 'END';
} else {
	issue_text_commits();
}

# Now issue a release
print "# Release\n";
print "commit refs/heads/$branch" . ($opt_S ? '' : '-Release') . "\n";
print "mark :$mark\n";
my $release_mark = $mark++;
print "author $release_master $last_mtime $tz_offset\n";
print "committer $release_master $last_mtime $tz_offset\n";
print data("$branch $version release\nSnapshot of the completed development branch\n\nSynthesized-from: $source_dir");
print "from :$last_devel_mark\n" if defined($last_devel_mark);
for my $merge (split(/,/, $opt_m)) {
	print "merge $merge\n";
}
# Add delayed commit files
print "# Commits of merged files\n";
for my $name (sort {$fi{$a}->{mtime} <=> $fi{$b}{mtime}} keys %fi) {
	next if (defined($cutoff_time) && $fi{$name}->{mtime} > $cutoff_time);
	next unless ($fi{$name}->{commit_at_release});
	print "# $fi{$name}->{mtime} $name\n";
	my $commit_path = $name;
	$commit_path =~ s/$opt_s// if ($opt_s);
	$commit_path = $opt_P . $commit_path if ($opt_P);
	print "M $fi{$name}->{mode} :$fi{$name}->{id} $commit_path\n";
}
# Remove reference copies of older files
for my $ref (split(/,/, $opt_r)) {
	print "D .ref-$ref\n";
}

# Tag the release
print "tag $branch-$version\n";
print "from :$release_mark\n";
print "tagger $release_master $last_mtime $tz_offset\n";
print data("Tagged $version release snapshot of $branch with $version\n\nSynthesized-from: $source_dir");


# Signify that we're finished
print "done\n";
print STDERR "Done importing $dev_branch\n";

# Return the argument as a fast-import data element
sub
data
{
	my ($d) = @_;
	$d .= "\n" unless ($d =~ m/\n$/);
	return "data " . length($d) . "\n" . $d;
}

# Create a map from file paths to committers
sub
create_committer_map
{
	if (defined($opt_c)) {
		open(my $in, '<', $opt_c) || die "Unable to open $opt_c: $!\n";
		while (<$in>) {
			chop;
			s/#.*//;
			s/^\s*//;
			next if (/^$/);
			my ($pattern, $author) = split(/\t+/, $_);
			if (!$author) {
				print STDERR "$opt_c($.): Unspecied author\n";
				exit 1;
			}
			my ($full_author, $coauthors) = add_name_email($author);
			push(@committer_map, {
				pattern => $pattern,
				author => $full_author,
				coauthors => $coauthors
			});
			$release_master = $full_author if ($pattern eq '.*');
		}
		close($in);
	}
	if (!defined($release_master)) {
		print STDERR "No default author specified\n";
		exit 1;
	}
}


# Create a map to entries in the specified comma-separated list of files
sub
create_map
{
	my ($fname_list, $map_ref) = @_;

	return unless defined($fname_list);

	for my $fname (split(/\,/, $fname_list)) {
		open(my $in, '<', $fname) || die "Unable to open $fname: $!\n";
		while (<$in>) {
			chop;
			s/#.*//;
			s/^\s*//;
			next if (/^$/);
			$map_ref->{$_} = 1;
		}
		close($in);
	}
}

# Create a map from contributor ids to full names and
# populate address_template and address_substitute
sub
create_name_map
{

	open(my $in, '<', $opt_n) || die "Unable to open $opt_n: $!\n";
	while (<$in>) {
		chop;
		s/#.*//;
		s/^\s*//;
		next if (/^$/);

		if (/^%A (.*)/) { # Address email format e.g. %A research!$1
			$address_template = $1;
			next;
		} elsif (/^%S ([^ ]*) +(.*)/) { # Substitutions %S @foo @foo.org
			$address_substitute{$1} = $2;
			next;
		}
		my ($id, $name, $email) = split(/:/, $_);
		if (defined($full_name{$id})) {
			print STDERR "Name for $id already defined as $full_name{$id}\n";
			exit 1;
		}
		$full_name{$id} = $name;
		if (defined($email)) {
			$email{$id} = $email;
		} else {
			$email{$id} = email_address($id);
		}
	}
	close($in);
}

# Return the domain associated with the specified email address
# Can handle UUCP and RFC-822 addresses
sub
get_domain
{
	my ($email) = @_;

	if ($email =~ m/^[^@]+\@(.*)$/) {
		return $1;
	} elsif ($email =~ m/^([^!]+)\!.*$/) {
		return $1;
	} else {
		print STDERR "Unable to get domain for address $email\n";
		exit 1;
	}
}

# Given an author id (or full details) add full name and email if needed
# Examples:
# Jon Doe <joe@example.com> stays as is
# jd becomes Jon Doe <joe@example.com>
# More than one id can be specified.
# In this case the co-author(s) are returned as an array
sub
add_name_email
{
	my ($id) = @_;

	# Return if id already contains an email field
	return $id if ($id =~ m/</);

	my ($author, @coauthors);
	my @ids = split(/,/, $id);
	for (my $i = 0; $i <= $#ids; $i++) {
		my $id = $ids[$i];
		check_name($id);
		my $contributor = "$full_name{$id} <$email{$id}>";
		if ($i == 0) {
			$author = $contributor;
		} else {
			push(@coauthors, $contributor);
		}
	}
	return ($author, \@coauthors);
}

# Given an author id, return the email address based on the
# address template
sub
email_address
{
	my ($id) = @_;
	my $address = $address_template;
	if (!defined($address_template)) {
		print STDERR "Address template not defined for $id\n";
		exit 1;
	}
	$address =~ s/\$/$id/g;
	for my $from (keys %address_substitute) {
		$address =~ s/$from/$address_substitute{$from}/;
	}
	return $address;
}

# Exit with an error if a full name is not defined for a given contributor id
sub
check_name
{
	my ($id) = @_;
	return if (defined($full_name{$id}));
	print STDERR "No full name defined for contributor id $id\n";
	exit 1;
}

# Return an author's full name, if available
# If not return the id, and save the unmatched id
sub
full_name
{
	my ($id) = @_;
	my $full = $full_name{$id};
	if (defined($full)) {
		return $full;
	} else {
		print $unmatched "$id\n" if (defined($unmatched));
		return $id;
	}
}

# Return the author (and possible co-authors) for the specified file path
sub
author
{
	my ($path) = @_;

	for my $re (@committer_map) {
		if ($path =~ m/^$re->{pattern}/) {
			if (defined($unmatched) && $re->{pattern} eq '.*') {
				print $unmatched "$path\n";
			}
			return ($re->{author}, $re->{coauthors});
		}
	}
	print STDERR "Unable to map comitter for $path\n";
	exit 1;
}

# Add the specified file to the repo as a blob returning its mark
sub
add_file_blob
{
	my ($name) = @_;
	if (!-r $name) {
		print STDERR "$name: $!\n";
		exit 1;
	}
	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat $name;
	print "# Manual addition of $name\n";
	print "blob\n";
	print "mark :$mark\n";
	print "data $size\n";
	# Flush stdout
	$| = 1;
	$| = 0;
	copy($name, \*STDOUT);
	return $mark++;
}

# Import files through git
# This routine modifies the git fast-export stream as follows.
# 1. It starts the sequence with the specified merge (-m)
# 2. It injects the specified reference files (-r) at the beginning of
#    all initial commits (those with no parents) up to the time point
#    specified with the -R option.
# 3. It removes the injected specified reference files from all the
#    graph edges they appear on after the specified time point.
# 4. It prepends to all branch names the string specified with -P.
# 5. It performs email substitutions based on %address_substitute
sub
git_import
{

	# get the object from a Git::Repository
	my $repo = Git::Repository->new(work_tree => $directory);
	my $fh = $repo->command(('fast-export', '--date-order', '--reverse', $branch, @ARGV))->stdout;
	# Create parser on the output stream
	my $export = Git::FastExport->new($fh);

	my $added_ref = 0;
	my $removed_ref = 0;

	# Start with a merge and a copy of the specified reference files
	my $ref_mark = issue_start_commit();

	# Commits that have reference files in their ancestors
	my @has_ref;

	while (my $block = $export->next_block()) {
		# print STDERR $block->{header}, ":", join(' ', keys(%$block)), "\n";
		# Prepend the specified string to branch names
		$block->{header} =~ s:((commit|reset) refs/heads/)(.+)$:${1}$opt_P$3:o if ($opt_P);

		if ($block->{header} !~ m/^commit/) {
			print $block->as_string();
			next;
		}

		# Subtitute full names and arbitrary addresses
		for my $ac (qw(author committer)) {
			$block->{$ac}->[0] =~ s/^$ac\s+(\S+)\s+/$ac $full_name{$1} /
				if ($block->{$ac}->[0] =~ m/^$ac\s+(\S+)\s+/ &&
				    $full_name{$1});
			for my $from (keys %address_substitute) {
				$block->{$ac}->[0] =~ s/^$from/$address_substitute{$from}/;
			}
		}

		# Process commits
		my ($mark) = ($block->{mark}->[0] =~ m/^mark\s+\:(\d+)/);
		my ($time) = ($block->{committer}->[0] =~ m/^[^<]*\<[^>]*\>\s*(\d+)\s+/);
		if (!defined($time)) {
			print STDERR "Undefined time in: ", @{$block->{committer}}[0], "\n";
		}
		# Pass the has_ref attribute down the commit chain
		my $from;
		if ($block->{from} && $mark) {
			($from) = ($block->{from}->[0] =~ m/^from\s+\:(\d+)/);
			$has_ref[$mark] = $has_ref[$from];
		}
		# Add reference files, if a time was specified with -R
		if ($opt_r && $time < $reference_stop_time && !$block->{from}) {
			my @from = ("from :$ref_mark");
			$block->{from} = \@from;
			$has_ref[$mark] = 1;
			$added_ref++;
		}
		# Remove reference files, if a time was specified with -R
		if ($opt_r && $time >= $reference_stop_time && $has_ref[$mark]) {
			my @files;
			@files = @{$block->{files}} if (defined($block->{files}));
			for my $ref (split(/,/, $opt_r)) {
				push(@files, "D .ref-$ref");
			}
			$block->{files} = \@files;
			$has_ref[$mark] = 0;
			$removed_ref++;
		}
		# Indicate parent of initial commit
		if ($opt_b && defined($ref_mark) && !$block->{from}) {
			my @from = ("from :$ref_mark");
			$block->{from} = \@from;
			undef($ref_mark);
		}
		print $block->as_string();
	}
	print "done\n";
	print STDERR "Added reference files to $added_ref commit(s)\n";
	print STDERR "Removed reference files from $removed_ref commit(s)\n";
	print STDERR "Done importing ", join(' ', $branch, @ARGV), "\n";
}
