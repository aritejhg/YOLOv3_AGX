#requirements.sh for installing dependencies in one
sudo apt-get -y update
sudo apt-get install -y git-all

#requirements for csv downloader
sudo apt-get install -y python3-pandas
sudo apt-get install -y python3-numpy
sudo apt-get install -y python3-urllib3
sudo apt-get install -y python3-tqdm
sudo apt-get install -y awscli
sudo apt-get install -y python-pathlib

#requirements for opencv
# Build tools:
sudo apt-get install -y build-essential cmake

# GUI (if you want GTK, change 'qt5-default' to 'libgtkglext1-dev' and remove '-DWITH_QT=ON'):
sudo apt-get install -y qt5-default libvtk6-dev

# Media I/O:
sudo apt-get install -y zlib1g-dev libjpeg-dev libwebp-dev libpng-dev libtiff5-dev libjasper-dev \
                        libopenexr-dev libgdal-dev

# Video I/O:
sudo apt-get install -y libdc1394-22-dev libavcodec-dev libavformat-dev libswscale-dev \
                        libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev yasm \
                        libopencore-amrnb-dev libopencore-amrwb-dev libv4l-dev libxine2-dev

# Parallelism and linear algebra libraries:
sudo apt-get install -y libtbb-dev libeigen3-dev

# Python:
sudo apt-get install -y python-dev  python-tk  pylint  python-numpy  \
                        python3-dev python3-tk pylint3 flake8

# Java:
sudo apt-get install -y ant default-jdk

#darknet requirements 
apt install ffmpeg libopencv-dev libgtk-3-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev qtbase5-dev libfaac-dev libmp3lame-dev v4l-utils unzip
