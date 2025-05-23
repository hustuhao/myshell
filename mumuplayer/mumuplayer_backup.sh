#!/bin/bash
# /Volumes/LinaBell/Software/Mumuplayer/备份
# 默认源目录和目标目录
DEFAULT_SOURCE_DIR="$HOME/Library/Application Support/com.netease.mumu.nemux/vms"
DEFAULT_BACKUP_DIR="$HOME/vms_backup" # 默认备份存放目录
TIMESTAMP=$(date +%Y%m%d_%H%M%S)      # 时间戳格式

# 显示帮助信息
show_help() {
	echo "Usage: $0 {backup|restore} [options]"
	echo "Options:"
	echo "  --folder_number : 可选，指定数字编号的文件夹（例如：0, 1, 2）。如果不指定，则备份/还原所有文件夹"
	echo "  --source_dir    : 可选，指定源目录，默认值为 $DEFAULT_SOURCE_DIR"
	echo "  --backup_dir    : 可选，指定备份目录，默认值为 $DEFAULT_BACKUP_DIR"
}

# 解析命令行参数
parse_args() {
	local operation="$1"
	shift # Remove the first argument which is the operation

	while [[ $# -gt 0 ]]; do
		case "$1" in
		--folder_number)
			folder_number="$2"
			shift 2
			;;
		--source_dir)
			source_dir="$2"
			shift 2
			;;
		--backup_dir)
			backup_dir="$2"
			shift 2
			;;
		*)
			echo "未知参数: $1"
			show_help
			exit 1
			;;
		esac
	done
}

# 备份函数
backup() {
	local source_dir="$1"
	local backup_dir="$2"
	local folder_number="$3"

	mkdir -p "$backup_dir" # 确保备份目录存在
	if [ -z "$folder_number" ]; then
		# 备份所有文件夹
		tar_file="$backup_dir/vms_all_$TIMESTAMP.tar"
		tar -cf "$tar_file" -C "$source_dir" . || {
			echo "错误：无法切换到目录 $source_dir"
			exit 1
		}
		echo "所有文件夹已打包备份到 $tar_file"
	else
		# 备份指定的文件夹
		folder="$source_dir/$folder_number"
		if [ -d "$folder" ]; then
			tar_file="$backup_dir/vms_$folder_number_$TIMESTAMP.tar"
			tar -cf "$tar_file" -C "$source_dir" "$folder_number" || {
				echo "错误：无法切换到目录 $source_dir 或文件夹 $folder_number 不存在"
				exit 1
			}
			echo "文件夹 $folder_number 已打包备份到 $tar_file"
		else
			echo "文件夹 $folder_number 不存在"
		fi
	fi
}

# 恢复函数
restore() {
	local source_dir="$1"
	local backup_dir="$2"
	local folder_number="$3"

	if [ -z "$folder_number" ]; then
		for tar_file in "$backup_dir"/vms_all_*.tar; do
			if [ -f "$tar_file" ]; then
				tar -xf "$tar_file" -C "$source_dir"
			fi
		done
		echo "所有文件夹已恢复"
	else
		tar_file="$backup_dir/vms_$folder_number_*.tar"
		latest_tar=$(ls -t $tar_file 2>/dev/null | head -n 1)
		if [ -f "$latest_tar" ]; then
			tar -xf "$latest_tar" -C "$source_dir"
			echo "文件夹 $folder_number 已恢复"
		else
			echo "没有找到编号为 $folder_number 的备份文件"
		fi
	fi
}

# 检查输入参数
if [ $# -lt 1 ]; then
	show_help
	exit 1
fi

# 获取操作类型
operation="$1"
shift

# 解析其他参数
parse_args "$operation" "$@"

# 设置默认值
source_dir="${source_dir:-$DEFAULT_SOURCE_DIR}"
backup_dir="${backup_dir:-$DEFAULT_BACKUP_DIR}"

# 根据第一个参数执行备份或恢复操作
case "$operation" in
backup)
	backup "$source_dir" "$backup_dir" "$folder_number"
	;;
restore)
	restore "$source_dir" "$backup_dir" "$folder_number"
	;;
*)
	show_help
	exit 1
	;;
esac
