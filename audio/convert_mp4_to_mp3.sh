#!/bin/bash

# 检查参数个数
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <directory>"
	exit 1
fi

# 要处理的目录
DIRECTORY=$1

# 检查目录是否存在
if [ ! -d "$DIRECTORY" ]; then
	echo "Directory does not exist: $DIRECTORY"
	exit 1
fi

# 遍历目录中的所有 mp4 文件
for file in "$DIRECTORY"/*.mp4; do
	# 获取不带扩展名的文件名
	base_name=$(basename "$file" .mp4)

	# 定义输出的 MP3 文件名
	output_file="$DIRECTORY/$base_name.mp3"

	# 使用 ffmpeg 进行转换
	echo "Converting $file to $output_file..."
	ffmpeg -i "$file" -q:a 0 -map a "$output_file"
done

echo "Conversion completed."
