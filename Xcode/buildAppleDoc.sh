#!/bin/bash

cur_dir=$(pwd)
#通用参数
projectName=$(echo $(basename $cur_dir))
company="WanDa";
companyID="com.wanda";
companyURL="http://www.ffan.com/";
target="iphoneos";
documentPath=../Doc

#创建doc路径
if [ ! -d $documentPath ]; then
    mkdir $documentPath
fi

for dirlist in $(ls ${cur_dir})
do
    if test -d ${dirlist}; then
        #文档输出路径
        outputPath=$documentPath/$(echo $(basename $dirlist));

        #创建输出路径
        if [ ! -d $outputPath ]; then
            mkdir $outputPath
        fi

        /usr/local/bin/appledoc \
        --no-create-docset  \
        --project-name "${dirlist}" \
        --project-company "${company}" \
        --company-id "${companyID}" \
        --output "$documentPath/$(echo $(basename $dirlist))" \
        ${dirlist}

    fi
done

