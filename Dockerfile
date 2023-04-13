FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /root

RUN apt-get update \
  && apt install -y iputils-arping iputils-ping iputils-tracepath git \
     vim make iproute2 sudo apt-transport-https ca-certificates curl \
     gnupg-agent software-properties-common wget python3 gcc g++ python3-dev \
     python3-pip openssh-client openssh-server dumb-init cmake \
  && systemctl disable ssh.service \
  && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo "export LANG=C.UTF-8" >> /etc/profile \
  && apt clean

RUN git clone https://github.com/jeffyjf/ceph.git && cd /root/ceph/ && git checkout v17.2.5 -b v17.2.5 && ./install-deps.sh && ./make-dist

RUN mkdir /root/ceph/build && cd /root/ceph/build && cmake -GNinja -DWITH_SPDK=ON -DWITH_RBD_SSD_CACHE=ON -DWITH_RBD_MIRROR=ON .. && ninja

RUN mkdir -p /var/run/sshd && chown root:root / && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

USER root
ENTRYPOINT ["dumb-init", "--"]
CMD ["/usr/sbin/sshd", "-D"]
