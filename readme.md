# Caution

The way described below isn't recommended.
Just type `./main.sh`

# create an uncompressed video

```bash
ffmpeg -i landscape.mov -vcodec rawvideo -pix_fmt yuv420p landscape_raw_yuv420p.avi
```

# separate a uncompressed video into frames

```bash
ffmpeg -i landscape_raw_yuv420p.avi ./frames_orig/frame%03d.png
```

# encrypt each frames

```fish
set ENCRYPTOR ~/codes/seminar/jpeg_encryption
mkdir frames_rot
mkdir frames_inv
mkdir frames_scr
cd frames_orig
for f in frame*.png; python $ENCRYPTOR/encryptor.py --type=encrypt --rotate -i $f -o ../frames_rot/$f; end
for f in frame*.png; python $ENCRYPTOR/encryptor.py --type=encrypt --invert -i $f -o ../frames_inv/$f; end
for f in frame*.png; python $ENCRYPTOR/encryptor.py --type=encrypt --scramble -i $f -o ../frames_scr/$f; end
```

# concatenate the frames into uncompressed video

```bash
ffmpeg -r 60 -i ./frames_rot/frame%03d.png -r 60 -vcodec rawvideo -pix_fmt yuv420p reconst_rot.avi
ffmpeg -r 60 -i ./frames_inv/frame%03d.png -r 60 -vcodec rawvideo -pix_fmt yuv420p reconst_inv.avi
ffmpeg -r 60 -i ./frames_scr/frame%03d.png -r 60 -vcodec rawvideo -pix_fmt yuv420p reconst_scr.avi
```

# compress the encrypted video

cf. https://superuser.com/questions/908280/what-is-the-correct-way-to-fix-keyframes-in-ffmpeg-for-dash

```bash
ffmpeg -i reconst_rot.avi -vcodec libx264 -g 1 -keyint_min 1 -preset veryfast -crf 35 reconst_rot_comp.mp4
ffmpeg -i reconst_inv.avi -vcodec libx264 -g 1 -keyint_min 1 -preset veryfast -crf 35 reconst_inv_comp.mp4
ffmpeg -i reconst_scr.avi -vcodec libx264 -g 1 -keyint_min 1 -preset veryfast -crf 35 reconst_scr_comp.mp4
```

# separate into frames again

```bash
mkdir frames_rot_comp
mkdir frames_inv_comp
mkdir frames_scr_comp
cd ..
ffmpeg -i reconst_rot_comp.mp4 ./frames_rot_comp/frame%03d.png
ffmpeg -i reconst_inv_comp.mp4 ./frames_inv_comp/frame%03d.png
ffmpeg -i reconst_scr_comp.mp4 ./frames_scr_comp/frame%03d.png
```

# decrypt each frames

```fish
mkdir frames_rot_decr
mkdir frames_inv_decr
mkdir frames_scr_decr
set ENCRYPTOR ~/codes/seminar/jpeg_encryption
```

```fish
cd frames_rot_comp
for f in frame*.png; python $ENCRYPTOR/encryptor.py --type=decrypt --rotate -i $f -o ../frames_rot_decr/$f; end
```

```fish
cd frames_inv_comp
for f in frame*.png; python $ENCRYPTOR/encryptor.py --type=decrypt --invert -i $f -o ../frames_inv_decr/$f; end
```

```fish
cd frames_inv_comp
for f in frame*.png; python $ENCRYPTOR/encryptor.py --type=decrypt --scramble -i $f -o ../frames_scr_decr/$f; end
```

# concatenate decrypted frames

```bash
ffmpeg -r 60 -i ./frames_rot_decr/frame%03d.png -r 60 -vcodec rawvideo -pix_fmt yuv420p reconst_rot_comp_decr.avi
ffmpeg -r 60 -i ./frames_inv_decr/frame%03d.png -r 60 -vcodec rawvideo -pix_fmt yuv420p reconst_inv_comp_decr.avi
ffmpeg -r 60 -i ./frames_rot_decr/frame%03d.png -r 60 -vcodec rawvideo -pix_fmt yuv420p reconst_scr_comp_decr.avi
```






