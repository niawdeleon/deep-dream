# Deep Dream Scripts and Notes

## Making Deep Dream Work on Video

1. Setup the instance using a pre-built AMI on Virgina (US East).
http://tleyden.github.io/blog/2014/10/25/cuda-6-dot-5-on-aws-gpu-instance-running-ubuntu-14-dot-04/

When using a pre-built AMI, most of the steps in the page above are no longer necessary.

2. Setup Docker and the GPU-enabled Caffe container. This is the actual container that we'll use but most of the scripts we need are in another container, which we'll install in step 3.
http://tleyden.github.io/blog/2014/10/25/running-caffe-on-aws-gpu-instance-via-docker/

3. Setup the dockerized Deep Dream guide below.

```bash
git clone https://github.com/VISIONAI/clouddream.git
```

In the scripts, replace the image used by deepdream-compute with tleyden5iwx/caffe-gpu-master since the VISIONAI's container is NOT GPU-enabled.
However instead of using the provided visionai/clouddream docker image, I used the tleyden5iwx/caffe-gpu-master image

4. Modify deepdream.py by adding these lines:

```python
caffe.set_device(0
)
caffe.set_mode_gpu()
```

5. The caffe-gpu-master image, though it supports GPU via CUDA, doesn’t have the needed Caffe model.

so you need to wget that into the /opt/caffe/models/bvlc_googlenet/ folder inside the container

```bash
cd /opt/caffe/models/bvlc_googlenet/
wget http://dl.caffe.berkeleyvision.org/bvlc_googlenet.caffemodel
```

6. To get inside the docker file with GPU support and with the deepdream folder mounted properly:
```bash
docker run -ti --rm  --name deepdream-gpu --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm -v ~/clouddream/deepdream:/opt/deepdream tleyden5iwx/caffe-gpu-master /bin/bash
```

7. To process the video, use process_video.sh in this repo.
