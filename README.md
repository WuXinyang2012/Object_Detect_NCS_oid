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

#1, Download customized dataset and transform into tfrecord

    python3 oid_tfrecord_by_name.py 	

You can specify the category name in Line.16 to download and transform your own dataset.
This script will cost more time when first run, since it needs to download additional csv files for dataset. These files would only be downloaded once.

After downloading all categories, you need to merge them into one directory for usage.  
One example .sh is shown in combine_tfrecord.sh. 
****

#2, Use OpenVIO to compile ssd_mobinet_v1 for VPU usage.  
After the regular installation of OpenVINO, you need to install additionally support for NCS

    cat <<EOF > 97-usbboot.rules    
    SUBSYSTEM=="usb", ATTRS{idProduct}=="2150", ATTRS{idVendor}=="03e7", GROUP="users", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"    
    SUBSYSTEM=="usb", ATTRS{idProduct}=="f63b", ATTRS{idVendor}=="03e7", GROUP="users", MODE="0666", ENV{ID_MM_DEVICE_IGNORE}="1"    
    EOF    
    sudo cp 97-usbboot.rules /etc/udev/rules.d/    
    sudo udevadm control --reload-rules    
    sudo udevadm trigger    
    sudo ldconfig    
    rm 97-usbboot.rules    

Then set up the environment:

    source /(path_to_OpenVINO)/bin/setupvars.sh     

Then first download frozen model.

    wget http://download.tensorflow.org/models/object_detection/ssd_mobilenet_v1_coco_2017_11_17.tar.gz        
    tar -zxvf ssd_mobilenet_v1_coco_2017_11_17.tar.gz    
    cd /(path_to_OpenVINO)/deployment_tools/model_optimizer    
    python3 mo_tf.py --input_model /(path_to_your_frozen_model)/frozen_inference_graph.pb --output_dir /(Specify_your_path) --tensorflow_use_custom_operations_config extensions/front/tf/ssd_support.json --output="detection_boxes,detection_scores,num_detections" --data_type FP16
    cd /(path_to_OpenVINO)/deployment_tools/inference_engine/samples/python_samples/    
    python3 object_detection_demo_ssd_async.py -i cam -m /(path_to_your_IRmodels)/frozen_inference_graph.xml -d MYRIAD    

Then you can find a detect demo with ~9 FPS.

#3, Transfer Learning on ssd_mobilenet_v1:    
For transfer learning, you need to specify two files: ssd_mobilenet_v1_retrain.config and label_map.pbtxt.     
##ssd_mobilenet_v1_retrain.config    
here you need to specify 5 paths inside this file for frozen model, dataset and label_map. They are commented out inside the file.    
##label_map.pbtxt    
Here specify the number, readable name and id of categories in your customized dataset.     

Then we can start transfer learning with tensorflow API.

    git clone https://github.com/tensorflow/models.git    
    cd models/research/object_detection
    python train.py --ligtostderr --pipeline_config_path=/(path_to_your_config)/ssd_mobilenet_v1_retrain.config --train_dir=/(path_to_log)
During training, you can use tensorboard to monitor the transfer learning:

    tensorboard --logdir=/(path_to_log)




