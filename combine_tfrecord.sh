#!/bin/bash

cp ./Apple/test/Apple.tfrecord ./tfrecord/train/oid.record-1
cp ./Banana/test/Banana.tfrecord ./tfrecord/train/oid.record-2
cp ./Orange/test/Orange.tfrecord ./tfrecord/train/oid.record-3

cp ./Apple/val/Apple.tfrecord ./tfrecord/test/oid.record-1
cp ./Banana/val/Banana.tfrecord ./tfrecord/test/oid.record-2
cp ./Orange/val/Orange.tfrecord ./tfrecord/test/oid.record-3
