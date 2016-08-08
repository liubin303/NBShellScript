#!/bin/bash
#--------------------------------------------
# 功能：编译sfht项目并打ipa包
# 使用说明：
#		编译project
#			build_ipa [-c <project configuration>] [-o <ipa output directory>]
#		编译workspace
#			build_ipa -w -s <schemeName> [-c <project configuration>] [-o <ipa output directory>]
# 参数说明：  
#		-c NAME				打包的configuration[beta,betapro,adhoc,appstore],默认为betapro。
#		-o PATH				生成的ipa文件输出的文件夹,默认为当前路径下的”build/ipa-build“文件夹中
#	    -w					编译workspace
#--------------------------------------------
# Bundle Identifier配置说明
# com.sfht.m.app                                                             ----- appstore/adhoc
# org.sfht.m.app                                                             ----- beta
#--------------------------------------------
# Code Signing Identity配置说明
# iPhone Distribution: S.F. IMPORT AND EXPORT COMPANY .LTD (MM34C5S88U)      ----- appstore/adhoc
# iPhone Distribution: S.F. IMPORT AND EXPORT COMPANY LIMITED                ----- beta
#--------------------------------------------
# Provisioning Profile配置说明
# name:SFHT_APPSTORE_DISTRIBUTION                                            ----- appstore
# name:SFHT_HOC_DISTRIBUTION                                                 ----- adhoc
# name:SFHTDistribution                                                      ----- beta 
#--------------------------------------------
# keychain证书配置说明
# MM34C5S88U.com.sfht.GenericKeychain                                        ----- appstore/adhoc
# Y2369R8QWB.com.sfht.GenericKeychain                                        ----- beta
#--------------------------------------------
# 极光推送配置说明
# APS_FOR_PRODUCTION=1  APP_KEY="842071bd7b50f03adbea0675"                   ----- appstore/adhoc
# APS_FOR_PRODUCTION=0  APP_KEY="15831d6de939e80073feba87"                   ----- beta 
#--------------------------------------------
# beta       企业证书测试环境测试包
# betapro    企业证书生产环境测试包
# adhoc      发布证书生产环境测试包
# appstore   发布证书生产环境发布包
#--------------------------------------------

function buildHelp() {
	echo "usage for project:"
	echo ".................... build_ipa_v2 [-c <project configuration>] [-o <ipa output directory>]"
	echo "usage for workspace:" 
	echo ".................... build_ipa_v2 -w -s <schemeName> [-c <project configuration>] [-o <ipa output directory>]"
    echo "parameter:"
    echo "-c NAME ............ 打包的configuration[beta,betapro,betapro,betahoc,adhoc,appstore],默认为$build_config"
    echo "-o PATH ............ 生成的ipa文件输出的文件夹,默认为/Users/$USER/Documents/"
    echo "-w ................. 编译workspace"
    echo "#--------------------------------------------"
    echo "# beta       企业证书测试环境测试包"
    echo "# betapro    企业证书生产环境测试包"
    echo "# betahoc    企业证书预发环境测试包"
    echo "# adhoc      发布证书生产环境测试包"
    echo "# appstore   发布证书生产环境发布包"
    echo "#--------------------------------------------"
}

