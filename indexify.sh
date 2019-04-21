#!/bin/bash

  SRCPATH="_"
  TMPDIR="/tmp";TMP="$TMPDIR/tmp"

# --------------------------------------------------------------------------- #
  # https://askubuntu.com/questions/962170
  walk() { local INDENT="${2:-0}"
           D=`echo "$1" | rev | #
              cut -d "/" -f 1 | #
              rev`              #
           printf "%*s%s\n" $INDENT '' "$D"
           printf "%*s%s\n" $INDENT '' "<ul>"
           for ITEM in `grep $1 ${TMP}.items | #
                        sed "s,\(^$1/[^/]*/\)\(.*\),\1," | #
                        sort -u | sed 's,/$,,'`
            do
               ISFILE=`echo $ITEM | egrep "\.[0-9a-z]{2,10}$" | wc -l`
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
   do  grep -m 1 "^GITURL:$REPO" $SRCPATH/*/*.txt        | #
       sed "s,^$SRCPATH/\([0-9a-f]\{6\}\)/\(.*\),\2 \1," | #
       sed "s,\([0-9]\{12\}\)\(.*\),\2 \1,"              | #
       sed "s,^\.txt:GITURL:${REPO}raw/[0-9a-f]*/,,"     | #
       sort -t' ' -k 1,1 | #
       cut -d " " -f 1 > ${TMP}.items

       if [ -f "${TMP}.tree" ];then rm ${TMP}.tree;fi

       for THIS in `cat ${TMP}.items | #
                    cut -d "/" -f 1  | #
                    sort -u`
        do
            walk $THIS >> ${TMP}.tree
       done

       cat ${TMP}.tree  | #
       sed '1s/^.*$/<ul>\n<li>&/'                | #
       sed 's/\(^[ ]*\)\(<li>\)\([ ]*\)/\1\2/' | #
       sed '$s/^<\/li>$/&\n<\/ul>\n\n/'
 
  done
# --------------------------------------------------------------------------- #


exit 0;

