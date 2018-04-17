#!/bin/bash
# ¯\_(ツ)_/¯
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	.sh
#
# @author skletz
# @version 1.0 28/12/2017
# -----------------------------------------------------------------------------
# @TODO:
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#mysql -uecat -panno4ever < insert.sql
#mysql -uecat -panno4ever -vvv << eof
#use ecat;
#INSERT INTO autoClassifications (classificationId, videoName, timecode) VALUES (NULL, 'study_video1.mp4', 0.333);
#eof

classificaitonfile="insert-autoClassifications2.sql"
labelfile="insert-autoLabels.sql"
filterfile="insert-autoFilters2.sql"

rm $classificaitonfile
rm $labelfile
rm $filterfile

map_smoke=("smoke" "no smoke")
map_smokeLabelId=("1" "2")

echo "use ecat;" >> $classificaitonfile
echo "use ecat;" >> $labelfile
echo "use ecat;" >> $filterfile

echo "INSERT INTO \`autoClassifications\` (\`classificationId\`, \`videoName\`, \`timecode\`) VALUES " >> $classificaitonfile

echo "INSERT INTO \`autoLabels\` (\`labelId\`, \`labelName\`, \`modelName\`) VALUES " >> $labelfile
echo "(1, 'smoke', 'GoogleNet'), " >> $labelfile
echo "(2, 'no smoke', 'GoogleNet'); " >> $labelfile

echo "SET FOREIGN_KEY_CHECKS=0;" >> $filterfile
echo "INSERT INTO \`autoFilters\` (\`classificationId\`, \`labelId\`, \`prediction\`) VALUES " >> $filterfile

INPUT="/Users/skletz/Dropbox/Programming/PLAYGround/preClassifier/data/output/test_smoke/study_video3.mp4.csv"
#echo >> $INPUT


function ShowProgress {
  # Process data
      let _progress=(${1}*100/${2}*100)/100
      let _done=(${_progress}*4)/10
      let _left=40-$_done
  # Build progressbar string lengths
      _fill=$(printf "%${_done}s")
      _empty=$(printf "%${_left}s")

  # 1.2 Build progressbar strings and print the ProgressBar line
  # 1.2.1 Output example:
  # 1.2.1.1 Progress : [########################################] 100%
  printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%% Elapsed Time: ${3} (sec), Progressed Frame Nr: ${4} of ${5} frames"
}

# we need milliseconds - mac do not support bash time $(date +"%s.%N")
microtime() {
    python -c 'import time; print time.time()'
}
sleep 1
now=$(date '+%d/%m/%Y %H:%M:%S');
echo "Script started: $now";

OLDIFS=$IFS
IFS=";"
value=0
n=2
lineCnt=$(< $INPUT wc -l)
classId=1;
classIdCnt=1;

echo "Lines " $lineCnt
let lineCnt=lineCnt-1

iterationCnt=1
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read flname w h fps fcnt fnr tcode label prec
do
  #pStart=$(microtime)

  if [ -z "$flname" ]; then
    break;
  fi

  #echo "Iteration : $value"
  #echo "Insert: (NULL, '$flname', $tcode)"
  if [ $value -eq 0 ]
  then

    echo "Skip first line (Headers) ..."

  elif [ $value -eq $lineCnt ]
  then

    #echo "Last Line ..."
    #echo "Label:" $label
    #echo "Precision : $prec"
    labelId=0
    for element in "${map_smoke[@]}"
    do
      #echo "Element: " $element
      if [[ "${element//[$' \t\n\r']/}" == "${label//[$' \t\n\r']/}" ]]
      then
        #echo "true"
        echo "($classId, '${map_smokeLabelId[$labelId]}', $prec);"  >> $filterfile
      fi
      let labelId=labelId+1;
    done
    echo "($classId, '$flname', $tcode);"  >> $classificaitonfile

  else
    if [ $(( $value % $n )) -eq 0 ]
    then

        echo "($classId, '$flname', $tcode),"  >> $classificaitonfile
        let classIdCnt=classIdCnt+1
    fi

    #echo "Label:" $label
    #echo "Precision : $prec"
    labelId=0
    for element in "${map_smoke[@]}"
    do
      #echo "Element: " $element
      if [[ "${element//[$' \t\n\r']/}" == "${label//[$' \t\n\r']/}" ]]
      then
        #echo "true"
        echo "($classId, '${map_smokeLabelId[$labelId]}', $prec),"  >> $filterfile
      fi
      let labelId=labelId+1;
    done
  fi

  if [ "$classIdCnt" == "$n" ]
  then
      #echo "Increment ClassID to $classId "
      let classIdCnt=1
      let classId=classId+1
  fi

  #sleep 1

  #if [ $(( $value % $n )) -eq 0 ] ; then
      #echo "Name : $flname"
    	#echo "Width : $w"
    	#echo "Height : $h"
    	#echo "Fps : $fps"
      #echo "FrameCount : $fcnt"
      #echo "FrameNr : $fnr"
      #echo "TimeCode : $tcode"
      #echo "Label : $label"
      #echo "Precision : $prec"
      #sleep 1
      #echo "INSERT INTO autoClassifications (classificationId, videoName, timecode) VALUES (NULL, '$flname', $tcode);" | mysql -uecat -panno4ever ecat;
      #echo "(NULL, '$flname', $tcode),"  >> insert-autoClassifications.sql
  #fi
  let value=value+1


  #pEnd=$(microtime)
  #DIFF=$(echo "$pEnd - $pStart" | bc)
  # ShowProgress ${iterationCnt} ${lineCnt} ${DIFF}
  #$iterationCnt $lineCnt
  let iterationCnt=iterationCnt+1

done < $INPUT
IFS=$OLDIFS
echo "SET FOREIGN_KEY_CHECKS=1;" >> $filterfile
now=$(date '+%d/%m/%Y %H:%M:%S');
echo "Script finised: $now";

#mysql -uecat -panno4ever < insert-autoClassifications.sql
#mysql -uecat -panno4ever < insert-autoLabels.sql
#mysql -uecat -panno4ever < insert-autoFilters.sql
