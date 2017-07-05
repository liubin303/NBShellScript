#!/bin/sh

#  check_unused_class.sh
#  Taobao4iPad
#
#  Created by Whirlwind on 15/7/17.
#  Copyright (c) 2015年 Taobao.com. All rights reserved.

if bash -l -c type fui >/dev/null; then
    UNUSED_CLASSES=`bash -l -c fui --path="${SRCROOT}" find`
    if [ -z "$UNUSED_CLASSES" ]
    then
        echo No unused imports
    else
        while read line;
        do
            echo $line:1:1: warning: Unused import
        done <<< "$UNUSED_CLASSES"
    fi
else
    echo "fui is not installed. Skip." >&2
fi
