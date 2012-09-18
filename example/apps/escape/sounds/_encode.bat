FOR /R %1 %%G IN (*.wav) DO tools\lame.exe -V2 "%%G"
FOR /R %1 %%G IN (*.wav) DO tools\oggenc2.exe -q 6 "%%G"