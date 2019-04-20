#!/bin/bash

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

