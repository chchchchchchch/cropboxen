#!/bin/bash

  SRCPATH="_"
  BASEURL="https://freeze.sh/_/2019/icebergen/cropboxen.php"
  URLPATTERN="$BASEURL?show=%SRCID%\&v=%VERSION%"

  TMPDIR="/tmp";TMP="$TMPDIR/tmp"

# --------------------------------------------------------------------------- #
  # https://askubuntu.com/questions/962170
  walk() { local INDENT="${2:-0}"
           D=`echo "$1" | rev | #
              cut -d "/" -f 1 | #
              rev`              #
           printf "%*s%s\n" $INDENT '' "$D"
           printf "%*s%s\n" $INDENT '' "<ul>"
           for ITEM in `grep $1 ${TMP}.list | #
                        sed "s,\(^$1/[^/]*/\)\(.*\),\1," | #
                        sort -u | sed 's,/$,,'`
            do
               ISFILE=`echo $ITEM | egrep "\.item$" | wc -l`
              #echo "$ITEM (ISFILE:$ISFILE)"
               if [ "$ISFILE" = "0" ]
               then  printf "%*s%s" $((INDENT+4)) '' "<li>"
                     walk "$ITEM" $((INDENT+4))
               else F=`echo "$ITEM" | rev | #
                       cut -d "/" -f 1 | rev`
                    printf "%*s%s\n" $((INDENT+4)) '' "<li>$F</li>"
               fi
           done
           printf "%*s%s\n" $((INDENT)) '' "</ul>"
           printf "%*s%s\n" $((INDENT)) '' "</li>"
  }
# --------------------------------------------------------------------------- #
  for REPO in `grep -m 1 -h '^GITURL' $SRCPATH/*/*.txt | #
               sed 's,raw/[0-9a-f]\{7\},\nX,'          | #
               grep "^GITURL" | cut -d ":" -f 2-       | #
               sort -u`
   do
       REPOID=`echo $REPO | md5sum | cut -c 1-8`
    #  ----
       grep -m 1 -h "^GITURL:$REPO" $SRCPATH/*/*.txt | #
       cut -d ":" -f 2- | sed "s,^${REPO}raw/[0-9a-f]*/,," > ${TMP}.list
    #  ----
      (IFS=$'\n'
       for ITEM in `cat ${TMP}.list`
        do TID=`echo $ITEM | cut -d " " -f 1 | #
                md5sum | cut -c 1-32`
           ITEMPATH=`echo $ITEM | rev | #
                     cut -d "/" -f 2- | #
                     rev`
           sed -i "s,$ITEM,$ITEMPATH/${TID}.item," ${TMP}.list

       done;)
    #  ----
       if [ -f "${TMP}.tree" ];then rm ${TMP}.tree;fi

       for THIS in `cat ${TMP}.list | #
                    cut -d "/" -f 1 | #
                    sort -u`
        do walk $THIS >> ${TMP}.tree
       done
    #  ----
       grep -m 1 "^GITURL:$REPO" $SRCPATH/*/*.txt        | #
       sed "s,^$SRCPATH/\([0-9a-f]\{6\}\)/\(.*\),\2:\1," | #
       sed "s,\([0-9]\{12\}\)\(.*\),\2:\1,"              | #
       sed "s,^\.txt:GITURL:${REPO}raw/[0-9a-f]*/,,"     | #
       sort -t ' ' -k 1,1 > ${TMP}.items
    #  ----
       for F in `cat ${TMP}.items | cut -d ":" -f 1 | sort -u` 
        do FID=`echo $F | cut -d ":" -f 1 | #
                md5sum | cut -c 1-32`
           NAME=`echo $F | cut -d ":" -f 1  | #
                 rev | cut -d "/" -f 1 | rev` #
           HREF="";CNT=1
           for V in `grep "^$F" ${TMP}.items`
            do SID=`echo $V | cut -d ":" -f 2`
               VID=`echo $V | cut -d ":" -f 3`
               URL=`echo $URLPATTERN       | #
                    sed "s,%SRCID%,$SID,"  | #
                    sed "s,%VERSION%,$VID,"` #
               HREF="$HREF<a href=\"$URL\">[$CNT]<\/a>"
               CNT=`expr $CNT + 1`
           done
           HREF="<span><a href=\"$URL\">$NAME</a></span><span>$HREF</span>"
           sed -i "s,${FID}\.item,$HREF," ${TMP}.tree
       done
    #  ---- 
       UL="<ul id=\"$REPOID\" class=\"tree\">"
       echo "<h1 class=\"tree\">$REPO</h1>"      >  ${SRCPATH}/${REPOID}.tree
       sed "1s/^.*$/$UL\n<li>&/" ${TMP}.tree   | #
       sed 's/\(^[ ]*\)\(<li>\)\([ ]*\)/\1\2/' | #
       sed '$s/^<\/li>$/&\n<\/ul>\n\n/'          >> ${SRCPATH}/${REPOID}.tree
       sed -i '/^[ ]*$/d'                           ${SRCPATH}/${REPOID}.tree
  done
# --------------------------------------------------------------------------- #
  if [ `echo ${TMP} | wc -c` -ge 4 ] &&
     [ `ls ${TMP}*.* 2>/dev/null | wc -l` -gt 0 ]
  then  rm ${TMP}*.* ;fi
# --------------------------------------------------------------------------- #

exit 0;
