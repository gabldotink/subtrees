#!/bin/bash
#
# Import Unix branches into a single repo
#
# Copyright 2013-2016 Diomidis Spinellis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# The directory where the repository will be created
REPO=import

# Commit label used for verification of parents
FIRST_COMMIT='Empty repository at start of Unix Epoch'

# Location of archive mirror
ARCHIVE=../archive

# Used to terminate when git fast-import fails
# This ensures the exit from nested subshells
set -E
trap '[ "$?" -eq 77 ] && exit 77' ERR

# Ensure consistent sorting
export LC_ALL=C

# Print usage information and exit
usage()
{
  cat <<EOF 1>&2
Usage: $0 [--debug] [--no-import] [--no-verify] [--verbose]

-d|--debug	Import only a small subset, and generate debugging information
-g|--git-fast-import-dump Dump the import to git-fast-import to gfi.in
-I|--no-import	Skip importing phase
-V|--no-verify	Skip verification phase
-v|--verbose	Pass verbose to the import-dir command
EOF
  exit 1
}

# Create a version of the README file with version SHA information appended
create_readme()
{
  fgrep -v zenodo.org/badge ../README.md
  echo
  echo '## Build identification'
  echo 'Data set versioned DOI: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2525586.svg)](https://doi.org/10.5281/zenodo.2525586)'
  echo 'Software versioned DOI: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2525601.svg)](https://doi.org/10.5281/zenodo.2525601)'
  echo -n '* Software URL: '
  git remote -v | sed -n 's/:/\//;s/.*git@/https:\/\//;s/\.git .*//;p;q'
  echo -n '* Software SHA: '
  git rev-parse HEAD
  date -u +'* Build timestamp: %F %T UTC'
} >README-SHA.md

add_boilerplate()
{
  cp ../old-code-license LICENSE
  cp ../Caldera-license.pdf .
  cp ../ALU-USA-statement.pdf .
  cp ../README-SHA.md README.md
  git add LICENSE README.md Caldera-license.pdf ALU-USA-statement.pdf
  git commit -a -m "Add licenses and README" >/dev/null
}


# Git fast import
gfi()
{
  if [ -n "$GFI_DUMP" ]
  then
    tee ../out/gfi.in
  else
    cat
  fi |
  git fast-import --stats --done --quiet 1>&2
  GFI_EXIT=${PIPESTATUS[1]}
  if [ $GFI_EXIT != 0 ] ; then
    exit 77
  fi
  set +x
}

# Succeed if the specified file exists and is newer than this script
is_up_to_date()
{
  test -r "$1" -a "$1" -nt ../import.sh
}

