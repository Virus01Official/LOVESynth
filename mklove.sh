date "+Compiled: %Y/%m/%d %H:%M:%S" > version.txt
rm ../LOVESynth.love
zip -9 -r -x\.git/* ../LOVESynth.love .