#获取配置信息
function loadBuildConfig() {
    #编译workspace需要的参数
    workspaceName="sfhaitao"
    schemeName="sfhaitao"
    #需要编译的target
    targetName="sfhaitao"
    #ipa支持的系统版本
    deploymentTarget="7.0"
    #app的版本号
    appVersion="3.3.0"
    #H5的版本号
    hybirdVersion="3.3.0"
    #H5环境
    apiMobileH5=1
    case "$build_config" in
    "beta" )
            #bundle identifier
            bundleID="org.sfht.m.app"
            #app名字
            displayName="丰趣海淘测试"
            #签名证书
            codeSign="iPhone Distribution: S.F. IMPORT AND EXPORT COMPANY LIMITED"
            #配置文件
            profileName="SFHTDistribution"
            #钥匙串
            keychainAccess="Y2369R8QWB.com.sfht.GenericKeychain"
            #api环境
            apiHostEnvironment=2
            #debug值
            debugMode=1
            #极光推送环境
            pushEnvironment=0
            #极光推送appkey
            pushAppKey="539687da0434cb62b45e1bd6"
            #日志上传地址
            reportUploadServer="http://client-log.oss-cn-shanghai.aliyuncs.com/"
        ;;
    "betapro" )
            bundleID="org.sfht.m.app"
            displayName="丰趣海淘正式"
            codeSign="iPhone Distribution: S.F. IMPORT AND EXPORT COMPANY LIMITED"
            profileName="SFHTDistribution"
            keychainAccess="Y2369R8QWB.com.sfht.GenericKeychain"
            apiHostEnvironment=0
            debugMode=1
            pushEnvironment=0
            pushAppKey="539687da0434cb62b45e1bd6"
            reportUploadServer="http://client-log.oss-cn-shanghai.aliyuncs.com/"
        ;;
    "betahoc" )
            bundleID="org.sfht.m.app"
            displayName="丰趣海淘预发"
            codeSign="iPhone Distribution: S.F. IMPORT AND EXPORT COMPANY LIMITED"
            profileName="SFHTDistribution"
            keychainAccess="Y2369R8QWB.com.sfht.GenericKeychain"
            apiHostEnvironment=3
            debugMode=1
            pushEnvironment=0
            pushAppKey="539687da0434cb62b45e1bd6"
            reportUploadServer="http://client-log.oss-cn-shanghai.aliyuncs.com/"
    ;;
    "adhoc" )
            bundleID="com.sfht.m.app"
            displayName="丰趣海淘adhoc"
            codeSign="iPhone Distribution: S.F. IMPORT AND EXPORT COMPANY .LTD (MM34C5S88U)"
            profileName="SFHT_HOC_DISTRIBUTION"
            keychainAccess="MM34C5S88U.com.sfht.GenericKeychain"
            apiHostEnvironment=0
            debugMode=1
            pushEnvironment=1
            pushAppKey="842071bd7b50f03adbea0675"
            reportUploadServer="http://client-log.fengqucdn.com/"
        ;;
    "appstore" )
            bundleID="com.sfht.m.app"
            displayName="丰趣海淘"
            codeSign="iPhone Distribution: S.F. IMPORT AND EXPORT COMPANY .LTD (MM34C5S88U)"
            profileName="SFHT_APPSTORE_DISTRIBUTION"
            keychainAccess="MM34C5S88U.com.sfht.GenericKeychain"
            apiHostEnvironment=0
            debugMode=0
            pushEnvironment=1
            pushAppKey="842071bd7b50f03adbea0675"
            reportUploadServer="http://client-log.fengqucdn.com/"
        ;;
    esac
    #build需要的profile
    project_profile_path="ProvisioningProfiles/$profileName.mobileprovision"
    #计算profile的UUID
    profileUUID=`/usr/libexec/PlistBuddy -c 'Print UUID' /dev/stdin <<< $(security cms -D -i $project_profile_path)`
    xcode_profile_path="/Users/$USER/Library/MobileDevice/Provisioning Profiles/$profileUUID.mobileprovision"
    #拷贝profile
    cp -f "$project_profile_path" "$xcode_profile_path"
}

#修改plist文件
function modify_plist() {
    local OPTIND  #OPTIND初始值为1，其含义是下一个待处理的参数的索引,必须用local标记位局部变量，否则多次调用时无法重置
    parameter=":p:k:v:"  #参数列表，:表示有入参
    while getopts $parameter optName; do
        case "$optName" in
            "p" )
                plist_path=$OPTARG  #OPTARG是当getopts获取到其期望的参数后存入的位置。而如果不在其期望内，则$optname被设为?并将该意外值存入
                ;;
            "k" )
                key=$OPTARG               
                ;;
            "v" )
                value=$OPTARG
                ;;
            "?" )
            echo "Error! Unknown parameter $OPTARG"
            exit 2
            ;;
            ":" )
            echo "Error! No argument value for parameter $OPTARG"
            exit 2
            ;;
            * )
            echo "Error! Unknown error while processing options"
            exit 2
            ;; 
        esac
    done
    if [[ -e $plist_path  ]]; then
        /usr/libexec/Plistbuddy -c "Set $key $value" "$plist_path"
    else
        echo "Error!$plist_path file not found.Please check."
        exit 2
    fi
}

