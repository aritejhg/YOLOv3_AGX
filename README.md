# YOLOv3_AGX
An implementation of YOLOv3 on NVIDIA AGX. Includes my implementation of dataset creation using Google OpenImages

# readme.md
This project focuses on training a YOLO model on custom database with custom set of classes using alexeyab/darknet and google openimages. 

It provides a way to download images (without annotations, loko at OiD toolkit if annotations are needed) and train dataset on the yolo model. 

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

## GO TO XAVIER AGX BRANCH FOR IMPLEMENTATION

________________________________________________________________________________
**How to train with multi-GPU**

Train it first on 1 GPU for like 1000 iterations: darknet.exe detector train cfg/coco.data cfg/yolov4.cfg yolov4.conv.137

Then stop and by using partially-trained model /backup/yolov4_1000.weights run training with multigpu (up to 4 GPUs): 
```bash
darknet.exe detector train cfg/coco.data cfg/yolov4.cfg /backup/yolov4_1000.weights -gpus 0,1,2,3
```
If you get a Nan, then for some datasets better to decrease learning rate, for 4 GPUs set learning_rate = 0,00065 (i.e. learning_rate = 0.00261 / GPUs). In this case also increase 4x times burn_in = in your cfg-file. I.e. use burn_in = 4000 instead of 1000.



**ZED_CAMERA=1** to build a library with ZED-3D-camera support (should be ZED SDK installed), then run LD_LIBRARY_PATH=./:$LD_LIBRARY_PATH ./uselib data/coco.names cfg/yolov4.cfg yolov4.weights zed_camera


