#!/bin/bash

 #GITDIR="$1";GITDIR=`realpath $GITDIR`

  INPUT="$1"
  OUTDIR="_";OUTDIR=`realpath $OUTDIR`
  URLPATTERN="cropboxen.php?show=%FILEID%\&v=%VERSION%"
# --------------------------------------------------------------------------- #
  TMPDIR="/tmp";TMP="$TMPDIR/tmp"
# --------------------------------------------------------------------------- #
  source lib/sh/git.functions
  source lib/sh/network.functions
  source lib/sh/svg.functions
# =========================================================================== #
# LOCALIZE IF URL PROVIDED
# =========================================================================== #
# TODO
# =========================================================================== #
# PROCESS CLI INPUT AND PROCESS
# =========================================================================== #
  if [ -d "$INPUT" ]
  then GITDIR=`realpath $INPUT`
  elif [ -f "$INPUT" ]
  then GITDIR=`realpath $INPUT`
       GITDIR=`dirname $GITDIR` 
  else echo "$INPUT DOES NOT EXIST (?)";exit 0;fi
# =========================================================================== #
  if [ `verifyGitPath $GITDIR | wc -l` -gt 0 ]
  then  echo "$GITDIR NOT A GIT REPOSITORY (?)";exit 0;fi
        GITROOTPATH=`getGitRootPath $GITDIR`
  if [ ! -d "$GITROOTPATH" ]
  then  echo "SOMETHING WENT WRONG. EXITING";exit 0;fi
        GITSUBPATH=`echo $INPUT             |    #
                    sed "s,^$GITROOTPATH,," |    #
                    sed 's,^/,,' | sed 's,/$,,'` #
  if [ "$GITSUBPATH" != "" ] && [ -d "$GITROOTPATH/$GITSUBPATH" ]
  then  GITSUBPATH="${GITSUBPATH}/"; fi
# --------------------------------------------------------------------------- #
  GITREMOTEBASEURLS=`getGitRemoteBaseUrls $GITROOTPATH`
  for URL in $GITREMOTEBASEURLS do
   do EXPANDURLS="$EXPANDURLS "`expandUrl $URL`
  done
  GITREMOTEBASEURLS="$EXPANDURLS"
  GITREMOTEBASEURLONE=`echo $GITREMOTEBASEURLS | sed 's/ /\n/g' | head -n 1`
# =========================================================================== #

  cd $GITROOTPATH # CHANGE INTO GIT ROOT PATH
# =========================================================================== #
# CREATE TREE VIEW (TO BE MODIFIED)
# =========================================================================== #
  TREEID=`echo $GITREMOTEBASEURLONE | #
          md5sum | cut -c 1-6``echo $GITSUBPATH | #
                               md5sum | cut -c 1-4`
  tree --charset=ascii -f -P "*.svg" --prune $GITSUBPATH | #
  sed 's/`--/|--/g'                                             > ${TMP}.tree
# =========================================================================== #
# LIST ALL FILES AND WRITE TO TEMPORARY LIST
# =========================================================================== #
  for BRANCH in `git for-each-ref --format='%(refname)' refs/heads/`
   do   git ls-tree -r --name-only $BRANCH . >> ${TMP}.list
  done; find . -name "*.svg" >> ${TMP}.list
# =========================================================================== #
# PROCESS FILES (MATCHING)
# =========================================================================== #
  for SVG in `cat ${TMP}.list       | #
              sed 's/^\.\///'       | #
              grep "^${GITSUBPATH}" | # ??????? WORKING ??????
              grep ".svg$"          | #
              sort -u`                #
   do echo -e "\n$SVG"
      FILEID=`echo $GITREMOTEBASEURLONE$SVG | #
              md5sum | cut -c 1-6`            #
      SVGNAME=`basename $SVG`
      SVGDIR="$OUTDIR/$MAINID"
