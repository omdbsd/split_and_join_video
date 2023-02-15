#!/bin/bash

readarray -t line_arr <$1
line_len=${#line_arr[*]}
line_i=0
while(( $line_i<$line_len ))
do
        line=${line_arr[line_i]}
	echo "$line"


        arr=(${line//,/ }) 
        len=${#arr[*]}
        echo "length of arr: $len"
    
	select_str=""
	basename=${arr[0]};
	extension="${basename##*.}"
	filename="${basename%.*}"

        if [ $len -lt 2 ]; then
             echo "error"
        else
	     echo "len is greater than or equal to 2"
             i=1
             while(( $i<$len ))
             do
		 ti=${arr[i]}
		 clip_time_arr=(${ti//-/ })
                 begin=$(echo ${clip_time_arr[0]} | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
        	 end=$(echo ${clip_time_arr[1]} | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
		 if [ $i -eq 1 ]; then
			 select_str="between(t,"$begin","$end")"
		 else
			 select_str=$select_str"+between(t,"$begin","$end")"
		 fi
                 let "i++";
             done
        fi

        echo $select_str
	
	if [ $2 -eq 1 ]; then
	    echo "ffmpeg -i $basename -vf \"select='$select_str',setpts=N/FRAME_RATE/TB\" -af \"aselect='$select_str',asetpts=N/SR/TB\" -nostdin ${filename}_clip.$extension"
	else
            ffmpeg -i $basename -vf "select='$select_str',setpts=N/FRAME_RATE/TB" -af "aselect='$select_str',asetpts=N/SR/TB" -nostdin ${filename}_clip.$extension
	fi

        let "line_i++";
done

