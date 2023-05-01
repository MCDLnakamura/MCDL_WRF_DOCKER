#
FROM centos:7
# MAINTAINER John Exby <exby@ucar.edu>
#
ENV WRF_VERSION 4.5
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
# Added by Nakamura
RUN yum -y install vim git unzip java
#
RUN groupadd -g 9999 wrf && \
    useradd -m -u 9999 -g 9999 wrfuser && \
    echo "wrfuser  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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
# RUN mkdir /wrf/.ssh ; echo "StrictHostKeyChecking no" > /wrf/.ssh/config
COPY default-mca-params.conf /wrf/.openmpi/mca-params.conf
RUN mkdir -p /wrf/.openmpi
RUN chown -R wrfuser:wrf /wrf/
# RUN echo "root    ALL=(ALL)     ALL" >> /etc/sudoers
#
#
# all root steps completed above, now below as regular userID wrfuser
# USER wrfuser
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
RUN cp -r /wrf/WRF /wrf/WRFDA
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
VOLUME /wrf
#