#     if [ ! -d $SVGDIR ];then mkdir $SVGDIR;fi
  # ----------------------------------------------------------------------- #
     (IFS=$'\n';CNT=1
  # ----------------------------------------------------------------------- #
      for COMMIT in `git log --all --pretty="%h:%ct:%s" -- $SVG | tac`
       do echo $COMMIT
          HASH=`echo $COMMIT | cut -d ":" -f 1`
          TIME=`echo $COMMIT | cut -d ":" -f 2`
         #HUMANTIME=`date -d @$TIME +%d.%m.%y" "%H:%M`
          TIMESTAMP=`date -d @$TIME +%y%m%d%H%M%S`
          MESSAGE=`echo $COMMIT | cut -d ":" -f 3-`
          SVGID="$TIMESTAMP"
          SVGINFO="$SVGDIR/${SVGID}.txt"
        # ------------------------------------------------------------ #
          CNT=`echo 00$CNT | rev | cut -c 1-2 | rev`
          AHREF=`echo $URLPATTERN          | #
                 sed "s,%FILEID%,$FILEID," | #
                 sed "s,%VERSION%,$SVGID," | #
                 sed 's,^,[<a href=",'     | #
                 sed "s,$,\">$CNT</a>],"`    #
          sed -i "\,$SVG,s,$, $AHREF," ${TMP}.tree
        # ------------------------------------------------------------ #
#         TMPSVG="${TMP}.${TIMESTAMP}.svg"
        # ------------------------------------------------------------ #
          GITURLS=`getGitRawUrl -a $GITREMOTEBASEURLS $HASH $SVG | #
                   sed 's/^/GITURL:/'`
#       # ------------------------------------------------------------ #
#         git show ${HASH}:${SVG} > $TMPSVG
#       # ------------------------------------------------------------ #
#         cat $TMPSVG | sed 's/display:none//g' > ${TMP}.svg
#         inkscape --export-area-drawing \
#                  --export-png=${TMP}.png \
#                 ${TMP}.svg > /dev/null 2>&1
#         VHASH=`md5sum ${TMP}.png | cut -d " " -f 1`
#       # ============================================================ #
#         if [ "$VHASH" != "$PREVVHASH" ]
#         then
#       # ------------------------------------------------------------ #
#         echo $GITURLS | sed 's/ /\n/g'                   >  $SVGINFO
#       # ------------------------------------------------------------ #
#         echo "COMMITMESSAGE:$MESSAGE"                    >> $SVGINFO
#       # ------------------------------------------------------------ #
#         echo "# STATUS:TIMESTAMP:ID:X:Y:W:H"  > $SVGDIR/${SVGID}.bxn
#       # ------------------------------------------------------------ #
#         AREA=`svgGetDimensions $TMPSVG`
#         MAX=`echo $AREA | cut -d ":" -f 3,4 | #
#              sed 's/:/\n/' | sort -n | tail -n 1`
#         MARGIN=`python -c "print $MAX / 100 * 10" | cut -d "." -f 1`
#         C=1;AREAPLUS=""
#         for V in `echo $AREA | sed 's/:/\n/g'`
#          do   if [ "$C" -le 2 ]
#               then V=`expr $V - $MARGIN / 2`
#               else V=`expr $V + $MARGIN`
#               fi
#               C=`expr $C + 1`
#               AREAPLUS="${AREAPLUS}:$V"
#         done; AREAPLUS=`echo $AREAPLUS | sed 's/^://'`
#         AREA="$AREAPLUS"
#         echo "AREA:$AREA"                                >> $SVGINFO
#       # ------------------------------------------------------------ #
#         sed 's/pagecolor="[^"]*"/\n&\n/' $TMPSVG | #
#         grep "^pagecolor" | cut -d '"' -f 2 | head -n 1 | #
#         sed 's/^/BGCOLOR:/' >> $SVGINFO
#       # ------------------------------------------------------------ #
#         svgLayers2Files $TMPSVG $SVGDIR/$SVGID
#       # ------------------------------------------------------------ #
#         for SVGLAYER in `ls $SVGDIR/${SVGID}*.svg`
#          do #echo $SVGLAYER
#             LAYERNAME=`cat $SVGLAYER | #
#                        sed 's/inkscape:label="[^"]*"/\n&\n/' | #
#                        grep "^inkscape:label" | cut -d '"' -f 2 | #
#                        head -n 1`
#             LAYERNAMEID=`echo $SVGLAYER | rev | #
#                          cut -d "_" -f 1 | rev | #
#                          sed 's/\.svg$//'`       #
#             echo "$LAYERNAMEID:$LAYERNAME" >> $SVGINFO
#             svgCropArea $SVGLAYER ${SVGLAYER%%.*}_CROP.svg $AREA
#             svgBake ${SVGLAYER%%.*}_CROP.svg $SVGLAYER
#             rm ${SVGLAYER%%.*}_CROP.svg
#         done
#       # ------------------------------------------------------------ #
#         sed 's/viewBox="[^"]*"/\n&\n/' $SVGDIR/${SVGID}*.svg | #
#         grep "^viewBox" | head -n 1 | #
#         cut -d '"' -f 2 | cut -d " " -f 3 | #
#         sed 's/^/W:/' >> $SVGINFO
#       # ----
#         sed 's/viewBox="[^"]*"/\n&\n/' $SVGDIR/${SVGID}*.svg | #
#         grep "^viewBox" | head -n 1 | #
#         cut -d '"' -f 2 | cut -d " " -f 4 | #
#         sed 's/^/H:/' >> $SVGINFO
#       # ------------------------------------------------------------ #
#       # ============================================================ #
#         else echo "NO VISUAL CHANGES"
#              rm ${TMPSVG}
#         fi
#         PREVVHASH="$VHASH"
#       # ============================================================ #
          CNT=`expr $CNT + 1`
      done;)
  # ----------------------------------------------------------------------- #
    sed -i "s,$SVG,$SVGNAME,g" ${TMP}.tree
  # ----------------------------------------------------------------------- #
  # TODO: IF NOT TRACKED
  done