# Import the data sources in archive into a Git archive
import()
{
  # Check prerequisite Perl module
  if ! perl -MVCS::SCCS -e 1 2>/dev/null
  then
    echo "The VCS::SCCS module is not installed"
    exit 1
  fi

  # Initialize repo
  create_readme
  rm -rf $REPO
  mkdir $REPO
  cd $REPO
  git init
  rm .git/hooks/*.sample
  echo Unix History Repository >.git/description

  add_boilerplate
  git tag Licenses

  # Create a blank repository to avoid the first release having as its
  # only parent one that was committed in the modern era
  git checkout --orphan Epoch
  TZ=UTC GIT_COMMITTER_DATE='1970-01-01T00:00:00' \
    GIT_AUTHOR_DATE='1970-01-01T00:00:00' git commit --allow-empty -m "$FIRST_COMMIT"

  # Release branch
  git branch Research-Release

  # PDP-7: Assembly language kernel and utilities
  perl ../import-dir.pl $VERBOSE -m Epoch,Licenses -c ../author-path/Research-V1 -n ../bell.au \
    $DEBUG -i ../ignore/Research-PDP7 \
    $ARCHIVE/pdp7-unix/scans Research PDP7 -0500 | gfi

  # V1: Assembly language kernel
  perl ../import-dir.pl $VERBOSE -m Research-PDP7 -c ../author-path/Research-V1 -n ../bell.au \
    $DEBUG \
    $ARCHIVE/v1/sys Research V1 -0500 | gfi

  # V2: Fragments of a few commands mostly in assembly, C compiler and library
  perl ../import-dir.pl $VERBOSE -m Research-V1 -c ../author-path/Research-V2 \
    -n ../bell.au $DEBUG \
    -u ../unmatched/Research-V2 $ARCHIVE/v2 Research V2 -0500 | gfi

  # V3: Part of the C compiler, manual pages
  perl ../import-dir.pl $VERBOSE -m Research-V2 -c ../author-path/Research-V3 \
    -n ../bell.au -r Research-V2 $DEBUG \
    -u ../unmatched/Research-V3 $ARCHIVE/v3 Research V3 -0500 | gfi

  # V4: C kernel, manual pages
  perl ../import-dir.pl $VERBOSE -m Research-V3 -c ../author-path/Research-V4 \
    -n ../bell.au -r Research-V3 $DEBUG \
    -u ../unmatched/Research-V4 $ARCHIVE/v4 Research V4 -0500 | gfi

  # V5: Full (apart from manual pages)
  perl ../import-dir.pl $VERBOSE -m Research-V4 -c ../author-path/Research-V5 \
    -n ../bell.au -r Research-V3,Research-V4 $DEBUG \
    -u ../unmatched/Research-V5 $ARCHIVE/v5 Research V5 -0500 | gfi

  # V6: Full
  perl ../import-dir.pl $VERBOSE -m Research-V5 -c ../author-path/Research-V6 \
    -n ../bell.au -r Research-V4,Research-V5 $DEBUG \
    -u ../unmatched/Research-V6 $ARCHIVE/v6 Research V6 -0500 | gfi

  # BSD1: Just commands; forked from V6
  # Leaves behind .ref-Research-V6
  perl ../import-dir.pl $VERBOSE -m Research-V6 -c ../author-path/BSD-1 \
    -n ../berkeley.au -r Research-V6 $DEBUG -i ../ignore/BSD-1 \
    -u ../unmatched/BSD-1 $ARCHIVE/1bsd BSD 1 -0800 | gfi

  # BSD2: Just commands
  perl ../import-dir.pl $VERBOSE -m BSD-1 -c ../author-path/BSD-2 -n ../berkeley.au \
    -r BSD-1,Research-V6 $DEBUG -i ../ignore/BSD-2 \
    -u ../unmatched/BSD-2 $ARCHIVE/2bsd BSD 2 -0800 | gfi

  # V7: Full
  perl ../import-dir.pl $VERBOSE -m Research-V6 -c ../author-path/Research-V7 \
    -n ../bell.au -r Research-V6 $DEBUG -i ../ignore/Research-V7 \
    -u ../unmatched/Research-V7 $ARCHIVE/v7 Research V7 -0500 | gfi

  # Unix/32V: Full
  perl ../import-dir.pl $VERBOSE -m Research-V7 -c ../author-path/Bell-32V \
    -n ../bell.au -r Research-V7 $DEBUG -i ../ignore/Bell-32V \
    $ARCHIVE/32v Bell 32V -0500 | gfi

  # BSD 3.0: First full distribution
  # Merge 32V and 2BSD
  perl ../import-dir.pl $VERBOSE -m Bell-32V,BSD-2 -c ../author-path/BSD-3 \
    -n ../berkeley.au -r Bell-32V,BSD-2 $DEBUG -i ../ignore/BSD-3 \
    -u ../unmatched/BSD-3 $ARCHIVE/3bsd BSD 3 -0800 | gfi

  # BSD SCCS: From 1980 to 1995
  DIR=../archive/CSRG/cd4.patched
  if [ -n "$DEBUG" ]
  then
    STRIP="-s $DIR"
    DIR=$DIR/sys/sys
  fi
  perl ../import-dir.pl $VERBOSE -l -S -C 1996-01-01 -m BSD-3 -c ../author-path/BSD-3 \
    -n ../berkeley.au -u ../unmatched/BSD-SCCS.authors $DEBUG \
    -r BSD-3 -P usr/src/ $STRIP $DIR BSD-SCCS | gfi

  # Merge SCCS and incremental 4BSD additions
  SCCS_AT_RELEASE=$(git log --before='1980-11-15 11:24:58 +0200' -n 1 --format='%H' BSD-SCCS)
  perl ../import-dir.pl $VERBOSE -l -m BSD-3,$SCCS_AT_RELEASE -c ../author-path/BSD-4 \
    -n ../berkeley.au \
    -r BSD-3,$SCCS_AT_RELEASE $DEBUG \
    -i ../ignore/BSD-4-src,../ignore/BSD-4-catman,../ignore/BSD-4-other,../ignore/BSD-4-map \
    -I ../ignore/BSD-4-sccs \
    -u ../unmatched/BSD-4 $ARCHIVE/CSRG//cd1/4.0 BSD 4 -0800 | gfi


  # Merge SCCS and incremental BSD additions on snapshots
  # See http://minnie.tuhs.org/Unix_History/4bsd
  # Timestamps were derived by inspecting the archive/CSRG/*.time files. These were
  # generated with the following command, which creates and ordered list of text
  # file modification times.
  # for i in cd1/4* cd2/* cd3/* ; do find . -type f | xargs file | awk -F: '$2 ~ /text/ {print $1}'| xargs stat --format='%n %Y %y' | sort -k 3n >`echo $i | sed 's|/|_|'`.time ; done
  #
  # R/L stands for BSD-Release branch or Leaf.
  #
  # Version	Parent		Directory		Last file timestamp + 1s  R/L
  cat <<\EOF |
4_1_snap	4		cd1/4.1.snap		1982-02-03 08:34:45 +0200 R
4_1c_2		4_1_snap	cd1/4.1c.2		1983-03-12 10:46:32 +0200 R
4_2		4_1c_2		cd1/4.2			1983-09-26 16:24:27 +0200 R
4_3		4_2		cd1/4.3			1987-03-02 09:38:51 +0200 R
4_3_Tahoe	4_3		cd2/4.3tahoe		1989-05-23 13:47:44 +0300 R
4_3_Net_1	4_3_Tahoe	cd2/net.1		1989-01-01 12:15:59 +0200 L
4_3_Reno	4_3_Tahoe	cd2/4.3reno		1991-01-02 10:10:59 +0200 R
4_3_Net_2	4_3_Reno	cd2/net.2		1991-04-19 11:49:58 +0300 L
4_4		4_3_Reno	cd3/4.4			1993-06-06 10:12:36 +0300 R
4_4_Lite1	4_4		cd2/4.4BSD-Lite1	1994-04-02 06:05:37 +0300 R
4_4_Lite2	4_4_Lite1	cd3/4.4BSD-Lite2	1995-04-28 13:13:03 +0300 R
EOF
  while read version parent dir date time tz rl ; do
    dir=../archive/CSRG/$dir
    parent=BSD-$parent

    # Exclude administrative files (SCCS and .MAP), and
    # files with spaces in their names
    is_up_to_date ../ignore/BSD-${version}-admin ||
      (
	case ${version} in
	  4_1c_2)
	    echo LABEL
	    echo TAPE/FILE.1
	    echo TAPE/FILE.2
	    ;;
	  4_4)
	    echo BAK
	    ;;
	esac
	find $dir -type f |
	egrep '(/\.MAP)|(/SCCS/)| ' |
	sed "s|$dir/||" |
	sort
      ) >../ignore/BSD-${version}-admin

    # Exclude additional installed files
    is_up_to_date ../ignore/BSD-${version}-other || (
      find $dir/bin -type f
      find $dir/etc -type f
      find $dir/usr/bin -type f
      find $dir/usr/ingres -type f 2>/dev/null
      find $dir/usr/lasttape -type f 2>/dev/null
      find $dir/usr/ucb -type f
      find $dir/usr/include/sys -type f
    ) |
    sed "s|$dir/||" |
    sort |
    comm -23 - <(sort ../ignore/BSD-${version}-admin) >../ignore/BSD-${version}-other

    # Exclude files that are under SCCS control
    SCCS_AT_RELEASE=$(git log --before="$date $time $tz" -n 1 --format='%H' BSD-SCCS)
    # Tag the release at the SCCS branch
    git tag BSD-$version-Snapshot-Development $SCCS_AT_RELEASE

    is_up_to_date ../ignore/"BSD-${version}-sccs" || (
      # Files in the SCCS tree
      git ls-tree --full-tree --name-only -r $SCCS_AT_RELEASE |
      egrep -v '^((\.ref)|(LICENSE)|(README\.md)|(ALU-USA-statement\.pdf)(Caldera-license\.pdf))'

      # Files with SCCS mark
      find $dir -type f |
      egrep -v '(\.MAP)|(/SCCS/)|(/ingres/)|['"'"'" ]' |
      # Only text files
      perl -ne 'chop; print "$_\n" if -T ' |
      xargs fgrep -l '@(#)' |
      sed "s|$dir/||" |
      sort |
      comm -23 - ../ignore/BSD-${version}-other
    ) | sort -u >../ignore/"BSD-${version}-sccs"

    perl ../import-dir.pl $VERBOSE -m $parent,$SCCS_AT_RELEASE \
      -l \
      -c ../author-path/BSD-default \
      -n ../berkeley.au \
      -r $parent,$SCCS_AT_RELEASE $DEBUG \
      -i ../ignore/BSD-${version}-other,../ignore/BSD-${version}-admin \
      -I ../ignore/BSD-${version}-sccs \
      -u ../unmatched/BSD-$version $dir \
      BSD $version -0800 | gfi
    # For leaf branches move BSD-Release pointer back to their parent
    if [ $rl = 'L' ] ; then
      git branch -f BSD-Release $parent
    fi
  done

  # 386BSD 0.0
  perl ../import-dir.pl $VERBOSE -m BSD-4_3_Net_2 -c ../author-path/386BSD \
    -n ../386bsd.au -r BSD-4_3_Net_2 $DEBUG \
    -u ../unmatched/386BSD-0.0 \
    $ARCHIVE/386BSD-0.0/src 386BSD 0.0 -0800 | gfi

  # 386BSD 0.1
  perl ../import-dir.pl $VERBOSE -m 386BSD-0.0 -c ../author-path/386BSD \
    -n ../386bsd.au -r 386BSD-0.0 $DEBUG \
    -u ../unmatched/386BSD-0.1 \
    -i ../ignore/386BSD-0.1 \
    $ARCHIVE/386BSD-0.1 386BSD 0.1 -0800 | gfi

  # 386BSD 0.1 patchkit
  perl ../import-dir.pl $VERBOSE -m 386BSD-0.1 -b 386BSD-0.1 $DEBUG \
    -G 'Diomidis Spinellis <dds@FreeBSD.org> 739659600 +0000' \
    $ARCHIVE/386BSD-0.1-patched/ 386BSD-0.1-patchkit \
    --progress=1000 | gfi

  # Early FreeBSD from the CVS repo converted into git
  MERGED_FREEBSD_1=386BSD-0.1-patchkit,BSD-4_3_Net_2

  #"FINAL_1_0" transformed to "FreeBSD-release/1.0" in 7525 files
  #"FINAL_1_1" transformed to "FreeBSD-release/1.1" in 8728 files
  #"FINAL_1_1_5" transformed to "FreeBSD-release/1.1.5" in 9530 files
  # Reference commit date obtained as two days earlied than first commit
  # Author: Rod Grimes <rgrimes@FreeBSD.org>
  # Date: 12 June 1993 17:58:18
  # Initial import, 0.1 + pk 0.2.4-B1
  # date +%s -d '1993-06-10'
  # 739659600
  perl ../import-dir.pl $VERBOSE -r $MERGED_FREEBSD_1 -m $MERGED_FREEBSD_1 \
    -R 1993-10-29 \
    -G 'Diomidis Spinellis <dds@FreeBSD.org> 739659600 +0000' \
    $ARCHIVE/freebsd-early.git/ \
    FreeBSD-release/1.0 FreeBSD-release/1.1 FreeBSD-release/1.1.5 HEAD \
    --progress=1000 | gfi

  # Modern FreeBSD starting from 2.0
  # Branches that get merged
  # See http://ftp.netbsd.org/pub/NetBSD/NetBSD-current/src/share/misc/bsd-family-tree
  MERGED_FREEBSD_2="BSD-4_4_Lite1,FreeBSD-release/1.1.5"

  # Branches to import
  if [ -n "$DEBUG" ]
  then
    REFS='release/2.0 release/3.0.0'
  else
    REFS=$(cd $ARCHIVE/freebsd.git/ ; git branch -l | egrep -v 'projects/|user/| master|svn_head' | sort -t/ -k2n)\ HEAD
  fi

  perl ../import-dir.pl $VERBOSE -r $MERGED_FREEBSD_2 -m $MERGED_FREEBSD_2 \
    -R '1994-11-22 10:59:00 +0000' \
    -n ../freebsd.au \
    -G 'Diomidis Spinellis <dds@FreeBSD.org> 785501938 +0000' \
    -P FreeBSD- $ARCHIVE/freebsd.git/ $REFS --progress=1000 | gfi

  # Adding boilerplate again seems to help getting a modern
  # timestamp for the files displayed on GitHub
  add_boilerplate
  cd ..
}

# Succeed if text files in the two specified directories
# are the same
verify_same_text()
{
  echo "Verifying contents of $2"
  if ! diff -r "$1" "$2" |
    fgrep -v -f "$3" |
    perl -ne '
      BEGIN {$exit = 0}
      chop;
      if (!s/^Only in // || !s|: |/| || -T) {
        next if (/LICENSE/);
        next if (/Caldera-license\.pdf/);
        next if (/ALU-USA-statement\.pdf/);
        next if (/README\.md/);
        $exit = 1;
        print "$_\n"
      }
      END {exit $exit}'
  then
    echo "Differences found" 1>&2
    exit 1
  fi
}

# Ensure that the specified directory is present
ensure_present()
{
  if ! [ -d "$1" ] ; then
    echo "Directory $1 not found" 1>&2
    exit 1
  fi
}

# Ensure that the specified directory is not present
ensure_absent()
{
  if [ -d "$1" ] ; then
    echo "Directory $1 should not be there" 1>&2
    exit 1
  fi
}

# verify_nodes branch/merge number
# Verify the number of the specified branch/merge type
verify_nodes()
{
  local N_EXPECTED=$2
  local N_JOIN=`git log --graph | fgrep -c $1`
  if [ $N_JOIN -lt $N_EXPECTED ]
  then
    echo "Found $N_JOIN instances of $1; expected $N_EXPECTED" 1>&2
    exit 1
  fi
}

# Compare the specified tag/branch with the specified directory against
# the specified thresholds
compare_repo()
{
  local id="$1"
  local dir="$2"
  local expected_diff_files="$3"
  local expected_diff_lines="$4"
  local expected_only_files="$5"
  local expected_errors="$6"

  git checkout "$id"
  DIFFS="$(diff -r . $dir 2>../diff.errors | tee ../diff.out | ../diff-sum.awk)"
  set $DIFFS
  local actual_diff_files="$1"
  local actual_diff_lines="$2"
  local actual_only_files="$3"
  local actual_errors=$(wc -l <../diff.errors)

  if [ $actual_errors -gt $expected_errors ] ; then
    cat ../diff.errors
    echo "More errors ($actual_errors) than expected ($expected_errors)" 1>&2
    exit 1
  fi
  rm ../diff.errors

  if [ $actual_diff_files -gt $expected_diff_files ] ; then
    echo "More different files ($actual_diff_files) than expected ($expected_diff_files)" 1>&2
    echo 'See diff.out' 1>&2
    exit 1
  fi
  if [ $actual_diff_lines -gt $expected_diff_lines ] ; then
    echo "More different lines ($actual_diff_lines) than expected ($expected_diff_lines)" 1>&2
    echo 'See diff.out' 1>&2
    exit 1
  fi
  if [ $actual_only_files -gt $expected_only_files ] ; then
    echo "More missing / extra files ($actual_only_files) than expected ($expected_only_files)" 1>&2
    echo 'See diff.out' 1>&2
    exit 1
  fi
  rm ../diff.out
}

# Verify the import
verify()
{
  cd $REPO

  # Verify that trees go back all the way to the first commit
  for i in 386BSD-0.1-patchkit FreeBSD-release/1.0 FreeBSD-release/2.0 \
    FreeBSD-release/3.0.0 ; do
    if ! git log --oneline --reverse $i -- | head -1 | grep "$FIRST_COMMIT" >/dev/null ; then
      echo "Incorrect parent for $i" 1>&2
      exit 1
    fi
  done

  # Verify Research releases are the same
  for i in 2 3 4 5 6
  do
    git checkout Research-V$i
    verify_same_text . $ARCHIVE/v$i /dev/null
  done
  verify_same_text . $ARCHIVE/v7 ../ignore/Research-V7

  # Verify BSD releases
  for i in 1 2 3
  do
    git checkout BSD-$i
    verify_same_text . $ARCHIVE/${i}bsd ../ignore/BSD-${i}
  done

  git checkout Bell-32V
  verify_same_text . $ARCHIVE/32v ../ignore/Bell-32V

  git checkout BSD-4
  verify_same_text . $ARCHIVE/CSRG/cd1/4.0 ../ignore/BSD-4-src

  # Verify that log/blame work as expected
  N_EXPECTED=3
  git checkout Research-Release
  for i in  usr/src/cmd/c/c00.c usr/sys/sys/pipe.c
  do
    echo Verify blame/log of $i
    N_ADD=`git log --follow --simplify-merges $i | grep -c "Work on"`
    if [ $N_ADD -lt $N_EXPECTED ]
    then
      echo "Found $N_ADD additions for $i; expected $N_EXPECTED" 1>&2
      exit 1
    fi
    N_BLAME=`git blame -C -C $i | awk '{print $1}' | sort -u | wc -l`
    if [ $N_BLAME -lt $N_EXPECTED ]
    then
      echo "Found $N_BLAME blames for $i; expected $N_EXPECTED" 1>&2
      exit 1
    fi
  done

  git checkout BSD-Release
  echo Verify branches and merges
  verify_nodes '|/' 55
  verify_nodes '|\' 32

  echo Verify symbolic links
  if ! [ -L usr/src/usr.bin/pascal/libpc/whoami.h ]
  then
    echo "usr/src/usr.bin/pascal/libpc/whoami.h is not a symbolic link" 1>&2
    exit 1
  fi

  echo Verify SCCS merge
  N_HASH=$(git blame -C -C usr/src/sys/sys/proc.h |
    awk '{print $1}' |
    sort -u |
    wc -l)

  N_EXPECTED=32
  if [ $N_HASH -lt $N_EXPECTED ]
  then
    echo "Found $N_HASH versions in BSD-Release proc.h; expected $N_EXPECTED" 1>&2
    exit 1
  fi

  # Exact numbers
  compare_repo 386BSD-0.1-patchkit ../archive/386BSD-0.1-patched 0 0 296 726
  compare_repo 386BSD-0.1-patchkit-Import ../archive/../archive/386BSD-0.1 0 0 117 692
  compare_repo 386BSD-0.0-Snapshot-Development ../archive/../archive/386BSD-0.0/src 0 0 28 574
  compare_repo 386BSD-0.1-Snapshot-Development ../archive/../archive/386BSD-0.1 0 0 118 692

  # Verify that we're not including ignored directory
  if [ -z "$DEBUG" ] ; then
    git checkout 386BSD-0.1
    ensure_absent usr/include
  fi

  git checkout FreeBSD-release/1.0
  for i in $(echo $MERGED_FREEBSD_1 | sed 's/,/ /')
  do
    ensure_present .ref-$i
  done

  # Actually 33 1220 54
  # Missing files are GNU utilities
  compare_repo FreeBSD-release/1.0 ../archive/FreeBSD-1.0/filesys/usr/src/ 40 1300 55 0

  git checkout FreeBSD-release/1.1
  for i in $(echo $MERGED_FREEBSD_1 | sed 's/,/ /')
  do
    ensure_absent .ref-$i
  done

  # Actually 43 272 126
  # Missing files are mainly from gnu/lib/libg++/g++-include
  compare_repo FreeBSD-release/1.1 ../archive/FreeBSD-1.1/filesys/usr/src/ 45 300 127 0

  # Actually 64 234 20
  # Missing files are mainly kernel configurations
  compare_repo FreeBSD-release/1.1.5 ../archive/FreeBSD-1.1.5/usr/src/ 70 300 21 0

  git checkout FreeBSD-release/2.0
  for i in $(echo $MERGED_FREEBSD_2 | sed 's/,/ /')
  do
    ensure_present .ref-$i
  done

  git checkout FreeBSD-release/3.0.0
  for i in $(echo $MERGED_FREEBSD_2 | sed 's/,/ /')
  do
    ensure_absent .ref-$i
  done

  echo Verify FreeBSD merge
  N_HASH=$(git blame -C -C sys/sys/proc.h |
    awk '{print $1}' |
    sort -u |
    wc -l)

  N_EXPECTED=58
  if [ $N_HASH -lt $N_EXPECTED ]
  then
    echo "Found $N_HASH versions in FreeBSD 3.0.0 proc.h; expected $N_EXPECTED" 1>&2
    exit 1
  fi
  echo Verification finished
}

# Remove comments and defaults from the specified file(s)
uncomment()
{
  sed 's/#.*//;s/^%.*//;/^$/d' $*
}

