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
i

 # https://askubuntu.com/questions/962170
 walk() { local INDENT="${2:-0}"
          DIR=`echo "$1" | rev | #
               cut -d "/" -f 1 | #
               rev`
          printf "%*s%s\n" $INDENT '' "$DIR"
          for E in "$1"/*
           do if [ -d "$E" ]
              then walk "$E" $((INDENT+4))
              else F=`echo "$E" | rev | #
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
          for E in "$1"/*; do
                  [[ -d "$E" ]] && walk "$E" $((indent+4))
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


  TMP="dev"

  e(){ echo $*; }



  e "<ul>"
  for THIS in `cat ${TMP}.list | #
               cut -d "/" -f 1 | #
               sort -u`          #
   do 
      NAME=`echo $THIS | rev | #
            cut -d "/" -f 1  | #
            rev`               #
      ISAFILE=`echo $THIS            | #
               egrep "\.[a-z]{2,4}$" | #
               sed 's/^.*/YES/'`       #
      while [ "$ISAFILE" != "YES" ]
       do



            ISAFILE=`echo $THIS            | #
                     egrep "\.[a-z]{2,4}$" | #
                     sed 's/^.*/YES/'`       #
      done


     #echo "$NAME"
      echo "$THIS ($ISAFILE)"


 


  done
  e "</ul>"



exit 0;






  ROOT="/home/christoph/2018"

  e(){ echo $*; }


# -
  e "<ul>"
# -
  for THIS in `ls "$ROOT" | sort`
   do 
       if [ -d "$ROOT/$THIS" ]
       then ISDIR="YES"
       else ISDIR="NO"
       fi
 
       NAME=`basename "$THIS"`
       echo "$NAME ($ISDIR)"
      #echo "  <li>$NAME</li>"


 


  done
# -
  e "</ul>"
# -


exit 0;





  ROOT="/home/christoph/SANDBOX"

  echo "<ul>"
  for D in `find "$ROOT" -maxdepth 1 \
                         -mindepth 1 \
                         -type d     | sort`
   do
      DNAME=`basename "$D"`
      echo "  <li>$DNAME</li>"


#     echo "  <ul>"
#     for F in `find "$D" -maxdepth 1 \
#                         -mindepth 1 \
#                         -type f     | sort`
#      do FNAME=`basename "$F"`
#         echo "    <li><a href=\"/$DNAME/$FNAME\">$F</a></li>"
#     done
#     echo "  </ul>"
 
  done
  echo "</ul>"


exit 0;



  ROOT="/home/christoph/SANDBOX"

  echo "<ul>"
  for DIRPATH in `find "$ROOT" -maxdepth 1 \
                               -mindepth 1 \
                               -type d     | sort`
   do
      DIRNAME=`basename "$DIRPATH"`
      echo "  <li>$DIRNAME</li>"


#     echo "  <ul>"
#     for I in `find "$DIRPATH" -maxdepth 1 \
#                               -mindepth 1 \
#                               -type f     | sort`
#      do FILE=`basename "$I"`
#         echo "    <li><a href=\"/$DIRNAME/$FILE\">$FILE</a></li>"
#     done
#     echo "  </ul>"
 
  done
  echo "</ul>"


exit 0;















# https://stackoverflow.com/questions/20275254
# -> bash-script-to-create-a-html-nav-menu#20304702

#preset variables, exec redirects everything to outputfile
ROOT="/data"
LABEL="foldername.txt"
MAXDEPTH=5
DEPTH=0
HTTP="http://www.somewhere.com"
exec > "$ROOT/Menu-test.html"

#functions for indentation, definition and printing tags
LI="<LI><SPAN class=plus><P>+</P></SPAN>"
ULecho() { Dent ; echo "<UL class='navlist$DEPTH'>"                    ;}
LIecho() { echo -n "$LI<A href='$HTTP${1/$ROOT/}/'>$( cat $LABEL)</A>" ;}
Indent() { for (( i=1 ; i < DEPTH ; ++i )); do Dent; Dent; done ; Dent ;}
Dent()   { echo -n "    "                                              ;}
LIstrt() { Indent; LIecho "$( pwd )" ; echo "</LI>"                    ;}
ULstrt() { Indent; LIecho "$( pwd )" ; echo; Indent; ULecho            ;}
TAGend() { Indent ; Dent ; echo "</UL>"; Indent; echo "</LI>"          ;}
DEPchk() { [ "$DEPTH" -gt "0" ] && ${1} ;}

:> $ROOT/$LABEL

Dive()
{
    local DPATH="$1"


    if [ "$( echo */$LABEL )" = "*/$LABEL" ] || [ $DEPTH -gt $MAXDEPTH ]
    then
        DEPchk LIstrt
    else
        DEPchk ULstrt
        for DPATH in */$LABEL
        do
            cd ${DPATH%/*}
              (( ++DEPTH ))
            Dive "$DPATH"
              (( --DEPTH ))
            cd ..
        done
        DEPchk TAGend
    fi
}

cd $ROOT
Dive "$ROOT"
echo "</UL>"

exit 0;


  TMP="dev"

  echo "<ul>"
  for DIRPATH in `egrep "/" ${TMP}.list | #
                  cut -d "/" -f 1 | sort | uniq`
   do
      DIRNAME="$DIRPATH"
      echo "  <li>$DIRNAME</li>"
      echo "  <ul>"
      for I in `egrep "${DIRPATH}/[^/]*\.[a-z]{2,4}$" ${TMP}.list`
       do
       #FILE=`basename "$I"`
        FILE=`echo "$I" | cut -d "/" -f 2`
        echo "    <li><a href=\"/$DIRNAME/$FILE\">$FILE</a></li>"
      done
      echo "  </ul>"

  done
  echo "</ul>"


exit 0;

  ROOT="."

  echo "<ul>"
  for DIRPATH in `find "$ROOT" -maxdepth 1 \
                               -mindepth 1 \
                               -type d     | sort`
   do
      DIRNAME=`basename "$DIRPATH"`
      echo "  <li>$DIRNAME</li>"
      echo "  <ul>"
      for I in `find "$DIRPATH" -maxdepth 1 \
                                -mindepth 1 \
                                -type f     | sort`
       do
        FILE=`basename "$I"`
        echo "    <li><a href=\"/$DIRNAME/$FILE\">$FILE</a></li>"
      done
      echo "  </ul>"
  done
  echo "</ul>"


exit 0;

# https://stackoverflow.com/questions/21395159
# -> shell-script-to-create-a-static-html-directory-listing

ROOT="."
HTTP="/"

i=0
echo "<UL>"
for filepath in `find "$ROOT" -maxdepth 1 -mindepth 1 -type d | sort`
 do
  path=`basename "$filepath"`
  echo "  <LI>$path</LI>"
  echo "  <UL>"
  for i in `find "$filepath" -maxdepth 1 -mindepth 1 -type f | sort`
   do
    file=`basename "$i"`
    echo "    <LI><a href=\"/$path/$file\">$file</a></LI>"
  done
  echo "  </UL>"
done
echo "</UL>"


exit 0;

   TMP="dev"

   sort ${TMP}.list  | #
   sed '/^[ \t]*$/d' | #
   egrep "\.[a-z]{2,4}" > ${TMP}.list.tmp
  
   INDENT="''"
   while [ `grep "/" ${TMP}.list.tmp | #
            wc -l` -gt 0 ]
    do      sed -i "s,/,$INDENT," ${TMP}.list.tmp
           #INDENT="${INDENT}''"
   done
  
   cat ${TMP}.list.tmp
   echo "----"

  (IFS=$'\n'
   for DIR in `cat ${TMP}.list.tmp | rev | #
               sed "s/[a-z]\{2,4\}\.[^']*//" | #
               rev | uniq | awk '{print length,$0}' | #
               sort -k2,2 -k1 | sed 's/^[0-9]* //'`
    do echo "$DIR"
       for F in `egrep "^${DIR}[^']*" ${TMP}.list.tmp | sed "s/^${DIR}//"`
        do echo "$F"
           sed -i "\,^${DIR}[^']*,s,^,:," ${TMP}.list.tmp

       done

  done;)



exit 0;



   TMP="dev"

   sort ${TMP}.list  | #
   sed '/^[ \t]*$/d' | #
   egrep "\.[a-z]{2,4}" > ${TMP}.list.tmp
  
   INDENT="''"
   while [ `grep "/" ${TMP}.list.tmp | #
            wc -l` -gt 0 ]
    do      sed -i "s,/,$INDENT," ${TMP}.list.tmp
           #INDENT="${INDENT}''"
   done
  
   cat ${TMP}.list.tmp
   echo "----"

  (IFS=$'\n'
   for DIR in `cat ${TMP}.list.tmp | rev | #
               sed "s/[a-z]\{2,4\}\.[^']*//" | #
               rev | uniq`
    do echo "DIR: $DIR"

       egrep "^${DIR}[^']*" ${TMP}.list.tmp | #
       sed "s/^${DIR}//" 
       sed -i "\,^${DIR}[^']*,s,^,:," ${TMP}.list.tmp

       echo "--"
  done;)

exit 0;



   TMP="dev"

   sort ${TMP}.list  | #
   sed '/^[ \t]*$/d' | #
   egrep "\.[a-z]{2,4}" > ${TMP}.list.tmp
  
   INDENT="  "
   while [ `grep "/" ${TMP}.list.tmp | #
            wc -l` -gt 0 ]
    do      sed -i "s,/,$INDENT," ${TMP}.list.tmp
            INDENT="$INDENT  "
   done
  
   cat ${TMP}.list.tmp
   echo "----"
  
  (IFS=$'\n';
   for D in `cat ${TMP}.list.tmp | #
             rev | sed 's/[a-z]\{2,4\}\.[^ ]*//' | #
             rev | uniq`
    do echo $D
       DRM="$D"      
       for L in `cat ${TMP}.list.tmp`
        do
           echo $L | sed "s/^$D/$DRM/"
           if [ `echo $L | grep $D | wc -l` -gt 0 ]
           then DRM=`echo $D | sed 's/./ /g'`; fi
       done
       echo "--"
   done;)



exit 0;


 
 TMP="dev"

   sort ${TMP}.list  | #
   sed '/^[ \t]*$/d' | #
   egrep "\.[a-z]{2,4}" > ${TMP}.list.tmp
  
   INDENT="  "
   while [ `grep "/" ${TMP}.list.tmp | #
            wc -l` -gt 0 ]
    do      sed -i "s,/,$INDENT," ${TMP}.list.tmp
            INDENT="$INDENT  "
   done
  
   cat ${TMP}.list.tmp
   echo "----"
  
  (IFS=$'\n';
   for D in `cat ${TMP}.list.tmp | #
             rev | sed 's/[a-z]\{2,4\}\.[^ ]*//' | #
             rev | uniq`
    do DRM="$D"      
       for L in `cat ${TMP}.list.tmp`
        do
           echo $L | sed "s/$D/$DRM/"
           if [ `echo $L | grep $D | wc -l` -gt 0 ]
           then DRM=`echo $D | sed 's/./ /g'`; fi
       done
       echo "--"
   done;)



exit 0;


 TMP="dev"
 sort ${TMP}.list | #
 sed '/^[ \t]*$/d' > ${TMP}.list.tmp

 INDENT="  "
 while [ `grep "/" ${TMP}.list.tmp | wc -l` -gt 0 ]
  do
     sed -i "s,/,\n$INDENT," ${TMP}.list.tmp
     INDENT="$INDENT  "
 done

 cat ${TMP}.list.tmp
 echo "----"

(IFS=$'\n';
 for D in `cat ${TMP}.list.tmp     | #
           egrep -v "\.[a-z]{2,4}" | #
           grep -n ""              | #
           sort -t ":" -k 2,2 -u   | #
           sort -n                 | #
           cut -d ":" -f 2-`
  do
     echo $D




 done;)


exit 0;

 TMP="dev"
 MAXDEPTH=`cat ${TMP}.list | sed 's,[^/],,g' | wc -L`

 C=1

 while [ $C -le $MAXDEPTH ]
  do SLASHS=$SLASHS"/"
     echo $SLASHS
     C=`expr $C + 1`     
 done 


exit 0;

 TMP="dev"
 MAXDEPTH=`cat ${TMP}.list | sed 's,[^/],,g' | wc -L`

 C=1

 while [ $C -le $MAXDEPTH ]
  do SLASHS=$SLASHS`printf "/%.0s" {1..100} | cut -c $C`
     echo $SLASHS
     C=`expr $C + 1`     
 done 



exit 0;

  SRCPATH="_"
  TMPDIR="/tmp";TMP="$TMPDIR/tmp"

  for REPO in `grep -m 1 -h '^GITURL' $SRCPATH/*/*.txt | #
               sed 's,raw/[0-9a-f]\{7\},\nX,'          | #
               grep "^GITURL" | cut -d ":" -f 2-       | #
               sort -u | grep bits`
   do  grep -m 1 "^GITURL:$REPO" $SRCPATH/*/*.txt        | #
       sed "s,^$SRCPATH/\([0-9a-f]\{6\}\)/\(.*\),\2 \1," | #
       sed "s,\([0-9]\{12\}\)\(.*\),\2 \1,"              | #
       sed "s,^\.txt:GITURL:${REPO}raw/[0-9a-f]*/,,"     | #
       sort -t' ' -k 1,1 > ${TMP}.list
   echo
  done

exit 0;




 TMP="dev"

 M=`cat ${TMP}.list | sed 's,[^/],,g' | wc -L`
 

 C=0;S="/"
 while [ $C -lt M ]
      do


         

    done
 




exit 0;

 M=`wc -l ${TMP}.list | #
    cut -d " " -f 1`    #

 C=0;while [ $C -lt M ]
      do
    done








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

