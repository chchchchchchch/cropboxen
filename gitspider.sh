#!/bin/bash

 #GITDIR="$1";GITDIR=`realpath $GITDIR`

  INPUT="$1"
  OUTDIR="_";OUTDIR=`realpath $OUTDIR`
# --------------------------------------------------------------------------- #
  TMPDIR="/tmp";TMP="$TMPDIR/tmp"
# --------------------------------------------------------------------------- #
  source lib/sh/git.functions
  source lib/sh/network.functions
  source lib/sh/svg.functions
# --------------------------------------------------------------------------- #
# LOCALIZE IF URL PROVIDED
# --------------------------------------------------------------------------- #
# TODO
# --------------------------------------------------------------------------- #
  if [ -d "$INPUT" ] || [ -f "$INPUT" ]
   then GITDIR=`realpath $INPUT`;GITDIR=`dirname $GITDIR` 
   else echo "$INPUT DOES NOT EXIST (?)";exit 0 
  fi
# --------------------------------------------------------------------------- #
  if [ `verifyGitPath $GITDIR | wc -l` -gt 0 ]
   then echo "$GITDIR NOT A GIT REPOSITORY (?)";exit 0;
  fi
  GITROOTPATH=`getGitRootPath $GITDIR`
  if [ ! -d "$GITROOTPATH" ]
   then echo "SOMETHING WENT WRONG. EXITING";exit 0
  fi
  GITSUBPATH=`echo $INPUT |                #
              sed "s,^$GITROOTPATH,," |    #
              sed 's,^/,,' | sed 's,/$,,'` #
  if [ -d "$GITROOTPATH/$GITSUBPATH" ];then GITSUBPATH="${GITSUBPATH}/";fi
# --------------------------------------------------------------------------- #
  GITREMOTEBASEURLS=`getGitRemoteBaseUrls $GITROOTPATH`
  for URL in $GITREMOTEBASEURLS
   do EXPANDURLS="$EXPANDURLS "`expandUrl $URL`
  done
  GITREMOTEBASEURLS="$EXPANDURLS"
# --------------------------------------------------------------------------- #
  cd $GITROOTPATH # CHANGE INTO GIT ROOT PATH
# --------------------------------------------------------------------------- #
# LIST ALL FILES AND WRITE TO TEMPORARY LIST
# --------------------------------------------------------------------------- #
  for BRANCH in `git for-each-ref --format='%(refname)' refs/heads/`
   do   git ls-tree -r --name-only $BRANCH . >> ${TMP}.list
  done; find . -name "*.svg" >> ${TMP}.list
# --------------------------------------------------------------------------- #
# PROCESS FILES (MATCHING)
# --------------------------------------------------------------------------- #
  for SVG in `cat ${TMP}.list       | #
              sed 's/^\.\///'       | #
              grep "^${GITSUBPATH}" | # ??????? WORKING ??????
              grep ".svg$"          | #
              sort -u`                #
   do BASENAME=`echo $SVG | md5sum | cut -c 1-12`
      echo -e "\n$SVG"
     (IFS=$'\n';
      for COMMIT in `git log --all --pretty="%h:%ct:%s" -- $SVG | tac`
       do echo $COMMIT
          HASH=`echo $COMMIT | cut -d ":" -f 1`
#         SVGOUT="${OUTDIR}/${BASENAME}_${HASH}.svg"
        # ------------------------------------------------------------ #
#         getGitRawUrl -a $GITREMOTEBASEURLS $HASH $SVG
        # ------------------------------------------------------------ #
#         git show ${HASH}:${SVG} > $SVGOUT
        # ------------------------------------------------------------ #
#         svgHasImg $SVGOUT
#       # ------------------------------------------------------------ #
#         cat $SVGOUT | sed 's/display:none//g' > ${TMP}.svg
#         inkscape --export-area-drawing \
#                  --export-png=${SVGOUT}.png \
#                 ${TMP}.svg > /dev/null 2>&1
#         VHASH=`md5sum ${SVGOUT}.png | cut -d " " -f 1`
#         if [ "$VHASH" != "$PREVVHASH" ]
#         then sleep 0
#         else echo "NO VISUAL CHANGES"
#              rm $SVGOUT
#         fi
#         PREVVHASH="$VHASH"
#       # ------------------------------------------------------------ #

      done;)
  # TODO: IF NOT TRACKED
  done
# --------------------------------------------------------------------------- #
  rm ${TMP}.list
# --------------------------------------------------------------------------- #
  cd - > /dev/null
# --------------------------------------------------------------------------- #

exit 0;

