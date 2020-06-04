FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04 as build-env

ADD . /AQ
WORKDIR /AQ

RUN apt update && apt-get install -y --no-install-recommends \
  build-essential \
  libnvinfer-dev \
  libnvonnxparsers-dev \
  libnvparsers-dev \
  libnvinfer-plugin-dev \
  wget

RUN make -j $(grep -c ^processor /proc/cpuinfo)

RUN mkdir ./data \
    && wget -nv -P ./data https://github.com/ymgaq/AQ/releases/download/v4.0.0/AQ_linux.tar.gz \
    && tar xzf ./data/AQ_linux.tar.gz -C ./data


FROM nvidia/cuda:10.2-cudnn7-runtime-ubuntu18.04
WORKDIR /AQ

RUN apt update && apt-get install -y --no-install-recommends \
  libnvinfer7 \
  libnvonnxparsers7 \ 
  libnvparsers7 \
  libnvinfer-plugin7

COPY --from=build-env /AQ/AQ /AQ/AQ
COPY --from=build-env /AQ/config.txt /AQ/config.txt
COPY --from=build-env /AQ/prob /AQ/prob
COPY --from=build-env /AQ/data/AQ/engine /AQ/engine

CMD ./AQ --lizzie

