#
FROM centos:7
# MAINTAINER John Exby <exby@ucar.edu>
# 
RUN curl -SL https://ral.ucar.edu/sites/default/files/public/projects/ncar-docker-wrf/ucar-bsd-3-clause-license.pdf > /UCAR-BSD-3-Clause-License.pdf
#
ENV WRF_VERSION 4.3.3
ENV WPS_VERSION 4.0.2
ENV NML_VERSION 4.0.2
#
# Set up base OS environment
#
RUN yum -y update
RUN yum -y install file gcc gcc-gfortran gcc-c++ glibc.i686 libgcc.i686 libpng-devel jasper \
  jasper-devel hostname m4 make perl tar bash tcsh time wget which zlib zlib-devel \
  openssh-clients openssh-server net-tools fontconfig libgfortran libXext libXrender ImageMagick sudo epel-release
#
# now get 3rd party EPEL builds of netcdf and openmpi dependencies
RUN yum -y install netcdf-openmpi-devel.x86_64 netcdf-fortran-openmpi-devel.x86_64 \
    netcdf-fortran-openmpi.x86_64 hdf5-openmpi.x86_64 openmpi.x86_64 openmpi-devel.x86_64 \
   && yum clean all
#
RUN mkdir -p /var/run/sshd \
    && ssh-keygen -A \
    && sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
#
RUN groupadd -g 9999 wrf && \
    useradd -m -s /bin/bash -u 9999 -g 9999 wrfuser && \
    echo wrfuser:wrfuser | chpasswd && \
    echo "wrfuser  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
#
# RUN groupadd wrf -g 9999
# RUN useradd -u 9999 -g wrf -G wheel -M -d /wrf wrfuser
#

RUN mkdir /wrf \
 &&  chown -R wrfuser:wrf /wrf \
 &&  chmod 6755 /wrf

RUN mkdir -p  /wrf/WPS_GEOG /wrf/wrfinput /wrf/wrfoutput \
 &&  chown -R wrfuser:wrf /wrf /wrf/WPS_GEOG /wrf/wrfinput /wrf/wrfoutput /usr/local \
 &&  chmod 6755 /wrf /wrf/WPS_GEOG /wrf/wrfinput /wrf/wrfoutput /usr/local

# Set environment for interactive container shells
#
RUN echo export LDFLAGS="-lm" >> /etc/bashrc \
 && echo export NETCDF=/wrf/netcdf_links >> /etc/bashrc \
 && echo export JASPERINC=/usr/include/jasper/ >> /etc/bashrc \
 && echo export JASPERLIB=/usr/lib64/ >> /etc/bashrc \
 && echo export LD_LIBRARY_PATH="/usr/lib64/openmpi/lib" >> /etc/bashrc \
 && echo export PATH=".:/usr/lib64/openmpi/bin:$PATH" >> /etc/bashrc \
 && echo setenv LDFLAGS "-lm" >> /etc/csh.cshrc \
 && echo setenv NETCDF "/wrf/netcdf_links" >> /etc/csh.cshrc \
 && echo setenv JASPERINC "/usr/include/jasper/" >> /etc/csh.cshrc \
 && echo setenv JASPERLIB "/usr/lib64/" >> /etc/csh.cshrc \
 && echo setenv LD_LIBRARY_PATH "/usr/lib64/openmpi/lib" >> /etc/csh.cshrc \
 && echo setenv PATH ".:/usr/lib64/openmpi/bin:$PATH" >> /etc/csh.cshrc
#
#
RUN mkdir /wrf/.ssh ; echo "StrictHostKeyChecking no" > /wrf/.ssh/config
COPY default-mca-params.conf /wrf/.openmpi/mca-params.conf
RUN mkdir -p /wrf/.openmpi
RUN chown -R wrfuser:wrf /wrf/
# RUN echo "root    ALL=(ALL)     ALL" >> /etc/sudoers
#
# Dockerfileファイル中に以下のような記述を追加し、8080番ポートを公開する
# EXPOSE 8080
#
# all root steps completed above, now below as regular userID wrfuser
USER wrfuser
WORKDIR /wrf
#
#
RUN curl -SL http://www2.mmm.ucar.edu/wrf/src/wps_files/geog_low_res_mandatory.tar.gz | tar -xzC /wrf/WPS_GEOG
#
# RUN curl -SL https://www2.mmm.ucar.edu/wrf/TUTORIAL_DATA/colorado_march16.tar.gz | tar -xzC /wrf/wrfinput
#
RUN curl -SL http://www2.mmm.ucar.edu/wrf/src/namelists_v$NML_VERSION.tar.gz  | tar -xzC /wrf/wrfinput
#
# Download wrf and wps source, Version 4.0 and later
RUN curl -SL https://github.com/wrf-model/WPS/archive/v$WPS_VERSION.tar.gz | tar zxC /wrf \
 && curl -SL https://github.com/wrf-model/WRF/archive/v$WRF_VERSION.tar.gz | tar zxC /wrf
RUN mv /wrf/WPS-$WPS_VERSION /wrf/WPS
RUN mv /wrf/WRF-$WRF_VERSION /wrf/WRF
ENV NETCDF_classic 1
#
# 
 RUN mkdir netcdf_links \
  && ln -sf /usr/include/openmpi-x86_64/ netcdf_links/include \
  && ln -sf /usr/lib64/openmpi/lib netcdf_links/lib \
  && export NETCDF=/wrf/netcdf_links \
  && export JASPERINC=/usr/include/jasper/ \
  && export JASPERLIB=/usr/lib64/ 

ENV LD_LIBRARY_PATH /usr/lib64/openmpi/lib
ENV PATH  /usr/lib64/openmpi/bin:$PATH
#
#
RUN ssh-keygen -f /wrf/.ssh/id_rsa -t rsa -N '' \
    && chmod 600 /wrf/.ssh/config \
    && chmod 700 /wrf/.ssh \
    && cp /wrf/.ssh/id_rsa.pub /wrf/.ssh/authorized_keys
#
#
VOLUME /wrf
CMD ["/bin/bash"]
#

RUN sudo yum install -y vim