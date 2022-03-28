# YOLOv3_AGX
An implementation of YOLOv3 on NVIDIA AGX. Includes my implementation of dataset creation using Google OpenImages

This project focuses on training a YOLO model on custom database with custom set of classes using alexeyab/darknet and google openimages. 

It provides a way to download images (without annotations, look at OiD toolkit if annotations are needed) as I create custom annotations and train dataset on the yolo model. 

This project allows for creation of multiple datasets which can be tested using different models trained at different resolutions for varying number of epochs.

Tested on Ubuntu 18.04 with RTX 2060 SUPER.

**Folder layout (after one round) for training PC**

```
door_staircase_detection
-- readme.md
-- main_installer.sh
-- requirements.sh
-- openimages_csv
    -- csv_downloader.py
-- libraries
    -- install-opencv.sh
    -- cudnn.tgz 
-- dataset
    -- generate_txt.py
    -- draw_bbox.py
    -- <dataset folder>_openimages
    -- <dataset folder>
        -- train.txt
        -- valid.txt
        -- <images with labels>
        -- results_<model>_<resolution>_<epochs>.txt #after detection is performed
        -- detection_results 
            -- <model>_<resolution>_<epochs>
                -- <images from valid.txt annotated with ground truth and preds>
-- darknet
    -- <model>_<resolution>_<epochs>_<dataset folder> #backup folder to store weights and logs
    -- cfg_file_generator.sh
    -- cfg
        -- <model>_<resolution>_<epochs>_<dataset folder>_train.cfg
        -- <model>_<resolution>_<epochs>_<dataset folder>_detection.cfg
    -- data
        -- obj_<dataset folder>.names
        -- <model>_<resolution>_<epochs>_<dataset folder>.data 
-- openimages_downloader.py
```

### Clone this repo into the home directory!!!!!

#***FLOW:***
0. Run main_installer.sh in main directory
**Inside main_installer.sh**
1. Requirements are installed
2. Install CUDA, CUDNN. (INSTALL NVIDIA DRIVERS BEFORE THIS) 
CUDNN needs to be manually downloaded from https://developer.nvidia.com/rdp/cudnn-archive. Download the tar in the libraries folder and rename to cudnn.tgz. Currently downloaded version is cudnn-11.3-linux-x64-v8.2.1.32.tgz
3. opencv is installed using install-opencv.sh, ver = 4.1.2 with opencv-contrib = NO
4. darknet is installed, and conv74 (custom training) weights are downloaded in the darknet directory

5. The darknet repo can now be tested using this command, executed from the darknet directory (this will not provide predictions, just to make sure darknet was made accurately):

```bash
./darknet detector test cfg/coco.data cfg/yolov4.cfg darknet53.conv.74 -thresh 0.25
```
***Now, the one time installation and setup is done.***



6. openimages_downloader.py can be run to download images from openimages dataset using

  ```bash
  python3 openimages_downloader.py
  ```

  Parameters:

  _list_of_classes_: provide a list of classes, classes must be mentioned exactly as in class-descriptions.csv. Recommended to put class with least number of images first, but code still works regardless. example: Door Stairs  
  Important that syntax is followed, exact spellings and case. Classes separated by a space.

  _mode of download_: single downloads all images of that contain any one of the classes. joint downloads images which have 2 or more classes. all downloads images that have all classes. [BUGGY, DO NOT USE] negative downloads only images which dont contain any class. Have a limit of 500, can be changed inside image_downloader.py

  _download folder_: name of the folder inside dataset folder, where images are downloaded to. images are downloaded to dataset/\<dataset folder>\_openimages

  _limit_: number of images to download

TODO:

Import annotations. Might need to import into annotations csv first.

Negatives mode is buggy. Might be classes having multiple names or annotation problems.

limit is only implemented at the end via slicing. a better way would be to implement while choosing images.

openimages offers info abt labels like if its occluded or if its a depiction. OID allows to filter based on that, that code needs to be imported. need to look into csv file to import that data as well.

This script is hard coded to get images from the training folder of openimages. To download from the other folders, need to change the csv downloaded and bring over code from OID Toolkit to achieve this filtering (can implement a pandas filtering of dataset before choosing images maybe?)

