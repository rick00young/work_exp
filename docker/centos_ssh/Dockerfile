# Dockerfile文件内容
#基于centos镜像库创建
FROM centos
MAINTAINER dys
#安装ssh
RUN yum install -y openssh-server sudo
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN yum  install -y openssh-clients

#配置root名
RUN echo "root:123456" | chpasswd
RUN echo "root   ALL=(ALL)       ALL" >> /etc/sudoers
#生成ssh key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key

#配置sshd服务
RUN mkdir /var/run/sshd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]