# --------------------------------------------------------------------------- #
  cd - > /dev/null

# =========================================================================== #
# FORMAT TREE VIEW
# =========================================================================== #
  GITSUBPATH=`echo $GITSUBPATH | sed 's,/$,,'`
  CHARGSP=`echo -n $GITSUBPATH | wc -c`
  if [ $CHARGSP == 0 ];then CHARGSP=2;fi
  TREEINDENT=`printf " %.0s" {1..100} | cut -c 2-$CHARGSP`
  sed -i "s/^/$TREEINDENT/"   ${TMP}.tree
  sed -i "1s,.*,$GITSUBPATH," ${TMP}.tree
# --------------------------------------------------------------------------- #
  CHARMAX=`cat ${TMP}.tree | #
           sed 's/\[[^]]*\]/XXXX/g' | #
           wc -L`;CHARMAX=`expr $CHARMAX + 10`
  HL=`printf -- "-%.0s" {1..200} | cut -c 3-$CHARMAX`
# --------------------------------------------------------------------------- #
  sed -i 's,-- ./,-- ,'                       ${TMP}.tree
  sed -i '/\.svg$/d'                          ${TMP}.tree
  sed -i '\,\.svg ,!s,\(|-- \)\(.*/\),\1,'    ${TMP}.tree
# --------------------------------------------------------------------------- #
 (IFS=$'\n';
  for L in `cat ${TMP}.tree`
   do CHARNUM=`echo "$L" | sed 's/\[[^]]*\]/XXXX/g' | wc -c`
      CHARPAD=`expr $CHARMAX - $CHARNUM`
      TREEPAD=`printf " %.0s" {1..100} | cut -c 1-$CHARPAD`
      echo $L | sed "s/\(\.svg\)\( \)\(\[\)/\1$TREEPAD\3/" >> ${TMP}.tree.mod
   done;) 
# --------------------------------------------------------------------------- #
  TREEHREF="$GITREMOTEBASEURLONE/tree/master/$GITSUBPATH"
  TREEHEAD="$GITREMOTEBASEURLONE"
  sed -i "1s,.*,$HL\n$TREEHEAD\n$HL\n&,"       ${TMP}.tree.mod
  sed -i '1s,.*,<html><body><pre>\n&,'         ${TMP}.tree.mod
  sed -i "\$s,.*,$HL\n</pre></body></html>,"   ${TMP}.tree.mod
# --------------------------------------------------------------------------- #
  mv ${TMP}.tree.mod ${OUTDIR}/${TREEID}.tree

# =========================================================================== #
# CLEAN UP
# =========================================================================== #
  rm ${TMP}.list
# --------------------------------------------------------------------------- #

exit 0;
