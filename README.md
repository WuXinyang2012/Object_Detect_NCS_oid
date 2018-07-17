Transfer learning on ssd_mobilenet_v1 based on customized dataset from OpenImages Dataset.
Then using OpenVINO SDK to make it runable on Movidius Neural Compute Stick, which can be useful on embedded system deployment.  
****

#Prerequirements:  
Movidius Neural Compute Stick  
Ubuntu 16.04  
Tensorflow (version>1.5)  
Tensorflow object detect API
OpenVINO SDK (version = R2018 R2)
***
All the scripts are tested with Python3.6 + Tensorflow-1.7.0.  
##2, Download customized dataset and transform into tfrecord;  
##3, Set up OpenVINO SDK; 
##4, Introduce how to compile ssd_mobinet_v1 for NCS with OpenVINO;  
##5, Transfer Learning on ssd_mobinet_v1.  

#1, Download customized dataset and transform into tfrecord 

    python3 oid_tfrecord_by_name.py 	

You can specify the category name in Line.16 to download and transform your own dataset.
This script will cost more time when first run, since it needs to download additional csv files for dataset. These files would only be downloaded once.

After downloading all categories, you need to merge them into one directory for usage.  
One example .sh is shown in combine_tfrecord.sh. 

#2, Use OpenVIO to compile ssd_mobinet_v1 for VPU usage.  
Assume you have already set up OpenVINO well (notice that the envirnoment variables have also been set), then first download frozen model.  
    wget http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v1_coco_2017_11_17.tar.gz
    tar -zxvf ssd_mobilenet_v1_coco_11_06_2017.tar.gz
    cd /(path_to_OpenVINO)/deployment_tools/model_optimizer
    python3 mo_tf.py --input_model /(path_to_your_frozen_model)/frozen_inference_graph.pb --output_dir /(Specify_your_path) --tensorflow_use_custom_operations_config extensions/front/tf/ssd_support.json --output="detection_boxes,detection_scores,num_detections" --data_type FP16
    cd /(path_to_OpenVINO)/deployment_tools/inference_engine/samples/python_samples/
    python3 object_detection_demo_ssd_async.py -i cam -m /(path_to_your_IRmodels)/frozen_inference_graph.xml -d MYRIAD

Then you can find a detect demo with ~9 FPS.



