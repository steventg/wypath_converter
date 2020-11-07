#!/bin/bash
set -e

DEST_DIR="dest_pano"
VIEWER_HTML="index.html"
mkdir -p ${DEST_DIR}

pushd freepv-0.3.0
rm -f CMakeCache.txt
rm -f Makefile
cmake .
make
pushd

cat > ${VIEWER_HTML} <<EOF
<html><body>
EOF

for src in source_qtvr/*.mov; do
  echo $src
  fileName=$(basename $src)
  prefix=${fileName//\.mov/}
  jpgFile=${DEST_DIR}/${prefix}.jpg
  ./freepv-0.3.0/src/utils/qtvr2img ${src} ${DEST_DIR}/${prefix}
  pnmtojpeg --quality=100 ${DEST_DIR}/${prefix}.pnm > ${jpgFile}
  rm ${DEST_DIR}/${prefix}.pnm  

  IFS=x read  width height < <(exiftool -T  -ImageSize ${jpgFile})
  echo $width $height  
  # calculation copied from here: https://facebook360.fb.com/editing-360-photos-injecting-metadata/
  let "fullPanoHeight = $width / 2"
  cropHeight=`echo "x = (${fullPanoHeight}*2*a((${height}/2)/(${width}/(2*4*a(1))))/(4*a(1))); scale=0; x/1" | bc -l`
  cropTop=`echo "x = (${fullPanoHeight}/2)*(((4*a(1))/2)-a((${height}/2)/(${width}/(2*(4*a(1))))))/((4*a(1))/2); scale=0; x/1" | bc -l`
  echo exiftool -FullPanoWidthPixels=${width} \
  	-FullPanoHeightPixels=${fullPanoHeight} \
  	-CroppedAreaLeftPixels=0 \
  	-CroppedAreaTopPixels=${cropTop} \
  	-CroppedAreaImageWidthPixels=${width} \
  	-CroppedAreaImageHeightPixels=${cropHeight} \
  	-ProjectionType=cylindrical
  	
  exiftool -FullPanoWidthPixels=${width} \
  	-FullPanoHeightPixels=${fullPanoHeight} \
  	-CroppedAreaLeftPixels=0 \
  	-CroppedAreaTopPixels=${cropTop} \
  	-CroppedAreaImageWidthPixels=${width} \
  	-CroppedAreaImageHeightPixels=${cropHeight} \
  	-ProjectionType=cylindrical \
  	-overwrite_original \
  	${jpgFile}

  cat >> ${VIEWER_HTML} <<EOF
    <iframe width="600" height="400" allowfullscreen style="border-style:none;" src="https://cdn.pannellum.org/2.5/pannellum.htm#panorama=https%3A//steventg.github.io/wypath_converter/dest_pano/${jpgFile}"></iframe>
EOF

done

cat >> ${VIEWER_HTML} <<EOF
</body><html>
EOF
