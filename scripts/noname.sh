#!/bin/bash
# ¯\_(ツ)_/¯
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	noname.sh
#
# @author skletz
# @version 1.0 28/12/2017
# -----------------------------------------------------------------------------
# @TODO:
# @NOTE:
# time bash noname.sh ../data/output/test_smoke/study_video3.mp4.csv  ../data/sql/test_smoke/autoLabels ../data/sql/test_smoke/autoFilters ../data/sql/test_smoke/autoClassification smoke "dbname -uUsername -pPassword"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# needed for printf - otherwise there is an error with invalid format
export LC_NUMERIC="en_US.UTF-8"

#Input-Output Files
csvfile=$1
output1=$2
output2=$3
output3=$4
indicator=$5
mysqlparam=$6

labelfile=$output1"_"$indicator".sql";
filterfile=$(dirname $output2)"/"$(basename $csvfile)"_"$(basename $output2)"_"$indicator".sql";
classificaitonfile=$(dirname $output3)"/"$(basename $csvfile)"_"$(basename $output3)"_"$indicator".sql";
sleep 10

echo "File to process: " $csvfile;
echo "Generate File 1: " $labelfile;
echo "Generate File 2: " $filterfile;
echo "Generate File 3: " $classificaitonfile;
echo "Indicator: " $indicator
echo "MySQL Param: " $mysqlparam

classificationId=1
# Check if it is possible to check mysql entries, otherwise classificationId starts with 1
if [ ! -z "$mysqlparam" ]
then
  echo "MySQL is possible"
  # Get the number of entries in order to get the starting ID for the classifications
  classificationId=`mysql $mysqlparam -s -e "select count(*) from autoClassifications;"`
  echo "Number of entries in tabel autoClassifications " $classificationId
  let classificationId=classificationId+1;
fi

# Remove older files for debugging mode
rm $classificaitonfile
rm $labelfile
rm $filterfile

files=("$labelfile" "$filterfile" "$classificaitonfile")

for element in "${files[@]}"
do
  echo "use ecat;" >> $element
done

# Prepare labels for insertion
# Init label maps
map_labelNames=("smoke" "no smoke")
map_labelIDs=()

# Check if it is possible to check mysql entries, otherwise labelId starts with 1
labelId=1
if [ ! -z "$mysqlparam" ]
then
  # Check if the labels already exists in the database
  isInTabel=`mysql $mysqlparam -s -e "select labelName from autoLabels where labelName = '${map_labelNames[0]}'"`
  if [ -z "$isInTabel" ]
  then
    # Get the last Id from mySQL
    labelId=`mysql $mysqlparam -s -e "select count(*) from autoLabels;"`
    echo "Number of Entries in tabel autoLabels " $labelId
    let labelId=labelId+1;
  else
    labelId=`mysql $mysqlparam -s -e "select labelId from autoLabels where labelName = '${map_labelNames[0]}'"`
    echo "LabelId of ${map_labelNames[0]} in autoLabels is" $labelId
  fi
fi

sleep 1

