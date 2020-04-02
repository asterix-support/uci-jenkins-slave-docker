FROM centos:7

USER root

RUN yum install -y openssh-server openssh-clients unzip git which java-1.8.0-openjdk-headless python3 python3-pip

# Set up for SSH daemon
RUN sed -ri -e 's/UsePAM yes/#UsePAM yes/g' \
            -e 's/#UsePAM no/UsePAM no/g' \
            -e 's/^GSS/#GSS/' \
            -e '/ssh_host_ed25519_key/d' \
            /etc/ssh/sshd_config && \
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa && \
    ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
    ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa

#            -e 's@#HostKey /etc/ssh/ssh_host_dsa_key@HostKey /etc/ssh/ssh_host_dsa_key@g' \

# JDK.
ENV JAVA_HOME=/usr/java/latest

# create jenkins user
RUN groupadd -g1000 jenkins && \
    useradd jenkins -g jenkins -u1000 -m -s /bin/bash && \
    echo "jenkins:$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo)" | chpasswd

COPY startup.sh /usr/sbin/
COPY ssh/* /home/jenkins/.ssh/
RUN chown -R jenkins:jenkins /home/jenkins/.ssh && \
    chmod 600 /home/jenkins/.ssh/*

# Configure password-less ssh for user jenkins
USER jenkins 
RUN ssh-keygen -q -t rsa -P "" < /dev/zero && \
    cat /home/jenkins/.ssh/id_rsa.pub >> /home/jenkins/.ssh/authorized_keys && \
    chmod 600 /home/jenkins/.ssh/authorized_keys

# Configure the Jenkins non-interactive logins with UTF-8
RUN echo "export LANG=en_US.UTF-8" >> /home/jenkins/.bashrc

USER root
ENTRYPOINT [ "/usr/sbin/startup.sh" ]
CMD [ "default" ]
EXPOSE 22 8000-8003

