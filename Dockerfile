#https://docs.docker.com/reference/dockerfile/

# 每条保留字指令都必须为大写字母且后面要跟随至少一个参数
# 指令按照从上到下，顺序执行
# # 表示注释
# 每条指令都会创建一个新的镜像层，并对镜像进行提交


# FROM         # 基础镜像，当前新镜像是基于哪个镜像的
# MAINTAINER   # 镜像维护者的姓名混合邮箱地址
# RUN          # 容器构建时需要运行的命令
# EXPOSE       # 当前容器对外保留出的端口
# WORKDIR      # 指定在创建容器后，终端默认登录的进来工作目录，一个落脚点
# ENV          # 用来在构建镜像过程中设置环境变量
# ADD          # 将宿主机目录下的文件拷贝进镜像且ADD命令会自动处理URL和解压tar压缩包
# COPY         # 类似ADD，拷贝文件和目录到镜像中！
# VOLUME       # 容器数据卷，用于数据保存和持久化工作
# CMD          # 指定一个容器启动时要运行的命令，dockerFile中可以有多个CMD指令，
               # 但只有最后一个生效！
# ENTRYPOINT   # 指定一个容器启动时要运行的命令！和CMD一样
# ONBUILD      # 当构建一个被继承的DockerFile时运行命令，
               # 父镜像在被子镜像继承后，父镜像的ONBUILD被触发



#    编写思路               
# 1.基于一个空的镜像
# 2.下载需要的环境 ADD
# 3.执行环境变量的配置 ENV
# 4.执行一些Linux命令 RUN
# 5.日志 CMD
# 6.端口暴露 EXPOSE
# 7.挂载数据卷 VOLUMES
            



#ubuntu22.04
FROM ros:humble-ros-base
LABEL  authors="YD07"


ENV DEBIAN_FRONTEND=noninteractive

# create workspace
RUN cd 
RUN mkdir -p /ma_auto_aim/ros_ws/src
RUN mkdir -p /ma_auto_aim/environment
WORKDIR /ma_auto_aim/

RUN cd ./ros_ws/src && git clone https://github.com/YD07-xyt/ma_auto_aim_main.git \
    && mv ./ma_auto_aim/environment/mindvision  ../../environment

RUN cd ../environment


# 更新软件源并安装基础工具
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    libopencv-dev \
    libeigen3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*


# 安装openvino
RUN wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    && apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    # Ubuntu 22
    && echo "deb https://apt.repos.intel.com/openvino ubuntu22 main" | sudo tee /etc/apt/sources.list.d/intel-openvino.list \
    && apt update \
    && apt-cache search openvino \
    && apt install openvino-2025.2.0 \
    && rm -rf /var/lib/apt/lists/*

RUN cd ../mindvision \
    && chmod +x install.sh \
    && ./install.sh \
    && rm -rf /var/lib/apt/lists/*

RUN cd ../

# 安装camera-info-manager包,xacro包
RUN apt-get update && apt-get install -y \
    ros-humble-camera-info-manager \
    ros-humble-xacro \
    && rm -rf /var/lib/apt/lists/*


# 安装fmt库
RUN apt-get update && apt-get install -y \
    libfmt-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装Sophus（李群李代数库，使用模板版本）
RUN git clone https://github.com/strasdat/Sophus.git /Sophus \
    && cd /Sophus \
    && git checkout a621ff \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc) \
    && make install \
    && rm -rf /Sophus

# 安装g2o（图优化库）
RUN sudo apt install -y \
    libspdlog-dev \
    libsuitesparse-dev \
    qtdeclarative5-dev \
    qt5-qmake \
    libqglviewer-dev-qt5 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/RainerKuemmerle/g2o \
    && cd g2o \
    && mkdir build && cd build \
    && cmake ..\
    && make -j$(nproc) \
    && make install 

# 安装Ceres Solver
RUN apt-get update && apt-get install -y \
    libceres-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装foxglove-bridge（ROS 2官方包）
RUN apt-get update && apt-get install -y \
    ros-humble-foxglove-bridge \
    && rm -rf /var/lib/apt/lists/*

# 恢复交互模式默认值
ENV DEBIAN_FRONTEND=

# 设置工作目录
WORKDIR /ros2_ws

# 启动命令（可选，默认进入bash）
CMD ["bash"]
