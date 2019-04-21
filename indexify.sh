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
               sort -u | head -n 2 | tail -n 1`
   do  grep -m 1 "^GITURL:$REPO" $SRCPATH/*/*.txt        | #
       sed "s,^$SRCPATH/\([0-9a-f]\{6\}\)/\(.*\),\2 \1," | #
       sed "s,\([0-9]\{12\}\)\(.*\),\2 \1,"              | #
       sed "s,^\.txt:GITURL:${REPO}raw/[0-9a-f]*/,,"     | #
       sort -t' ' -k 1,1 | #
       cut -d " " -f 1 > ${TMP}.items
 
       for THIS in `cat ${TMP}.items | #
                    cut -d "/" -f 1  | #
                    sort -u`
        do
            walk $THIS
       done
 
  done
# --------------------------------------------------------------------------- #

exit 0;






  TMP="dev"

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
  cd "$1"
  walk "E"
  cd - > /dev/null


exit 0;





  SRCPATH="_"
  TMPDIR="/tmp";TMP="$TMPDIR/tmp"
# --------------------------------------------------------------------------- #
# https://askubuntu.com/questions/962170
  walk() { local INDENT="${2:-0}"
           D=`echo "$1" | rev | #
              cut -d "/" -f 1 | #
              rev`              #
          #printf "%*s%s\n" $INDENT '' "$D"
          #printf "%*s%s\n" $INDENT '' "<ul>"

           for ITEM in "$1"
            do 
               ISFILE=`echo $ITEM | egrep "\.[0-9a-z]{2,10}$" | wc -l`
               echo "$ITEM (ISFILE:$ISFILE)"
               if [ "$ISFILE" == "0" ]
               then #printf "%*s%s" $((INDENT+4)) '' "<li>"
                    #walk "$ITEM" $((INDENT+4))
               #else F=`echo "$ITEM" | rev | #
               #        cut -d "/" -f 1 | #
               #        rev`
               #     #printf "%*s%s\n" $((INDENT+4)) '' "<li>$F</li>"
               fi

           done
          #printf "%*s%s\n" $((INDENT)) '' "</ul>"
          #printf "%*s%s\n" $((INDENT)) '' "</li>"
  }
# --------------------------------------------------------------------------- #
  for REPO in `grep -m 1 -h '^GITURL' $SRCPATH/*/*.txt | #
               sed 's,raw/[0-9a-f]\{7\},\nX,'          | #
               grep "^GITURL" | cut -d ":" -f 2-       | #
               sort -u | head -n 2 | tail -n 1`
   do  grep -m 1 "^GITURL:$REPO" $SRCPATH/*/*.txt        | #
       sed "s,^$SRCPATH/\([0-9a-f]\{6\}\)/\(.*\),\2 \1," | #
       sed "s,\([0-9]\{12\}\)\(.*\),\2 \1,"              | #
       sed "s,^\.txt:GITURL:${REPO}raw/[0-9a-f]*/,,"     | #
       sort -t' ' -k 1,1 | #
       cut -d " " -f 1 > ${TMP}.items
 
#echo `cat ${TMP}.items`
#echo "--"

       for THIS in `cat ${TMP}.items | #
                    cut -d "/" -f 1  | #
                    sort -u`
        do
           walk $THIS

       done 

 
  done
# --------------------------------------------------------------------------- #

exit 0;




  SRCPATH="_"
  TMPDIR="/tmp";TMP="$TMPDIR/tmp"
# --------------------------------------------------------------------------- #
# https://askubuntu.com/questions/962170
  walk() { local INDENT="${2:-0}"
           D=`echo "$1" | rev | #
              cut -d "/" -f 1 | #
              rev`              #
          #printf "%*s%s\n" $INDENT '' "$D"
          #printf "%*s%s\n" $INDENT '' "<ul>"
echo $*
           for ITEM in "$1"
            do 
               ISFILE=`echo $ITEM | egrep "\.[0-9a-z]{2,10}$" | wc -l`
               echo "$ITEM (ISFILE:$ISFILE)"
               if [ "$ISFILE" == "0" ]
               then #printf "%*s%s" $((INDENT+4)) '' "<li>"
                    echo $ITEM
                   #walk "$ITEM" $((INDENT+4))
               #else F=`echo "$ITEM" | rev | #
               #        cut -d "/" -f 1 | #
               #        rev`
               #     #printf "%*s%s\n" $((INDENT+4)) '' "<li>$F</li>"
               fi

           done
          #printf "%*s%s\n" $((INDENT)) '' "</ul>"
          #printf "%*s%s\n" $((INDENT)) '' "</li>"
  }
# --------------------------------------------------------------------------- #
  for REPO in `grep -m 1 -h '^GITURL' $SRCPATH/*/*.txt | #
               sed 's,raw/[0-9a-f]\{7\},\nX,'          | #
               grep "^GITURL" | cut -d ":" -f 2-       | #
               sort -u | head -n 2 | tail -n 1`
   do  grep -m 1 "^GITURL:$REPO" $SRCPATH/*/*.txt        | #
       sed "s,^$SRCPATH/\([0-9a-f]\{6\}\)/\(.*\),\2 \1," | #
       sed "s,\([0-9]\{12\}\)\(.*\),\2 \1,"              | #
       sed "s,^\.txt:GITURL:${REPO}raw/[0-9a-f]*/,,"     | #
       sort -t' ' -k 1,1 | #
       cut -d " " -f 1 > ${TMP}.items
 
#echo `cat ${TMP}.items | sed 's/$/X/g'`
#echo "--"

       walk `cat ${TMP}.items` #> ${TMP}.tree

 
 
   echo
  done