7. Once images are downloaded, use software of choice to label (https://github.com/AlexeyAB/darknet#how-to-mark-bounded-boxes-of-objects-and-create-annotation-files). Integrate any other sources of images here if present. (Roboflow can be used for annotation, but free tier has limit so process in batches). 

labelImg can be used for annotation.

```bash
git clone https://github.com/tzutalin/labelImg.git
sudo apt-get install pyqt5-dev-tools
cd labelImg
sudo pip3 install -r requirements/requirements-linux-python3.txt
make qt5py3
```

	In data/predefined_classes.txt define the list of classes that will be used for your training.
    
```bash
python3 labelImg.py
```

    Right below "Save" button in the toolbar, click "PascalVOC" button to switch to YOLO format.

    You may use Open/OpenDIR to process single or multiple images. When finished with a single image, click save.

 A txt file of YOLO format will be saved in the same folder as your image with 	same name. A file named "classes.txt" is saved to that folder too. "classes.txt" defines the list of class names that your YOLO label refers to.

Refer to hotkeys (https://github.com/tzutalin/labelImg#hotkeys) for easy operation.

8. Export as YOLO format. Save images and ground truth txts into the dataset folder being used. Augmentation using Roboflow can be done as well. Save this dataset to dataset/\<dataset folder> (VoTT was used, but not reccomended) (Roboflow can be used for converting to yolo format and augmentation)

  obj.names file is obtained as well, which contains the list of classes. Rename to obj_\<dataset folder>.names, and save in darknet/data/ .  

9. Using generate_txt.py, a random train.txt and valid.txt can be created of the appropriate percentage. Also generates the 
Command used: 

  ``` bash
  python3 ~/staircase-and-doorway-detection-yolov3/dataset/generate_txt.py 
  ```

  Parameters: 

  _Percentage (given as decimal)_: ```0.8``` for 80% training set 20% validation set.
  
  _dataset name_: name of the folder inside dataset folder, where images are downloaded to.
  
  _Currently, test set is not created._

***Now, dataset configuration is complete.*** 



10. Create a new cfg file using cfg\_file\_generator.sh . Creates train and detection cfg.  obj_\<model>\_\<resolution>\_\<epochs>.data file and darknet/\<model>\_\<resolution>\_\<epochs>\_\<dataset folder> is created automatically as well. Runs in the bash env. 

  Parameters:

  _model_: name of the model.
  
  _resolution_: resolution for performing training and detection. If a different resolution is needed for training or detection, change one of the cfg files. must be divisible by 32.

  _epochs_: training cycles. recommended classes*2000.

  _dataset folder_: the folder name where dataset is saved inside the dataset directory.

  _classes_: number of classes in the dataset


This can be run using 
```bash
cd darknet
chmod +x cfg_file_generator.sh
./cfg_file_generator.sh
```
 _currently, this script only works with yolov3. To switch to other models, the sed commands need to be changed to what is in the config being copied to create the train.cfg_

11. Train using this command. change parameters and paths as necessary.  
(Transfer learning info https://stackoverflow.com/a/55132722). Run from inside the darknet directory.

```bash
./darknet detector train data/<model>_<resolution>_<epochs>_<dataset folder>.data cfg/<model>_<resolution>_<epochs>_<dataset folder>_train.cfg darknet53.conv.74 -dont_show -map | tee <model>_<resolution>_<epochs>_<dataset folder>/log.txt
```

  a darknet/chart\_\<model>\_\<resolution>\_\<epochs>\_\<dataset folder>\_\train.png is created for every training. Every time training is stopped and resumed, a new chart will be created. If it is the same model, resolution, epochs and dataset, it will overwrite the old one. Reccomend to move the training chart to darknet/\<model>\_\<resolution>\_\<epochs>\_\<dataset folder> folder and rename it once training is finished, if training is meant to be resumed later.
  
  -dont_show stops showing the chart, if you would like to view the chart as it trains, please remove it.

  For resuming training, use:

```bash
./darknet detector train data/<model>_<resolution>_<epochs>_<dataset folder>.data cfg/<model>_<resolution>_<epochs>_<dataset folder>_train.cfg <model>_<resolution>_<epochs>_<dataset folder>/<model>_<resolution>_<epochs>_<dataset folder>_final.weights -dont_show -map | tee <model>_<resolution>_<epochs>_<dataset folder>/log.txt
```



12. Create detections using this command. change parameters and paths as necessary. Run from inside the darknet directory. 

Final or best weights can be used. Best weights are saved during training, whereas final are the final weights. just replace \_final.weights with \_best.weights. 

```bash
./darknet detector test data/<model>_<resolution>_<epochs>_<dataset folder>.data cfg/<model>_<resolution>_<epochs>_<dataset folder>_detection.cfg <model>_<resolution>_<epochs>_<dataset folder>/<model>_<resolution>_<epochs>_<dataset folder>_final.weights -dont_show -ext_output -thresh 0.3 < ~/door_staircase_detection/dataset/<dataset folder>/valid.txt > ~/door_staircase_detection/dataset/<dataset folder>/results_<model>_<resolution>_<epochs>.txt
```

mAP can be checked using this command

```bash
./darknet detector map data/<model>_<resolution>_<epochs>_<dataset folder>.data cfg/<model>_<resolution>_<epochs>_<dataset folder>_detection.cfg <model>_<resolution>_<epochs>_<dataset folder>/<model>_<resolution>_<epochs>_<dataset folder>_final.weights -dont_show
```


13. Use draw\_bbox.py to draw ground truth boxes and predictions from dataset/\<dataset folder>/results\_\<model>\_\<resolution>\_\<epochs>.txt on images. saves them in dataset/\<dataset folder name>\/detection_results/\<model>\_\<resolution>\_\<epochs>

14. After training, extract the following files:  

  darknet/\<model>\_\<resolution>\_\<epochs>\_\<dataset folder>_best.weights 

  darknet/data/obj\_\<dataset folder>.names

  darknet/cfg/\<model>\_\<resolution>\_\<epochs>\_\<dataset folder>\_detection.cfg  

  Transfer these files to Xavier AGX.


# XAVIER AGX SETUP


**Folder layout for Xavier AGX**

```
--catkin_ws
    -- src
        -- darknet_ros
            -- darknet_ros
                -- config
                    -- ros.yaml
                    -- yolov3_trained.yaml
                -- launch
                    -- darknet_ros.launch
                    -- yolov3_trained.launch
                -- yolo_network_config
                    -- cfg
                        -- yolov3_trained.cfg
                    -- weights
                        -- yolov3_trained.weights
    -- staircase_doorway_detect_yolov3.sh                   
    -- libraries
        -- install-opencv.sh
        -- 3.4.2.zip
        -- boost_1_76_0.tar.bz2
```

(Continuing from training setup)

15. On the Xavier AGX, ensure ROS Melodic is installed (Other versions of ROS may use different instructions.) (http://wiki.ros.org/melodic/Installation/Ubuntu, make sure step 1.5 for bashrc config is done.)

```
echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc

source ~/.bashrc
```

16. Create a libraries folder. Install OpenCV (ver 3.4.2, contrib = NO) and boost C++ (https://www.boost.org/doc/libs/1_76_0/more/getting_started/unix-variants.html, need to manually download tar file). The most reliable way to get a copy of Boost is to download a distribution from SourceForge, download boost_1_76_0.tar.bz2 (latest on 29/7/21, https://www.boost.org/users/history/version_1_76_0.html)

  In the directory where you want to put the Boost installation, execute

```
/libraries/install-opencv.sh

tar --bzip2 -xf /libraries/boost_1_76_0.tar.bz2
cd /libraries/boost_1_76_0
./bootstrap.sh --prefix=path/to/installation/prefix
./b2 install
```

17. Clone and install leggedrobotics/darknet_ros for melodic

```
cd catkin_workspace/src
git clone --recursive --branch melodic https://github.com/leggedrobotics/darknet_ros.git
cd ../
```
18. Add compute architecture of Xavier AGX to catkin_ws/src/darknet_ros/darknet_ros/CMakeLists.txt. Xavier AGX uses arch 72 (https://en.wikipedia.org/wiki/CUDA#Supported_GPUs)

```
-gencode arch=compute_72,code=sm_72
```

19. Build darknet_ros. CXX flags needed (https://github.com/leggedrobotics/darknet_ros/issues/266#issuecomment-737075555)

```
catkin_make -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-DCV__ENABLE_C_API_CTORS
```  

20. In order to use your own detection objects you need to provide your weights and your cfg file inside the directories:

```
catkin_workspace/src/darknet_ros/darknet_ros/yolo_network_config/weights/
catkin_workspace/src/darknet_ros/darknet_ros/yolo_network_config/cfg/
```
  
  Currently, the yolov3_trained.weights and yolov3_trained.cfg is placed in these folders. These are weights and detection.cfg files extracted in step 14, just renamed.

21. Create your config file (for darknet_ros, based on names file extracted in step 14) for ROS where you define the names of the detection objects. You need to include it inside:

  catkin_workspace/src/darknet_ros/darknet_ros/config/____.yaml

  Currently, yolov3_trained.yaml is used, as shown below: 

```
yolo_model:

  config_file:
    name: yolov3_trained.cfg
  weight_file:
    name: yolov3_trained.weights
  threshold:
    value: 0.3
  detection_classes:
    names:
      - Closed Door
      - Open Door
      - Person
      - Stairs
```

Then in the launch file you have to point to your new config file in the line. We make another launch yaml that uses darknet_ros launch yaml, but points to the correct paths. For example, the file here points to yolov3_trained files used. arg name is also changed to point to correct camera topic published by camera. For our case, using Intel RealSense, topic name is camera/color/image_raw

(darknet_ros.launch might need absolute paths if relative paths throw an issue)

```
<?xml version="1.0" encoding="utf-8"?>
<launch>
  
  <rosparam command="load" ns="darknet_ros" file="$(find darknet_ros)/config/yolov3_trained.yaml"/>
  <!-- Use YOLOv3 -->
  <arg name="network_param_file"         default="$(find darknet_ros)/config/yolov3_trained.yaml"/>
  <arg name="image" default="camera/color/image_raw" />


  <!-- Include main launch file -->
  <include file="$(find darknet_ros)/launch/darknet_ros.launch">
    <arg name="network_param_file"    value="$(arg network_param_file)"/>
    <arg name="image" value="$(arg image)" />
  </include>

</launch>
```

22. Install RealSense ROS wrapper.

```
sudo apt-get install ros-$ROS_DISTRO-realsense2-camera
```

23. Put 99-rule file in correct directory for diagnosing failed to open usb interface issue (https://github.com/IntelRealSense/realsense-ros/issues/1408).

```
cd /etc/udev/rules.d/ 
wget https://github.com/IntelRealSense/librealsense/blob/master/config/99-realsense-libusb.rules
```

24. Change topic in darknet_ros/config/ros.yaml. 

```
  camera_reading:
    topic: /camera/color/image_raw
    queue_size: 1
```
25. Install tmux, and use the /catkin_ws/staircase_doorway_detect_yolov3.sh script to launch roscore, darknet_ros and realsense (To confirm realsense is being detected. rviz can be used as realsense likes to push temperature or control issues in terminal but actually publishes the image).

```
sudo apt install tmux
catkin_ws/staircase_doorway_detect_yolov3.sh
```

**issues that may arise, helpful links**

Project ‘cv_\bridge‘ specifies ‘/usr/include/opencv‘ as an include dir, which is not found: https://github.com/ros-perception/vision\_opencv/issues/389

darknet-master seem uses pkg-config to locate the lib of opencv4 (darknet-master/Makefile) however in opencv-4.1.0/CMakeLists.txt, it is deprecated - -，you need set the flag ON: https://github.com/pjreddie/darknet/issues/1494#issuecomment-629905519


________________________________________________________________________________
**How to train with multi-GPU**

Train it first on 1 GPU for like 1000 iterations: darknet.exe detector train cfg/coco.data cfg/yolov4.cfg yolov4.conv.137

Then stop and by using partially-trained model /backup/yolov4_1000.weights run training with multigpu (up to 4 GPUs): 
```bash
darknet.exe detector train cfg/coco.data cfg/yolov4.cfg /backup/yolov4_1000.weights -gpus 0,1,2,3
```
If you get a Nan, then for some datasets better to decrease learning rate, for 4 GPUs set learning_rate = 0,00065 (i.e. learning_rate = 0.00261 / GPUs). In this case also increase 4x times burn_in = in your cfg-file. I.e. use burn_in = 4000 instead of 1000.



**ZED_CAMERA=1** to build a library with ZED-3D-camera support (should be ZED SDK installed), then run LD_LIBRARY_PATH=./:$LD_LIBRARY_PATH ./uselib data/coco.names cfg/yolov4.cfg yolov4.weights zed_camera


