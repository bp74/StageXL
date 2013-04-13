FOR %%G IN (*.png) DO cwebp.exe "%%G" -m 6 -q 100 -lossless -o "%%~nG.webp"
FOR %%G IN (*.jpg) DO cwebp.exe "%%G" -m 6 -q 80 -o "%%~nG.webp"
