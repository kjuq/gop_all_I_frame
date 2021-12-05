#!/bin/sh

set -e

TYPE="--rotate"

ORIG_VID=landscape.mov

ENCRYPTOR=~/codes/seminar/jpeg_encryption

I_FRAME=1

# ensure that the current directory is where the script is
DIR=`dirname $0` && cd $DIR

DIR=`pwd`
TMP=$DIR/tmp

mkdir $TMP

# create a raw video from the original one
raw_vid=raw.avi
ffmpeg -i $ORIG_VID -vcodec rawvideo -pix_fmt yuv420p $TMP/$raw_vid
echo "!-- A raw video was successfully converted from an original video. --!"
pwd

# create pictures of frames from a raw video
ffmpeg -i $TMP/$raw_vid $TMP/frame%03d.png
echo "!-- Pictures of frames were successfully extraced from a raw video. --!"
pwd

# encrypt each extraced frames
cd $TMP
i=0
for f in frame*.png; do
	((i++))
	if [ $(( i % 10 )) -eq 0 ]; then
		echo "$f is successfully encrypted."
	fi
	python $ENCRYPTOR/encryptor.py --type=encrypt $TYPE -i $f -o $f
done
cd $DIR
echo "!-- Frames were successfully encrypted. --!"

# concatenate encrypted frames
enc_raw_vid=enc_raw.avi
ffmpeg -r 60 -i $TMP/frame%03d.png -r 60 -vcodec rawvideo -pix_fmt yuv420p $TMP/$enc_raw_vid
echo "!-- Frames were successfully concatenated into an uncompressed video. --!"

# compress an encrypted video
enc_cmp_vid=enc_cmp.mp4
ffmpeg -i $TMP/$enc_raw_vid -vcodec libx264 -g $I_FRAME -keyint_min $I_FRAME -preset veryfast -crf 35 $TMP/$enc_cmp_vid
echo "!-- An encrypted video was successfully compressed. --!"

# separate an encrypted video into frames again
ffmpeg -i $TMP/$enc_cmp_vid $TMP/frame%03d.png
echo "!-- An encrypted and compressed video was successfully separated into frames. --!"

# decrypt separated frames
cd $TMP
i=0
for f in frame*.png; do
	((i++))
	if [ $(( i % 10 )) -eq 0 ]; then
		echo "$f is successfully decrypted."
	fi
	python $ENCRYPTOR/encryptor.py --type=decrypt $TYPE -i $f -o $f
done
cd $DIR
echo "!-- Frames were successfully decrypted. --!"

# concatenate decrypted frames
dec_comp_vid=dec_cmp.avi
ffmpeg -r 60 -i $TMP/frame%03d.png -r 60 -vcodec rawvideo -pix_fmt yuv420p $TMP/$dec_comp_vid
echo "!-- Frames were successfully concatenated into an uncompressed and decrypted video. --!"

# remove temporary files
rm -rf $TMP/*.png
echo "!-- Temporary files were successfully deleted. --!"

echo ""
echo "Encryption Type: " $TYPE
echo "Interval of I-frame: " $I_FRAME