# Verify authors are defined for specified author path file(s)
check_author()
{
  local author
  author=$1
  shift
  local missing_authors
  missing_authors=$(comm -13 \
    <(uncomment $author | cut -d: -f 1 | sort -u) \
    <(uncomment "$@" | awk '{print $2}' | tr , \\n | sort -u) )
  if [ "$missing_authors" ] ; then
    echo "Missing author definitions:" 1>&2
    echo $missing_authors 1>&2
    exit 1
  fi
}

preconditions()
{
  # Check for duplicate author definitions
  for f in *.au ; do
    duplicates=$(sed 's/#.*//;/^%/d;/^$/d' $f | cut -d: -f 1 | sort | uniq -d)
    if [ "$duplicates" ] ; then
      echo "Duplicate author definitions  in $f:" 1>&2
      echo "$duplicates" 1>&2
      exit 1
    fi
  done

  # Check for missing author definitions
  check_author bell.au author-path/Research-* author-path/Bell-32V \
    author-path/Sys-*
  check_author berkeley.au author-path/BSD-*
  check_author 386bsd.au author-path/386BSD

  # Check that CDs are mounted
  # List generated with the following command
  # df -h | awk '/loop/{print $6}' | while read d ; do for i in $d/* ; do echo $i ; break ; done; done
  for c in \
    /home/dds/src/unix-history-make/src/archive/FreeBSD-1.0/cdinstal \
    /home/dds/src/unix-history-make/src/archive/FreeBSD-1.1/cdinstal \
    /home/dds/src/unix-history-make/src/archive/FreeBSD-1.1.5.1/00_TRANS.TBL \
    /home/dds/src/unix-history-make/src/archive/CSRG/cd1/1bsd \
    /home/dds/src/unix-history-make/src/archive/CSRG/cd2/4.3reno \
    /home/dds/src/unix-history-make/src/archive/CSRG/cd3/4.4 \
    /home/dds/src/unix-history-make/src/archive/CSRG/cd4/admin
  do
    if ! [ -r $c ] ; then
      echo "No mounted file system in $(dirname $c); run make" 1>&2
      exit 1
    fi
  done

  # Check that ignored files are still there
  if ! grep LABEL ignore/BSD-4_1c_2-admin >/dev/null ; then
    echo "Missing ignored files in ignore/BSD-4_1c_2-admin" 1>&2
    exit 1
  fi
}

