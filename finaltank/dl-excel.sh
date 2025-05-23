#!/bin/bash

# 检查参数是否提供
if [ $# -ne 2 ]; then
	echo "用法: $0 <Git分支名> <解压目标目录>"
	exit 1
fi

# 定义变量
GIT_BRANCH="$1"
EXTRACT_DIR="$2"
WORK_DIR=$(pwd)
SERVER_EXCEL_DIR="$WORK_DIR/excels"
CLIENT_EXCEL_DIR="Assets/LocalResources/Config/Excel"
TMP_ARCHIVE="$SERVER_EXCEL_DIR/tmp.tar"

# 创建目标目录(如果不存在)
mkdir -p "$SERVER_EXCEL_DIR"
mkdir -p "$EXTRACT_DIR"

# 切换到工作目录
cd "$SERVER_EXCEL_DIR" || exit

# 下载配置文件
echo "正在从Git分支 '$GIT_BRANCH' 下载Excel配置文件..."
git archive --output="$TMP_ARCHIVE" --remote=git@git.17zjh.com:zhuguangwen/TankGame.git "$GIT_BRANCH" "$CLIENT_EXCEL_DIR"

# 检查git archive是否成功
if [ $? -ne 0 ]; then
	echo "错误: 无法从Git获取指定分支的文件"
	rm -f "$TMP_ARCHIVE"
	exit 1
fi

# 解压配置文件
echo "正在解压文件到 '$EXTRACT_DIR'..."
tar -xvf "$TMP_ARCHIVE" -C "$EXTRACT_DIR"

# 检查tar是否成功
if [ $? -ne 0 ]; then
	echo "错误: 解压文件失败"
	rm -f "$TMP_ARCHIVE"
	exit 1
fi

# 删除临时文件
rm -f "$TMP_ARCHIVE"
echo "临时文件已删除"

echo "配置文件下载并解压完成!"
