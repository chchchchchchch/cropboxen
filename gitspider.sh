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
  GITREMOTEBASEURLONE=`echo $GITREMOTEBASEURLS | sed 's/ /\n/g' | head -n 1`
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
   do #echo -e "\n$SVG"
      SVGDIR="$OUTDIR/"`echo $GITREMOTEBASEURLONE$SVG | #
                        md5sum | cut -c 1-6`            # 
      if [ ! -d $SVGDIR ];then mkdir $SVGDIR;fi
  # ----------------------------------------------------------------------- #
     (IFS=$'\n';
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
          TMPSVG="${TMP}.${TIMESTAMP}.svg"
        # ------------------------------------------------------------ #
          GITURLS=`getGitRawUrl -a $GITREMOTEBASEURLS $HASH $SVG | #
                   sed 's/^/GITURL:/'`
        # ------------------------------------------------------------ #
          git show ${HASH}:${SVG} > $TMPSVG
        # ------------------------------------------------------------ #
          cat $TMPSVG | sed 's/display:none//g' > ${TMP}.svg
          inkscape --export-area-drawing \
                   --export-png=${TMP}.png \
                  ${TMP}.svg > /dev/null 2>&1
          VHASH=`md5sum ${TMP}.png | cut -d " " -f 1`
        # ============================================================ #
          if [ "$VHASH" != "$PREVVHASH" ]
          then
        # ------------------------------------------------------------ #
          echo $GITURLS | sed 's/ /\n/g'                   >  $SVGINFO
        # ------------------------------------------------------------ #
          echo "COMMITMESSAGE:$MESSAGE"                    >> $SVGINFO
        # ------------------------------------------------------------ #
          echo "# STATUS:TIMESTAMP:ID:X:Y:W:H"  > $SVGDIR/${SVGID}.bxn
        # ------------------------------------------------------------ #
          AREA=`svgGetDimensions $TMPSVG`
          MAX=`echo $AREA | cut -d ":" -f 3,4 | #
               sed 's/:/\n/' | sort -n | tail -n 1`
          MARGIN=`python -c "print $MAX / 100 * 10" | cut -d "." -f 1`
          C=1;AREAPLUS=""
          for V in `echo $AREA | sed 's/:/\n/g'`
           do   if [ "$C" -le 2 ]
                then V=`expr $V - $MARGIN / 2`
                else V=`expr $V + $MARGIN`
                fi
                C=`expr $C + 1`
                AREAPLUS="${AREAPLUS}:$V"
          done; AREAPLUS=`echo $AREAPLUS | sed 's/^://'`
          AREA="$AREAPLUS"
          echo "AREA:$AREA"                                >> $SVGINFO
        # ------------------------------------------------------------ #
          sed 's/pagecolor="[^"]*"/\n&\n/' $TMPSVG | #
          grep "^pagecolor" | cut -d '"' -f 2 | head -n 1 | #
          sed 's/^/BGCOLOR:/' >> $SVGINFO
        # ------------------------------------------------------------ #
          svgLayers2Files $TMPSVG $SVGDIR/$SVGID
        # ------------------------------------------------------------ #
          for SVGLAYER in `ls $SVGDIR/${SVGID}*.svg`
           do #echo $SVGLAYER
              LAYERNAME=`cat $SVGLAYER | #
                         sed 's/inkscape:label="[^"]*"/\n&\n/' | #
                         grep "^inkscape:label" | cut -d '"' -f 2 | #
                         head -n 1`
              LAYERNAMEID=`echo $SVGLAYER | rev | #
                           cut -d "_" -f 1 | rev | #
                           sed 's/\.svg$//'`       #
              echo "$LAYERNAMEID:$LAYERNAME" >> $SVGINFO
              svgCropArea $SVGLAYER ${SVGLAYER%%.*}_CROP.svg $AREA
              svgBake ${SVGLAYER%%.*}_CROP.svg $SVGLAYER
              rm ${SVGLAYER%%.*}_CROP.svg
          done
        # ------------------------------------------------------------ #
          sed 's/viewBox="[^"]*"/\n&\n/' $SVGDIR/${SVGID}*.svg | #
          grep "^viewBox" | head -n 1 | #
          cut -d '"' -f 2 | cut -d " " -f 3 | #
          sed 's/^/W:/' >> $SVGINFO
        # ----
          sed 's/viewBox="[^"]*"/\n&\n/' $SVGDIR/${SVGID}*.svg | #
          grep "^viewBox" | head -n 1 | #
          cut -d '"' -f 2 | cut -d " " -f 4 | #
          sed 's/^/H:/' >> $SVGINFO
        # ------------------------------------------------------------ #
        # ============================================================ #
          else echo "NO VISUAL CHANGES"
               rm ${TMPSVG}
          fi
          PREVVHASH="$VHASH"
        # ============================================================ #

      done;)
  # ----------------------------------------------------------------------- #
  # TODO: IF NOT TRACKED
  done
# --------------------------------------------------------------------------- #
  rm ${TMP}.list
# --------------------------------------------------------------------------- #
  cd - > /dev/null
# --------------------------------------------------------------------------- #

exit 0;

