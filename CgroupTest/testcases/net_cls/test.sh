#!/bin/bash

echo $#

a=(1 2 3 4)

function test()
{
    local x
    eval x=(\${$1[@]})
    echo ${x[@]}
    echo ${#x[@]}
    return 0
}

! test a && echo lala || echo qweqwe
