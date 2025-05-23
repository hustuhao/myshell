#!/bin/bash

# sh dl-excels-v3.sh instantgame-activity-optimization

# 检查参数是否提供
if [ $# -ne 2 ]; then
	echo "用法: $0 <Git分支名> <解压目标目录>"
	exit 1
fi

# 定义变量
GIT_BRANCH="$1"
TARGET_DIR=$(realpath "$2") # 获取绝对路径
WORK_DIR=$(pwd)
SERVER_EXCEL_DIR="$WORK_DIR/excels"
CLIENT_EXCEL_DIR="Assets/LocalResources/Config/Excel"
TMP_ARCHIVE="$SERVER_EXCEL_DIR/tmp.tar"
TMP_EXTRACT_DIR="$SERVER_EXCEL_DIR/tmp_extract"

# 创建目标目录(如果不存在)
mkdir -p "$SERVER_EXCEL_DIR"
mkdir -p "$TARGET_DIR"
mkdir -p "$TMP_EXTRACT_DIR"

# 切换到工作目录
cd "$SERVER_EXCEL_DIR" || exit

# 下载配置文件
echo "正在从Git分支 '$GIT_BRANCH' 下载Excel配置文件..."
git archive --output="$TMP_ARCHIVE" --remote=git@git.17zjh.com:zhuguangwen/TankGame.git "$GIT_BRANCH" "$CLIENT_EXCEL_DIR"

# 检查git archive是否成功
if [ $? -ne 0 ]; then
	echo "错误: 无法从Git获取指定分支的文件"
	rm -rf "$TMP_EXTRACT_DIR" "$TMP_ARCHIVE"
	exit 1
fi

# 解压配置文件到临时目录
echo "正在解压文件到临时目录..."
tar -xvf "$TMP_ARCHIVE" -C "$TMP_EXTRACT_DIR"

# 检查tar是否成功
if [ $? -ne 0 ]; then
	echo "错误: 解压文件失败"
	rm -rf "$TMP_EXTRACT_DIR" "$TMP_ARCHIVE"
	exit 1
fi

# 移动Excel文件到目标目录并移除前缀
echo "正在处理文件路径并移动到 '$TARGET_DIR'..."
find "$TMP_EXTRACT_DIR" -type f -name "*.xlsx" -o -name "*.xls" | while read -r file; do
	# 获取文件名(不含路径)
	filename=$(basename "$file")
	# 移动到目标目录
	mv "$file" "$TARGET_DIR/$filename"
	echo "已移动: $filename"
done

# 删除临时文件和目录
rm -rf "$TMP_EXTRACT_DIR" "$TMP_ARCHIVE"
echo "临时文件和目录已删除"

echo "配置文件下载、处理并移动到 '$TARGET_DIR' 完成!"
