#!/bin/bash

# A simple bash script designed for compressing media on Discord to a desired filesize.

# Input video
if [ -z "$1" ]; then
	echo "Usage: $0 input_video_file"
	echo "Compresses video files to Discord quality"
	exit 1
fi



INPUT="$1"
BASE_NAME="${INPUT%.*}"
TARGET_SIZE=$(echo "8 * 1000 * 8" | bc -l)

# Check if ffmpeg is installed.
if command -v ffmpeg >/dev/null 2>&1 ; then
	# Get duration in seconds
	DURATION=$(ffmpeg -i "$INPUT" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d ,)
	IFS=: read -r H M S <<< "$DURATION"

	DURATION_SEC=$(echo "$H*3600 + $M*60 + $S" | bc -l)

	# Bitrate calculator
	# Formula : (target size in bits) / duration
	echo $TARGET_SIZE
	echo $DURATION_SEC
	FLOAT_BITRATE=$(echo "($TARGET_SIZE) / ($DURATION_SEC)" | bc -l)
	BITRATE=${FLOAT_BITRATE%.*}

	# Compress with FFMPEG
	ffmpeg -i "$INPUT" -c:v libx265 -preset medium -b:v "${BITRATE}k" -c:a aac -b:a 128k -f mp4 "${BASE_NAME}_compressed.mp4"
else
	echo "ERROR: FFMPEG is not installed!"
	echo "Please install FFMPEG using your respective package manager."
	exit 1
fi
