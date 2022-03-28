SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR
#install requirements
chmod +x requirements.sh
sudo ./requirements.sh

wait

sudo apt install nvidia-cuda-toolkit gcc
#maybe should put an if statement here. https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#mandatory-post

echo "PATH=/usr/local/cuda/bin:$PATH" >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64' >> ~/.bashrc
#slightly changed coz https://forums.developer.nvidia.com/t/path-ld-library-path/48080/1
source ~/.bashrc

#extract and copy cudnn https://docs.nvidia.com/deeplearning/cudnn/archives/cudnn_765/cudnn-install/index.html#installlinux
echo Download CUDNN and rename to cudnn.tgz. Place inside the libraries folder.
read -p "press y when done: " CUDNN_DOWNLOADED_RENAMED
if [ "$CUDNN_DOWNLOADED_RENAMED" = "y" ]; then
  tar -xzvf libraries/cudnn.tgz
  sudo cp cuda/include/cudnn*.h /usr/local/cuda/include 
  sudo cp -P cuda/lib64/libcudnn* /usr/local/cuda/lib64 
  sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
fi

#download CSV for openimages
echo Downloading CSVs
python3 openimages_csv/csv_downloader.py
wait
echo CSVs downloaded or already exist

#install opencv
echo Installing OpenCV
chmod +x ./libraries/install-opencv.sh
sudo ./libraries/install-opencv.sh
wait
echo OpenCV installed
source ~/.bashrc

#git clone alexeyab/darknet
git clone https://www.github.com/AlexeyAB/darknet
echo Git cloned
cd darknet
sed -i 's/GPU=0/GPU=1/g' Makefile
sed -i 's/CUDNN=0/CUDNN=1/g' Makefile
sed -i 's/CUDNN_HALF=0/CUDNN_HALF=1/g' Makefile
sed -i 's/OPENCV=0/OPENCV=1/g' Makefile
echo Change Makefile to reflect correct hardware ARCH (https://github.com/AlexeyAB/darknet#how-to-compile-on-linux-using-make
read -p "press y when done: " GPU_SET
if [ "$GPU_SET" = "y" ]; then
  make
  chmod a+x ./darknet
  echo Darknet made
fi

# get yolov3 custom training weights
wget -c https://pjreddie.com/media/files/darknet53.conv.74
echo Weights downloaded

echo Installer finished!