# --------------------------------------------------------------------------- #

exit 0;



 TMPDIR="/tmp";TMP="$TMPDIR/tmp"

 # https://askubuntu.com/questions/962170
 walk() { local INDENT="${2:-0}"
          DIR=`echo "$1" | rev | #
               cut -d "/" -f 1 | #
               rev`              #
         #printf "%*s%s\n" $INDENT '' "$DIR"
         #printf "%*s%s\n" $INDENT '' "<ul>"

          for THIS in "$1"/*
           do #echo "$THIS"
              ISAFILE=`echo "$THIS"          | #
                       egrep "\.[0-9a-z]{2,10}$" | #
                       sed 's/^.*/YES/'`   #
              echo "$THIS $ISAFILE"

              if [ "$ISAFILE" == "YES" ]
              then echo "$THIS $ISAFILE"
                   F=`echo "$THIS" | rev | #
                      cut -d "/" -f 1 | #
                      rev`
#                  #printf "%*s%s\n" $((INDENT+4)) '' "<li>$F</li>"
              else #printf "%*s%s" $((INDENT+4)) '' "<li>"
                   walk "$THIS" $((INDENT+4))              
#             
              fi

          done
         #printf "%*s%s\n" $((INDENT)) '' "</ul>"
         #printf "%*s%s\n" $((INDENT)) '' "</li>"
 }

 cd "$1"
 walk "." > ${TMP}.tree
 cd - > /dev/null

 cat ${TMP}.tree | sed '1s/^\.$//'       | #
 sed 's/\(^[ ]*\)\(<li>\)\([ ]*\)/\1\2/' | #
 sed '$s/^<\/li>$//'


exit 0;


 TMPDIR="/tmp";TMP="$TMPDIR/tmp"

 # https://askubuntu.com/questions/962170
 walk() { local INDENT="${2:-0}"
          DIR=`echo "$1" | rev | #
               cut -d "/" -f 1 | #
               rev`              #
          printf "%*s%s\n" $INDENT '' "$DIR"
          printf "%*s%s\n" $INDENT '' "<ul>"
          for THIS in "$1"/*
           do if [ -d "$THIS" ]
              then printf "%*s%s" $((INDENT+4)) '' "<li>"
                   walk "$THIS" $((INDENT+4))
              else F=`echo "$THIS" | rev | #
                      cut -d "/" -f 1 | #
                      rev`
                   printf "%*s%s\n" $((INDENT+4)) '' "<li>$F</li>"
              fi
          done
          printf "%*s%s\n" $((INDENT)) '' "</ul>"
          printf "%*s%s\n" $((INDENT)) '' "</li>"
 }

 cd "$1"
 walk "." > ${TMP}.tree
 cd - > /dev/null

 cat ${TMP}.tree | sed '1s/^\.$//'       | #
 sed 's/\(^[ ]*\)\(<li>\)\([ ]*\)/\1\2/' | #
 sed '$s/^<\/li>$//'

exit 0;

 # https://askubuntu.com/questions/962170
 walk() { local INDENT="${2:-0}"
          DIR=`echo "$1" | rev | #
               cut -d "/" -f 1 | #
               rev`
          printf "%*s%s\n" $INDENT '' "$DIR"
          for THIS in "$1"/*
           do if [ -d "$THIS" ]
              then walk "$THIS" $((INDENT+4))
              else F=`echo "$THIS" | rev | #
                      cut -d "/" -f 1 | #
                      rev`
                   printf "%*s%s\n" $((INDENT+4)) '' "$F"
              fi
          done
 }

 cd "$1"
 walk "."
 cd - > /dev/null

exit 0;

 # https://askubuntu.com/questions/962170
 walk() { local indent="${2:-0}"
          printf "%*s%s\n" $indent '' "$1"
          for entry in "$1"/*; do
                  [[ -d "$entry" ]] && walk "$entry" $((indent+4))
          done
 }
 walk "$1"

exit 0;

  SRCPATH="_"
  TMPDIR="/tmp";TMP="$TMPDIR/tmp"

  for REPO in `grep -m 1 -h '^GITURL' $SRCPATH/*/*.txt | #
               sed 's,raw/[0-9a-f]\{7\},\nX,'          | #
               grep "^GITURL" | cut -d ":" -f 2-       | #
               sort -u`
   do  grep -m 1 "^GITURL:$REPO" $SRCPATH/*/*.txt        | #
       sed "s,^$SRCPATH/\([0-9a-f]\{6\}\)/\(.*\),\2 \1," | #
       sed "s,\([0-9]\{12\}\)\(.*\),\2 \1,"              | #
       sed "s,^\.txt:GITURL:${REPO}raw/[0-9a-f]*/,,"     | #
       sort -t' ' -k 1,1 > ${TMP}.list

       for D in `cat ${TMP}.list | cut -d " " -f 1 | #
                 rev | cut -d "/" -f 2- | rev | sed 's,/,\n,g' | sort -u`
        do
             egrep "$D/[^ ]*" ${TMP}.list
             echo
       done

#     (IFS=$'\n';
#      for F in `grep -m 1 "^GITURL:$REPO" $SRCPATH/*/*.txt        | #
#                sed "s,^$SRCPATH/\([0-9a-f]\{6\}\)/\(.*\),\2 \1," | #
#                sed "s,\([0-9]\{12\}\)\(.*\),\2 \1,"              | #
#                sed "s,^\.txt:GITURL:${REPO}raw/[0-9a-f]*/,,"     | #
#                sort -t' ' -k 1,1`
#       do
#             echo $F
#
#      done;)
   echo
  done

exit 0;

