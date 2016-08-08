#!/bin/sh

#当前目录
current_dir_path=$(dirname $0)
current_dir_path=${current_dir_path/\./$(pwd)}
current_user_path=${current_dir_path#*Users/}
current_user_path=${current_user_path%%/*}
current_user_path="/Users/$current_user_path"

function the_help() {
    echo "#####################################"
    echo "# 参数说明"
    echo "# -a xxxxx.app.dSYM 文件路径，必须传入"
    echo "# -c crash 文件路径，必须传入"
    echo "# -e 解析的crash文件输出目录，非必须"
    echo "# -h help 帮助"
    echo "#####################################"
}

function error_exit() {
    if [ $1 -ne 0 ]; then
        echo $2
        if [$# -eq 3 ]; then
        	exit 1
    	fi
    fi       
}


until [ $# -eq 0 ] 
do 
	case $1 in
   		-a) dsym_file=$2 
			shift 
   			;; # 
   		-c) crash_file=$2 
			shift 
   			;; # 
   		-e) export_path=$2
			shift 
   			;; # 
   		-h) the_help
			;;
	esac
	shift 
done 

#符号文件存在与否
if [ ! -d  "$dsym_file" ]; then 
	echo "符号文件（*.app.dSYM）没找到！"
	the_help
    exit 1
fi

#crash文件存在与否
if [ ! -f  "$crash_file" ]; then 
	echo "要解析的crash文件（*.crash）没找到！"
	the_help
    exit 1
fi

#读取crash文件中的关键信息
#去crash文件中找Path
app_path_full=`grep "Path:" "$crash_file"`

app_path=${app_path_full##*private/}

# file=/dir1/dir2/dir3/my.file.txt
# 我們可以用 ${ } 分別替換獲得不同的值：
# ${file#*/}：拿掉第一條 / 及其左邊的字串：dir1/dir2/dir3/my.file.txt
# ${file##*/}：拿掉最後一條 / 及其左邊的字串：my.file.txt
# ${file#*.}：拿掉第一個 . 及其左邊的字串：file.txt
# ${file##*.}：拿掉最後一個 . 及其左邊的字串：txt
# ${file%/*}：拿掉最後條 / 及其右邊的字串：/dir1/dir2/dir3
# ${file%%/*}：拿掉第一條 / 及其右邊的字串：(空值)
# ${file%.*}：拿掉最後一個 . 及其右邊的字串：/dir1/dir2/dir3/my.file
# ${file%%.*}：拿掉第一個 . 及其右邊的字串：/dir1/dir2/dir3/my
# /var/mobile/Applications/3D507EA9-1BB7-4360-B01A-CA5A5F3FC7A5/sfhaitao.app/sfhaitao
app_name=${app_path##*/}

code_type_line=`grep $app_path "$crash_file" | grep -v "$app_path_full"`
tem_substring="*$app_name"
code_type=${code_type_line#$tem_substring}
tem_substring="<*>*"
# code_type=${code_type%%$tem_substring}
code_type=arm64

os_version=`grep "OS Version:" "$crash_file"`
os_version=${os_version##*iOS }

#查看是否能解析系统目录
system_symbols_path="$current_user_path/Library/Developer/Xcode/iOS DeviceSupport/$os_version/Symbols"
is_exist_sys_symbols=true
if [ ! -d "$system_symbols_path" ]; then 
	echo "无法解析系统符号，没有找到对应的符号文件！！"
	is_exist_sys_symbols=false
fi  

#输出目录
if [ -z "$export_path" ]; then 
    export_path="$current_dir_path/crash"
fi

if [ ! -d "$export_path" ]; then  
	echo "输出目录还不存在，故创建目录 '$export_path'"
	mkdir "$export_path"  
fi  

#将目标文件拷贝到输出目录
crash_name=${crash_file##*/}
export_file="$export_path/$crash_name"

if [ -f "$export_file" ]; then
	echo "已经存在，删除重新拷贝"
	rm -rf "$export_file"
fi
cp "$crash_file" "$export_path/"

#开始解析
echo "============================开始 解析============================"
echo "= crash file : '$crash_file'"
echo "= dSYM       : '$dsym_file'"
echo "= export file: '$export_file'"
echo "= app name   : '$app_name'"
echo "= code type  : '$code_type'"
echo "= os version : 'iOS $os_version'"
echo "================================================================"

tem_substring="Binary Images:"
binary_images_row=`sed -n -e "/$tem_substring/=" "$crash_file"`
if [ $binary_images_row -eq 0 ]; then
	echo "没有找到起始地址，无法解析"
	exit 1
fi

#先解析app代码
echo "=========================app code begin========================="
app_code_binary_row=$[binary_images_row + 1]
# app_code_binary_row=352

the_line=`sed -n "$app_code_binary_row p" "$crash_file"`
start_address=${the_line%%-*}

deal_rows_string=`sed -n -e "/$start_address/=" "$crash_file"`

OLD_IFS="$IFS" 
IFS="," 
deal_rows=($deal_rows_string) 
IFS="$OLD_IFS" 
for deal_row in ${deal_rows[@]} 
do 
	if [ $deal_row -eq $app_code_binary_row ]; then
		continue 
	fi

	#原始字符串
	deal_line=`sed -n "$deal_row p" "$crash_file"`

	#计算新的字符串
	tem_substring=${deal_line%%$start_address*}

	header_string=${deal_line%%0x*}

	deal_address=${tem_substring##$header_string}

	#执行解析语句
	tem_substring=`xcrun atos -o "$dsym_file/Contents/Resources/DWARF/$app_name" -l $start_address -arch $code_type $deal_address`
	echo $tem_substring

	result_line="$header_string$tem_substring"

	#替换符号文件
	sed -i "" "s#$deal_line#$result_line#g" "$export_file"

done
echo "==========================app code end=========================="


#解析系统代码
if [ $is_exist_sys_symbols ]; then
	echo "=========================sys code begin========================="

	crash_file_row_count=`sed -n '$=' "$crash_file"`

	sys_code_binary_row=$[binary_images_row + 1]
	while [ $sys_code_binary_row -lt $crash_file_row_count ]
	do
		sys_code_binary_row=`expr $sys_code_binary_row + 1`
		# echo $sys_code_binary_row
	   
		the_line=`sed -n "$sys_code_binary_row p" "$crash_file"`

		start_address=${the_line%%-*}
		library_path=${the_line##*<*> }

		deal_rows_string=`sed -n -e "/$start_address/=" "$crash_file"`

		OLD_IFS="$IFS" 
		IFS="," 
		deal_rows=($deal_rows_string) 
		IFS="$OLD_IFS" 
		for deal_row in ${deal_rows[@]} 
		do 
			if [ $deal_row -eq $sys_code_binary_row ]; then
				continue 
			fi

			#原始字符串
			deal_line=`sed -n "$deal_row p" "$crash_file"`

			#计算新的字符串
			tem_substring=${deal_line%%$start_address*}

			header_string=${deal_line%%0x*}

			deal_address=${tem_substring##$header_string}

			#执行解析语句
			tem_substring=`xcrun atos -o "$system_symbols_path$library_path" -l $start_address -arch $code_type $deal_address`
			echo $tem_substring

			result_line="$header_string$tem_substring"

			#替换符号文件
			sed -i "" "s#$deal_line#$result_line#g" "$export_file"

		done

	done

	echo "==========================sys code end=========================="
fi



