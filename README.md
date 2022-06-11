# Description
  一键部署Hadoop+Hive环境，由于是伪集群，仅适用于个人学习和本地项目。镜像中不包括数据库，所以请指定metastore服务所需连接的数据库URL。默认启动hiveserver2服务，可以使用远程连接，端口是10000。

# 应用的下载
  应用包括Hadoop、Hive、JDK、mysql驱动。下载下来解压到项目的根目录。
  链接: https://pan.baidu.com/s/165vW7n4-35yeRAMyf96qiw 提取码: rqd7 

# 构建镜像
  构建镜像之前请先修改hadoop和hive当中的配置文件，根据本地环境。其中hive文件夹中关于数据的URL、账号、密码部分请一定修改。
  `[sudo] docker build -t {image_name}:{tags_name} ./`
 
 # 运行容器
  `sudo docker run -itd -p 9870:9870 -p 8088:8088 -p 9868:9868 -p 10000:10000 --hostname hadoop --name hadoop_gs {image}`
  hostname要指定为Dockerfile中指明的主机名字。默认是hadoop。
