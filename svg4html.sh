#!/bin/bash

  SVG="$1"
  OUTDIR="_"
# --------------------------------------------------------------------------- #
  source lib/sh/svg.functions
# --------------------------------------------------------------------------- #
  if [ ! -d "$OUTDIR" ]
   then echo "$OUTDIR DOES NOT EXIST";exit 0;fi
  SVGDIR=$OUTDIR/`echo $* | md5sum | cut -c 1-6`
  if [ -d "$SVGDIR" ]
   then echo "$SVGDIR DOES EXIST"
        echo "OVERWRITE?"
   else echo "CREATE $SVGDIR"
        mkdir -p $SVGDIR
  fi
# --------------------------------------------------------------------------- #
  FDATE="190405165301"
  SVGID="$FDATE"
  SVGINFO="$SVGDIR/${SVGID}.txt"
  echo "# STATUS:TIMESTAMP:ID:X:Y:W:H" > $SVGDIR/${SVGID}.bxn
# --------------------------------------------------------------------------- #
  AREA=`svgGetDimensions $SVG`
  MAX=`echo $AREA | cut -d ":" -f 3,4 | #
       sed 's/:/\n/' | sort -n | tail -n 1`
  MARGIN=`python -c "print $MAX / 100 * 10" | cut -d ":" -f 1`
  C=1;AREAPLUS=""
  for V in `echo $AREA | sed 's/:/ /g'`
   do   if [ "$C" -le 2 ]
        then V=`expr $V - $MARGIN / 2`
        else V=`expr $V + $MARGIN`
        fi
        C=`expr $C + 1`
        AREAPLUS="${AREAPLUS}:$V"
  done; AREAPLUS=`echo $AREAPLUS | sed 's/^://'` 
  AREA="$AREAPLUS"
  echo "AREA:$AREA" > $SVGINFO
# --------------------------------------------------------------------------- #
  sed 's/pagecolor="[^"]*"/\n&\n/' $SVG | #
  grep "^pagecolor" | cut -d '"' -f 2 | head -n 1 | #
  sed 's/^/BGCOLOR:/' >> $SVGINFO
# --------------------------------------------------------------------------- #
  svgLayers2Files $SVG $SVGDIR/$SVGID
# --------------------------------------------------------------------------- #
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
# --------------------------------------------------------------------------- #
  sed 's/viewBox="[^"]*"/\n&\n/' $SVGDIR/${SVGID}*.svg | #
  grep "^viewBox" | head -n 1 | cut -d '"' -f 2 | cut -d " " -f 3 | #
  sed 's/^/W:/' >> $SVGINFO
# ----
  sed 's/viewBox="[^"]*"/\n&\n/' $SVGDIR/${SVGID}*.svg | #
  grep "^viewBox" | head -n 1 | cut -d '"' -f 2 | cut -d " " -f 4 | #
  sed 's/^/H:/' >> $SVGINFO
# --------------------------------------------------------------------------- #

exit 0;

