cd images
FOR /R %%G IN (*.png) DO cwebp.exe "%%G" -q 100 -lossless -o "%%~nG.webp"
FOR /R %%G IN (*.jpg) DO cwebp.exe "%%G" -q 80 -o "%%~nG.webp"