# Option processing; see getopt-parse.bash
# Note that we use `"$@"' to let each command-line parameter expand to a
# separate word. The quotes around `$@' are essential!
# We need TEMP as the `eval set --' would nuke the return value of getopt.
# Usage: $0 [--debug] [--no-import] [--no-verify]

TEMP=`getopt -o d,g,G,I,V,v --long debug,git-fast-import-dump,no-gc,no-import,no-verify,verbose -n 'import' -- "$@"`

if [ $? != 0 ] ; then
	usage
fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while : ; do
  case "$1" in
    -d|--debug)
      # When debugging import only a few representative files
      export DEBUG=-p\ '([su]1\.s)|(a1\.s)|(((nami)|(c00)|(ex_addr)|(sys_socket))\.c)|(open\.2)|(((sysexits)|(proc)|(stat)|(telextrn))\.h)'
      shift
      ;;
    -g|--git-fast-import-dump)
      GFI_DUMP=true
      shift
      ;;
    -G|--no-gc)
      SKIP_GC=true
      shift
      ;;
    -I|--no-import)
      SKIP_IMPORT=true
      shift
      ;;
    -V|--no-verify)
      SKIP_VERIFY=true
      shift
      ;;
    -v|--verbose)
      VERBOSE=-v
      shift
      ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

# Main processing starts here
preconditions
test "$SKIP_IMPORT" || import
test "$DEBUG" && exit
test "$SKIP_VERIFY" || verify
test "$SKIP_GC" || git gc --aggressive
