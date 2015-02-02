#!/bin/bash

function MaskToNumber()
{
    local MASK_A=`echo $1 | awk -F . '{print $1}'`
    local MASK_B=`echo $1 | awk -F . '{print $2}'`
    local MASK_C=`echo $1 | awk -F . '{print $3}'`
    local MASK_D=`echo $1 | awk -F . '{print $4}'`
    
    if [ ${MASK_D} -ne 0 ]
    then
        local TMP=$(echo "obase=2;${MASK_D}" | bc | grep -o "1" | wc -l)
        echo $((TMP+24))
    elif [ ${MASK_C} -ne 0 ]
    then
        local TMP=$(echo "obase=2;${MASK_C}" | bc | grep -o "1" | wc -l)
        echo $((TMP+16))
    elif [ ${MASK_B} -ne 0 ]
    then
        local TMP=$(echo "obase=2;${MASK_B}" | bc | grep -o "1" | wc -l)
        echo $((TMP+8))
    elif [ ${MASK_A} -ne 0 ]
    then
        local TMP=$(echo "obase=2;${MASK_A}" | bc | grep -o "1" | wc -l)
        echo ${TMP}
    fi
}
