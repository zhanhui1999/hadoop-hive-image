FROM ubuntu:20.04




RUN  mkdir -p /opt/software \
	&& mkdir -p /opt/module \
	&& echo "root:graphscope" | chpasswd \
	&& apt update \
	&& apt install openssh-server -y  \
	&& apt install openssh-client -y \
	&& mkdir -p /home/root/.ssh \
	&& apt install sshpass




RUN touch /etc/profile.d/myenv.sh
RUN echo 'JAVA_HOME=/opt/module/jdk1.8.0_212' >> /etc/profile.d/myenv.sh
RUN echo 'HADOOP_HOME=/opt/module/hadoop-3.2.0' >> /etc/profile.d/myenv.sh
RUN echo 'HIVE_HOME=/opt/module/apache-hive-3.1.2-bin' >> /etc/profile.d/myenv.sh
RUN echo 'PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$PATH' >> /etc/profile.d/myenv.sh


RUN echo '\n\n\n\n' | ssh-keygen
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config			#允许root用户登录
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config		#跳过Host检查
COPY --chown=root:root jdk-8u212-linux-x64.tar.gz /opt/software/
COPY --chown=root:root hadoop-3.2.0.tar.gz /opt/software/
COPY --chown=root:root apache-hive-3.1.2-bin.tar.gz /opt/software/

RUN tar -zxvf /opt/software/jdk-8u212-linux-x64.tar.gz -C /opt/module \
	&& rm -rf /opt/software/jdk-8u212-linux-x64.tar.gz

RUN tar -zxvf /opt/software/hadoop-3.2.0.tar.gz -C /opt/module \
	&& rm -rf /opt/software/hadoop-3.2.0.tar.gz
	
RUN tar -zxvf /opt/software/apache-hive-3.1.2-bin.tar.gz -C /opt/module \
	&& rm -rf /opt/software/apache-hive-3.1.2-bin.tar.gz

COPY --chown=root:root mysql-connector-java-8.0.13.jar /opt/module/apache-hive-3.1.2-bin/lib
RUN mv /opt/module/apache-hive-3.1.2-bin/lib/log4j-slf4j-impl-2.10.0.jar /opt/module/apache-hive-3.1.2-bin/lib/log4j-slf4j-impl-2.10.0.bak 

ENV JAVA_HOME=/opt/module/jdk1.8.0_212
ENV HADOOP_HOME=/opt/module/hadoop-3.2.0
ENV HIVE_HOME=/opt/module/apache-hive-3.1.2-bin
ENV PATH=$JAVA_HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$PATH

RUN rm -rf /opt/module/hadoop-3.2.0/etc/hadoop/core-site.xml
RUN rm -rf /opt/module/hadoop-3.2.0/etc/hadoop/yarn-site.xml
RUN rm -rf /opt/module/hadoop-3.2.0/etc/hadoop/hdfs-site.xml
RUN rm -rf /opt/module/hadoop-3.2.0/etc/hadoop/mapred-site.xml
RUN rm -rf /opt/module/hadoop-3.2.0/etc/hadoop/hadoop-env.sh
COPY hadoop/core-site.xml /opt/module/hadoop-3.2.0/etc/hadoop/
COPY hadoop/yarn-site.xml /opt/module/hadoop-3.2.0/etc/hadoop/
COPY hadoop/hdfs-site.xml /opt/module/hadoop-3.2.0/etc/hadoop/
COPY hadoop/mapred-site.xml /opt/module/hadoop-3.2.0/etc/hadoop/
COPY hadoop/hadoop-env.sh /opt/module/hadoop-3.2.0/etc/hadoop/
COPY hive/hive-site.xml /opt/module/apache-hive-3.1.2-bin/conf


EXPOSE 10000
EXPOSE 9000
EXPOSE 9870
EXPOSE 8088
EXPOSE 9868
EXPOSE 22


#RUN echo '\n\n\n\n' | ssh-keygen -t rsa -f /etc/ssh/myssh
#RUN echo 'graphscope' | ssh-copy-id -i /etc/ssh/myssh/.ssh/id_rsa.pub hadoop
RUN echo '#!/bin/bash' >> /opt/run.sh
RUN echo 'service ssh start' >> /opt/run.sh
RUN echo 'sleep 3' >> /opt/run.sh
RUN echo 'source /etc/profile' >> /opt/run.sh
#ssh-copy-id命令没法使用echo指定输入，所以只能前面设置跳过host检查，这里使用sshpass指定输入root用户密码
RUN echo 'sshpass -p graphscope ssh-copy-id -i root@hadoop' >> /opt/run.sh	
RUN echo 'service ssh restart' >> /opt/run.sh
RUN echo 'sleep 3' >> /opt/run.sh
RUN echo '/opt/module/hadoop-3.2.0/bin/hadoop namenode -format' >> /opt/run.sh
RUN echo '/opt/module/hadoop-3.2.0/sbin/start-all.sh' >> /opt/run.sh
RUN echo 'schematool -initSchema -dbType mysql -verbose' >> /opt/run.sh
RUN echo 'nohup hive --service metastore &' >> /opt/run.sh
RUN echo 'nohup hive --service hiveserver2 &' >> /opt/run.sh
#开启beeline客户端，指定hiveserver2服务的主机和端口
RUN echo 'bash' >> /opt/run.sh
RUN chmod +x /opt/run.sh

CMD ["/opt/run.sh"]