#获取当前工程路径
project_path=$(dirname $0)
project_path=${project_path/\./$(pwd)}
#编译的configuration，默认为betapro
build_config=betapro
#可用参数列表
param_pattern=":c:o:ws:h"
#处理参数
while getopts $param_pattern optName
do
    case "$optName" in
        "c" )
            build_config=$OPTARG
            ;;
        "o" )
            build_out_path=$OPTARG
            ;;
        "w" )
            workspace_name='*.xcworkspace'
            ls $project_path/$workspace_name &>/dev/null
            rtnValue=$?
            if [ $rtnValue = 0 ];then
                build_workspace=`basename $project_path/$workspace_name`
                echo "$build_workspace will be build"
            else
                echo  "Error!Current path is not a xcode workspace.Please check, or do not use -w option."
                exit 2
            fi
            ;;
        "h" )
            buildHelp
            exit 0
            ;;
        "?" )
            echo "Error! Unknown parameter $OPTARG"
            exit 2
            ;;
        ":" )
            echo "Error! No argument value for parameter $OPTARG"
            exit 2
            ;;
          * )
            echo "Error! Unknown error while processing options"
            exit 2
            ;;         
    esac
done

#默认编译workspace
workspace_name='*.xcworkspace'
ls $project_path/$workspace_name &>/dev/null
rtnValue=$?
if [ $rtnValue = 0 ];then
    build_workspace=`basename $project_path/$workspace_name`
    echo "$build_workspace will be build"
else
    echo  "Error!Current path is not a xcode workspace.Please check, or do not use -w option."
    exit 2
fi

#加载配置信息
loadBuildConfig

# #获取build文件路径和info.plist路径
if [[ -n $build_workspace ]]; then
    app_infoplist_path="$workspaceName/$schemeName-Info.plist" # build workspace
else
    #获取工程文件
    project_name='*.xcodeproj'
    ls $project_path/$project_name &>/dev/null
    if [ $? = 0 ];then
        build_project=$(echo $(basename $project_path/$project_name))
    else
        echo  "Error!Current path is not a xcode project.Please check."
        exit 2
    fi
    app_infoplist_path="$targetName/$targetName-Info.plist"  #build project
fi

#keychain.plist路径
keychain_plist_path="$project_path/KeychainAccessGroups.plist"

#pushConfig.plist路径 
pushConfig_plist_path="$project_path/$targetName/ThirdPart/JPushLib/PushConfig.plist" 

#functionSwitchConfig.plist路径
functionSwitchConfig_plist_path="$project_path/$targetName/functionSwitchConfig.plist"

#取build号
#buildNumber=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${app_infoplist_path})
#buildNumber=$(($buildNumber+1))
#取gitcommit数做为build号
buildNumber=`git rev-list HEAD | wc -l | sed -e 's/ *//g' | xargs -n1 printf %d`

#修改info.plist
modify_plist -p "$app_infoplist_path" -k "CFBundleIdentifier" -v "$bundleID"
modify_plist -p "$app_infoplist_path" -k "CFBundleName" -v "$displayName"
modify_plist -p "$app_infoplist_path" -k "CFBundleDisplayName" -v "$displayName"
modify_plist -p "$app_infoplist_path" -k "CFBundleShortVersionString" -v "$appVersion"
modify_plist -p "$app_infoplist_path" -k "CFBundleVersion" -v "$buildNumber"
modify_plist -p "$app_infoplist_path" -k "Hybird_Version" -v "$hybirdVersion"

#修改keychain.plist
modify_plist -p "$keychain_plist_path" -k "keychain-access-groups:0" -v "$keychainAccess"

#修改pushConfig.plist
modify_plist -p "$pushConfig_plist_path" -k "APS_FOR_PRODUCTION" -v "$pushEnvironment"
modify_plist -p "$pushConfig_plist_path" -k "APP_KEY" -v "$pushAppKey"

#修改functionSwitchConfig.plist
#日志上传地址修改
modify_plist -p "$functionSwitchConfig_plist_path" -k ":12:subInfo:uploadServer" -v "$reportUploadServer"

#修改function

