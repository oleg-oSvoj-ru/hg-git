Load commonly used test logic
  $ . "$TESTDIR/testutil"

  $ git init gitrepo
  Initialized empty Git repository in $TESTTMP/gitrepo/.git/
  $ cd gitrepo
  $ echo alpha > alpha
  $ git add alpha
  $ fn_git_commit -m 'add alpha'

  $ git tag alpha

  $ git checkout -b beta 2>&1 | sed s/\'/\"/g
  Switched to a new branch "beta"
  $ echo beta > beta
  $ git add beta
  $ fn_git_commit -m 'add beta'


  $ cd ..
clone a tag
  $ hg clone -r alpha gitrepo hgrepo-a | grep -v '^updating'
  importing git objects into hg
  1 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg -R hgrepo-a log --graph
  @  changeset:   0:ff7a2f2d8d70
     bookmark:    master
     tag:         alpha
     tag:         default/master
     tag:         tip
     user:        test <test@example.org>
     date:        Mon Jan 01 00:00:10 2007 +0000
     summary:     add alpha
  
clone a branch
  $ hg clone -r beta gitrepo hgrepo-b | grep -v '^updating'
  importing git objects into hg
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg -R hgrepo-b log --graph
  @  changeset:   1:7fe02317c63d
  |  bookmark:    beta
  |  tag:         default/beta
  |  tag:         tip
  |  user:        test <test@example.org>
  |  date:        Mon Jan 01 00:00:11 2007 +0000
  |  summary:     add beta
  |
  o  changeset:   0:ff7a2f2d8d70
     bookmark:    master
     tag:         alpha
     tag:         default/master
     user:        test <test@example.org>
     date:        Mon Jan 01 00:00:10 2007 +0000
     summary:     add alpha
  

clone with mapsavefreq set
  $ rm -rf hgrepo-b
  $ hg clone -r beta gitrepo hgrepo-b --config hggit.mapsavefrequency=1 --debug | grep saving
  saving mapfile
  saving mapfile

Make sure that a deleted .hgsubstate does not confuse hg-git

  $ cd gitrepo
  $ echo 'HASH random' > .hgsubstate
  $ git add .hgsubstate
  $ fn_git_commit -m 'add bogus .hgsubstate'
  $ git rm -q .hgsubstate
  $ fn_git_commit -m 'remove bogus .hgsubstate'
  $ cd ..

  $ hg clone -r beta gitrepo hgrepo-c
  importing git objects into hg
  updating to branch default
  2 files updated, 0 files merged, 0 files removed, 0 files unresolved
  $ hg --cwd hgrepo-c status

clone empty repo
  $ git init empty
  Initialized empty Git repository in $TESTTMP/empty/.git/
  $ hg clone empty emptyhg
  updating to branch default
  0 files updated, 0 files merged, 0 files removed, 0 files unresolved
