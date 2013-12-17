#!/usr/bin/env python
#coding: utf8

import sys
import os
import re
from subprocess import check_output, call, CalledProcessError


def parse_external(line):
    """Parse svn:externals property.

    assume that the externals are either defined as
    <folder> [-r<revision>] <url>
    <folder>[@<revision>] <url>

    return folder, revision, url
    revision might be None
    """
    match = re.match("""
        ^(?P<folder>[^@ \t]*)                # match the folder
        (?:(?:@|\s+-r)(?P<revision>[0-9]*))? # optionally, match the revision
        \s*(?P<url>.*)$                      # finally, match the rest as url
        """, line.strip(), re.VERBOSE)
    if not match:
        raise ValueError("svn::externals line could not be parsed")
    return match.groups()


def find_svnrevision():
    """Find the svn revision the current branch is based on.
    git-svn history should be very linear but we need to now on which svn
    revision the current branch is based. To do this, we traverse the parents
    of the current commit until git svn finds a corresponding svn revision

    return svn revision or None if none could be found
    """
    revlist = check_output(["git", "rev-list", "--parents", "HEAD"])
    for line in revlist.splitlines():
        parents = line.split()
        revision = check_output(["git", "svn", "find-rev", parents[0]])
        try:
            revision = int(revision)
            return revision
        except ValueError:
            pass

    return None

#Supply list of directories to check as arguments
externals = sys.argv[1:]
#If no arguments are given, try all known directories
if not externals:
    externals = ["genfit2"]

#Get Belle2 environment variables
try:
    LOCAL_DIR = os.environ["BELLE2_LOCAL_DIR"]
except KeyError:
    print "Belle2 not setup correctly"
    sys.exit(1)

#Let's change into the release dir
os.chdir(LOCAL_DIR)

#See if there is already an gitignore file, if so read it
gitignore = []
if os.path.exists(".gitignore"):
    with open(".gitignore") as f:
        gitignore_contents = f.readlines()

#Get the latest revision we checked out. This might not be the revision the
#current branch is based on but finding that revision is more difficult.
current_revision = find_svnrevision()
print "Checking svn:externals for r%s" % current_revision

for e in externals:
    print "directory '%s'" % e
    try:
        prop = check_output(["git", "svn", "propget",
                             "-r%s" % current_revision, "svn:externals", e])
    except CalledProcessError:
        #Apparently no externals here, move on
        continue

    #Fetch all externals
    for line in prop.split("\n"):
        if not line.strip():
            continue

        dirname, revision, url = parse_external(line)
        abspath = os.path.join(LOCAL_DIR, e, dirname)
        # Build command line for svn
        args = ["svn"]
        if os.path.exists(abspath):
            #Seems to exist already, so update to specified revision
            print "Updating", os.path.join(e, dirname),
            args.append("update")
        else:
            #Not there yet, checkout using svn
            print "Fetching", os.path.join(e, dirname),
            print "from", url,
            args += ["checkout", url]

        # If revision is specified, add it after the svn command
        if revision is not None:
            print "r" + revision,
            args.insert(2, "-r" + revision)

        # finish line
        print
        call(args + [abspath])

        #Check if it is already excluded
        exclude = "/%s/" % os.path.join(e, dirname).strip("/")
        if not any(e.startswith(exclude) for e in gitignore):
            #If not, add it to the gitignore
            gitignore.append(
                "%s # ignore directory containing svn:externals\n" % exclude)

#Write gitignore file
with open(".gitignore", "w") as f:
    f.writelines(gitignore)