echo "Start Build Project..."
#生成的app文件目录
build_ipa_path=/Users/$USER/Documents/build-ipa
if [ ! -d $build_ipa_path ]; then
    mkdir $build_ipa_path
fi
case "$build_config" in
    "beta" )
        appdirname=Beta-iphoneos
        ;;
    "betapro" )
        appdirname=BetaPro-iphoneos
        ;;
    "betahoc" )
        appdirname=BetaHoc-iphoneos
        ;;
    "adhoc" )
        appdirname=AdHoc-iphoneos
        ;;
    "appstore" )
        appdirname=Release-iphoneos
        ;;
esac

build_ipa_path=$build_ipa_path/$appdirname
if [ ! -d $build_ipa_path ]; then
    mkdir $build_ipa_path
fi
dateFragment=$(date '+%Y-%m-%d')-$(date '+%H%M%S')

build_ipa_path=$build_ipa_path/$dateFragment
if [ ! -d $build_ipa_path ]; then
    mkdir $build_ipa_path
fi

if [[ -n $build_workspace ]]; then  
    /usr/bin/xcodebuild \
        -workspace $build_workspace \
        -scheme $schemeName \
        -configuration Release \
            CODE_SIGN_IDENTITY="$codeSign" \
            PROVISIONING_PROFILE="$profileUUID" \
            CONFIGURATION_BUILD_DIR="$build_ipa_path" \
            GCC_PREPROCESSOR_DEFINITIONS="SF_API_HOST=$apiHostEnvironment SF_REMOTE_H5=$apiMobileH5 SF_REMOTE_H5=$apiMobileH5 DEBUG=$debugMode SD_WEBP=1" \
            IPHONEOS_DEPLOYMENT_TARGET="$deploymentTarget" \
            clean build
else 
    /usr/bin/xcodebuild \
        -project $build_project \
        -target $targetName \
        -configuration Release \
            CODE_SIGN_IDENTITY="$codeSign" \
            PROVISIONING_PROFILE="$profileUUID" \
            CONFIGURATION_BUILD_DIR="$build_ipa_path" \
            GCC_PREPROCESSOR_DEFINITIONS="SF_API_HOST=$apiHostEnvironment SF_REMOTE_H5=$apiMobileH5 DEBUG=$debugMode SD_WEBP=1" \
            IPHONEOS_DEPLOYMENT_TARGET="$deploymentTarget" \
            clean build
fi

if [[ $? -ne 0 ]]; then  
    echo "Error! Build Project faild"
    exit 2
fi
echo "Build Project Success!"

#删除掉build自动生成的build文件夹
if [[ -d $project_path/build ]]; then
    rm -rf $project_path/build
fi

#IPA名称
ipa_name="${displayName}_${appVersion}_${buildNumber}"


#xcrun打包
echo "Start Build PackageApplication..."
xcrun -sdk iphoneos PackageApplication -v ${build_ipa_path}/*.app -o ${build_ipa_path}/${ipa_name}.ipa
if [[ $? -ne 0 ]]; then
    echo "Error! Build PackageApplication faild"
    exit 2
else
    echo "Build PackageApplication Success!"
    #将ipa文件拷贝到输出路径
    if [[ -n $build_out_path ]]; then
        #输出路径存在
        if [[ -d $build_out_path ]]; then
            cp ${build_ipa_path}/${ipa_name}.ipa $build_out_path/${ipa_name}.ipa
        else
            mkdir $build_out_path
            cp ${build_ipa_path}/${ipa_name}.ipa $build_out_path/${ipa_name}.ipa
        fi
         
    fi
fi

#upload ipa
if [ -f "upload.py" ]; then
python upload.py "$build_ipa_path/${ipa_name}.ipa"
fi


##是否需要上传ipa
#if read -t 10 -p "是否需要上传ipa到appbeta[Y/N][y/n]？" shouldUpload ; then
#    case $shouldUpload in
#        Y | y )
#            echo "Start upload..."
#            python upload.py ${build_ipa_path}/${ipa_name}.ipa
#            ;;
#        N | n )
#            ;;
#        "?" )
#            echo "Error! Unknown input parameter"
#            ;;
#        * )
#            echo "Error! Unknown input parameter"
#            ;;
#    esac
#else
#    echo "Error! input timeout"
#fi
exit 0
