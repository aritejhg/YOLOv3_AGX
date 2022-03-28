#csv_downloader.py, inspired from https://github.com/EscVM/OIDv4_ToolKit/blob/master/modules/csv_downloader.py
import os
import sys
import time
import urllib.request
import pandas as pd
from pathlib import Path

OID_URL = 'https://storage.googleapis.com/openimages/2018_04/'

def csv(file, csv_dir):
    '''
    Check the presence of the required .csv files.
    :param file: .csv file
    :param csv_dir: folder of the .csv files
    :return: None
    '''
    if not os.path.isfile(os.path.join(csv_dir, file)) or os.stat((os.path.join(csv_dir, file))).st_size < 5:
        print("Missing the {} file.".format(os.path.basename(file)))
        ans = input("Do you want to download the missing file? [Y/n] ")

        if ans.lower() == 'y':
            folder = str(os.path.basename(file)).split('-')[0]
            if folder != 'class':
                FILE_URL = str(OID_URL + folder + '/' + file)
            else:
                FILE_URL = str(OID_URL + file)

            FILE_PATH = os.path.join(csv_dir, file)
            with open(FILE_PATH,'w') as create_file:
              pass
            #needed as csv is only copied from the urllib command later
            create_file.close()
            save(FILE_URL, FILE_PATH)
            print('\n' + "File {} downloaded into {}.".format(file, FILE_PATH))

        else:
            exit(1)

def save(url, filename):
    '''
    Download the .csv file.
    :param url: Google url for download .csv files
    :param filename: .csv file name
    :return: None
    '''
    urllib.request.urlretrieve(url, filename, reporthook)

def reporthook(count, block_size, total_size):
    '''
    Print the progression bar for the .csv file download.
    :param count:
    :param block_size:
    :param total_size:
    :return:
    '''
    global start_time
    if count == 0:
        start_time = time.time()
        return
    duration = time.time() - start_time
    progress_size = int(count * block_size)
    speed = int(progress_size / ((1024 * duration) + 1e-5))
    percent = int(count * block_size * 100 / (total_size + 1e-5))
    sys.stdout.write("\r...%d%%, %d MB, %d KB/s, %d seconds passed" %
                     (percent, progress_size / (1024 * 1024), speed, duration))
    sys.stdout.flush()
home_path = str(Path(__file__).absolute()).rstrip('csv_downloader.py')
csv('train-annotations-human-imagelabels.csv',home_path)
csv('class-descriptions.csv',home_path)

print ("appending header to class-description.csv")
#append header to class-descriptions.csv
class_df=pd.read_csv(home_path + 'class-descriptions.csv', header=None)
class_df.to_csv(home_path + 'class-descriptions.csv', header = ['label', 'class_name'])

#remove confidence 0 from annotations
print ("cleaning annotations csv")
annotations_df = pd.read_csv(home_path + 'train-annotations-human-imagelabels.csv')
annotations_df = annotations_df[annotations_df.Confidence != 0]
annotations_df.to_csv(home_path + 'train-annotations-human-imagelabels.csv', index=False)
