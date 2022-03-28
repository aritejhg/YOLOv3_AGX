#install-opencv adapted from https://github.com/milq/milq/blob/master/scripts/bash/install-opencv.sh

######################################
# INSTALL OPENCV ON UBUNTU OR DEBIAN #
######################################

# -------------------------------------------------------------------- |
#                       SCRIPT OPTIONS                                 |
# ---------------------------------------------------------------------|
OPENCV_VERSION='4.1.2'       # Version to be installed, 4.1.2 to be same as colab
OPENCV_CONTRIB='NO'          # Install OpenCV's extra modules (YES/NO)
# -------------------------------------------------------------------- |

# |          THIS SCRIPT IS TESTED CORRECTLY ON          |
# |------------------------------------------------------|
# | OS               | OpenCV       | Test | Last test   |
# |------------------|--------------|------|-------------|
# | Ubuntu 20.04 LTS | OpenCV 4.5.1 | OK   | 27 Mar 2021 |
# |----------------------------------------------------- |
# | Ubuntu 20.04 LTS | OpenCV 4.2.1 | OK   | 25 Apr 2020 |
# |----------------------------------------------------- |
# | Debian 10.2      | OpenCV 4.2.0 | OK   | 26 Dec 2019 |
# |----------------------------------------------------- |
# | Debian 10.1      | OpenCV 4.1.1 | OK   | 28 Sep 2019 |
# |----------------------------------------------------- |
# | Ubuntu 18.04 LTS | OpenCV 4.1.0 | OK   | 22 Jun 2019 |
# | Debian 9.9       | OpenCV 4.1.0 | OK   | 22 Jun 2019 |
# |----------------------------------------------------- |
# | Ubuntu 18.04 LTS | OpenCV 3.4.2 | OK   | 18 Jul 2018 |
# | Debian 9.5       | OpenCV 3.4.2 | OK   | 18 Jul 2018 |



# Documentation and other:
sudo apt-get install -y doxygen unzip wget


# INSTALL THE LIBRARY

wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip
unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip
mv opencv-${OPENCV_VERSION} OpenCV

if [ $OPENCV_CONTRIB = 'YES' ]; then
  wget https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip
  unzip ${OPENCV_VERSION}.zip && rm ${OPENCV_VERSION}.zip
  mv opencv_contrib-${OPENCV_VERSION} opencv_contrib
  mv opencv_contrib OpenCV
fi

cd OpenCV && mkdir build && cd build

if [ $OPENCV_CONTRIB = 'NO' ]; then
cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON \
      -DWITH_XINE=ON -DENABLE_PRECOMPILED_HEADERS=OFF ..
fi

if [ $OPENCV_CONTRIB = 'YES' ]; then
cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON \
      -DWITH_XINE=ON -DENABLE_PRECOMPILED_HEADERS=OFF \
      -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules ..
fi

make -j8
sudo make install
sudo ldconfig -v