# Prepare initial statments for classifications and filters
echo "INSERT INTO \`autoClassifications\` (\`classificationId\`, \`videoName\`, \`timecode\`) VALUES " >> $classificaitonfile;
echo "INSERT INTO \`autoFilters\` (\`classificationId\`, \`labelId\`, \`prediction\`, \`avgPrediction\`) VALUES " >> $filterfile;
# Prepare initial statments for labels
echo "INSERT INTO \`autoLabels\` (\`labelId\`, \`labelName\`, \`modelName\`) VALUES " >> $labelfile;
tLen=${#map_labelNames[@]}
let lastElem=tLen-1
let lId=labelId;
# Insert values
for (( i=0; i<${tLen}; i++ ));
do
  # Last elements ends with ";"
  if [ "$i" -eq "$lastElem" ]
  then
    echo "($lId, '${map_labelNames[$i]}', 'GoogleNet'); " >> $labelfile
  else
    echo "($lId, '${map_labelNames[$i]}', 'GoogleNet'), " >> $labelfile
  fi

  # add id to label maps
  map_labelIDs+=("$lId")
  let lId=lId+1;
done

echo "Label Names: ${map_labelNames[@]}"
echo "Label Ids: ${map_labelIDs[@]}"

# Process the input file
# Copy old delimiter - restore it at the end
OLDIFS=$IFS
# Delimiter
IFS=";"

# used to find the last element which ends with ";"
iterationCnt=0
# How many labels, new ClassificationId after each labelCnt'th line
labelCnt=$tLen

# Get the number of lines to know the last line in the file
lineCnt=$(< $csvfile wc -l)
pairCnt=$(< $csvfile wc -l)

classId=$classificationId;
classIdCnt=1;

echo "Number of Labels: " $labelCnt
echo "Start with label Id: " $labelId
echo "Start with classification Id: " $classId
echo "Number of Lines: " $lineCnt " in " $csvfile
let lineCnt=lineCnt-1
sleep 1

# TODO: set false in production env
debugmode=true;

# memorize avgPrecision for pre labels and post Labels
seconds=1.0
cpCsvfile=$csvfile

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

now=$(date '+%d/%m/%Y %H:%M:%S');
echo "Script started: $now";

timecounter=0
# Loop through the file
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read flname w h fps fcnt fnr tcode label prec
do
  pStart=$(microtime)

  # Check condition for continue or break
  # If it is the first line, then skip it, contains only the header.
  if [ $iterationCnt -eq 0 ]
  then
    # echo "Skip first line (Headers) ..."
    let iterationCnt=iterationCnt+1
    continue;
  fi

  # If the variable is empty, then the whole line is empty, therefore no values to insert
  if [ -z "$flname" ]; then
    break;
  fi
    # Check if a new pair start
    #echo "Iteration count: $iterationCnt"

    #progress

  if [ $(( $iterationCnt % $labelCnt)) -eq 0 ]
  then
    let nextPairNr=iterationCnt+labelCnt-1
    if [ $nextPairNr -eq $pairCnt ]
    then
      echo "($classId, '$flname', $tcode);"  >> $classificaitonfile
      #echo "Values to insert as classification: ($classId, '$flname', $tcode);"
    else
      echo "($classId, '$flname', $tcode),"  >> $classificaitonfile
      #echo "Values to insert as classification: ($classId, '$flname', $tcode),"
    fi

      let classIdCnt=classIdCnt+1
      # echo "New pair: Increment classification Id count to " $classIdCnt
  fi

  # echo "Current label:" $label
  # echo "Precision of the label : $prec"

  # Insert values into the filter file
  intervall=$(echo "$labelCnt * $seconds * $fps" | bc)
  intervall=$(echo $intervall | awk '{print ($0-int($0)<0.499)?int($0):int($0)+1}')
  lnLen=${#map_labelNames[@]}
  for (( i=0; i<${lnLen}; i++ ));
  do
    #if the current label is found
    if [[ "${map_labelNames[$i]//[$' \t\n\r']/}" == "${label//[$' \t\n\r']/}" ]]
    then
      # echo "Label Count: " $labelCnt
      # echo "Seconds: " $seconds
      # echo "Fps: " $fps

      previous=$(echo "$iterationCnt - $intervall" | bc)
      next=$(echo "$iterationCnt + $intervall" | bc)

      # echo "Iteration Nr: " $iterationCnt
      # echo "Intervall: " $intervall
      # echo "Look at: " $(echo "$next - $previous" | bc)

      if [[ ! $previous -gt 0 ]]; then
        let previous=2
        # echo "Previous is smaller, Now: " $previous
      fi

      if [[ $next -gt $lineCnt ]]; then
        let next=lineCnt
        # echo "Next is bigger, Now: " $next
      fi

      sumPrediction=0.0
      sublineCnt=0

      # echo "COMMAND: "
      # echo "tail -n +"$previous" $cpCsvfile"
      # echo "head -"$((next - previous))""
      # echo "-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*"
      while read flname2 w2 h2 fps2 fcnt2 fnr2 tcode2 label2 prec2
      do
        if [[ "${label//[$' \t\n\r']/}" == "${label2//[$' \t\n\r']/}" ]]
        then
          # echo "Works ..."
          # echo "Name : $flname2"
          # echo "TimeCode : $tcode2"
          # echo "Label : $label2"
          # echo "Precision : $prec2"

          sumPrediction=$(echo "$sumPrediction + $prec2" | bc -l)

          let sublineCnt=sublineCnt+1
          # echo "Summed Prediciton: " $sumPrediction
          # echo "Subline Count: " $sublineCnt
        fi
      done < <(tail -n +"$previous" $cpCsvfile | head -"$((next - previous))");

      avgPrediction=$(echo "$sumPrediction / $sublineCnt" | bc -l )
      # echo "Average Prediciton: " $avgPrediction
      avgPrediction=$(printf '%.7f' $avgPrediction)

      #echo "Average Prediciton: " $avgPrediction
      #echo "-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*-/-*"
      #sleep 3

      prec=$(printf '%.7f' $prec)

      if [ $iterationCnt -eq $lineCnt ]
      then
        echo "($classId, ${map_labelIDs[$i]}, $prec, $avgPrediction);"  >> $filterfile
        #echo "Values to insert as filter: ($classId, ${map_labelIDs[$i]}, $prec, $avgPrediction);"
      else
        echo "($classId, ${map_labelIDs[$i]}, $prec, $avgPrediction),"  >> $filterfile
        #echo "Values to insert as filter: ($classId, ${map_labelIDs[$i]}, $prec, $avgPrediction),"
      fi
    fi
  done

  if [ "$classIdCnt" == "$labelCnt" ]
  then
      # echo "Increment ClassID to $classId "
      let classIdCnt=1
      let classId=classId+1
  fi

  let iterationCnt=iterationCnt+1


pEnd=$(microtime)
DIFF=$(echo "$pEnd - $pStart" | bc)
ShowProgress ${iterationCnt} ${lineCnt} ${DIFF} $iterationCnt $lineCnt

done < $csvfile
IFS=$OLDIFS

now=$(date '+%d/%m/%Y %H:%M:%S');
echo "Script finised: $now";

# Insert only if mysql option is possible
if [ ! -z "$mysqlparam" ]
then
  if [ -z "$isInTabel" ]
  then
    mysql $mysqlparam < $labelfile
  fi

  mysql $mysqlparam < $classificaitonfile
  mysql $mysqlparam < $filterfile
fi
