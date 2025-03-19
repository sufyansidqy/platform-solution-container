






# syntax = docker/dockerfile:1.2.0
#####################################################################################
#
# Description: This docker file creates a container for WLX
#
# Components:
#   - AIS server + WLX Solution
#
# Prerequisites:
#  - The following items must be provided/present when building the image:
#       1.)     ./resources/AML-WLF_VX.X.X.X/
#               - Directory containing the unpacked folder of WLX installer ( name format AML-WLF_VX.X.X.X - must match WLX_VERSION ARG )
#
#       2.)     ./resources/container-configuration
#               - Directory containing the WLX installer configuration files ( default provided, must match WLX version )
#
#       3.)     ./resources/license/license.lic
#               - Directory containing the solution/PS license.lic
#
#       4.)     ./resources/rpms/ (Optional)
#               - Directory containing the rmps to be installed when creating image
#
# Docker folder structure should be like:
#   ./resources
#        ├── AML-WLF_V*   (Downloaded through CI or script)
#        |   ├── bin
#        |   |   └── **/*.*
#        |   ├── conf
#        |   |   └── **/*.*
#        |   ├── image
#        |   |   └── **/*.*
#        |   ├── lib
#        |   |   └── **/*.*
#        |   └── utilities
#        |       └── **/*.*
#        ├── container-configuration
#        |   └── *.conf
#        ├── license
#        |   └── *.lic
#        └── rpms
#            └── *.rpm
#
#Originally written by CDD team
#Modified for WLX
#####################################################################################

#####################################################################################
# Build inputs
#####################################################################################
ARG WLX_VERSION=AML-WLF_V10.1.0.93
ARG FROM_IMAGE=ais:10.3.0.4
FROM $FROM_IMAGE AS BUILDER
#####################################################################################

#####################################################################################
# Setting variables
#####################################################################################
ENV HOME=/home/ais_user
ENV NLS_LANG=AMERICAN_AMERICA.AL32UTF8
ARG WLX_VERSION
ENV WLX_VERSION=$WLX_VERSION
LABEL WLX_VERSION=$WLX_VERSION
#####################################################################################

#####################################################################################
# Inject license for installation
#####################################################################################
USER ais_user
COPY --chown=ais_user:ais_user resources/license/license.lic $AIS_SERVER_DIR/Instances/actimize_server_1/license/license.lic
RUN sed -i 's!Configuration_Entry Key="License File Path" Value=""!Configuration_Entry Key="License File Path" Value="'$AIS_SERVER_DIR'/Instances/actimize_server_1/license/license.lic"!g' $AIS_SERVER_DIR/Instances/actimize_server_1/ais_config.xml
#####################################################################################

#####################################################################################
# Inject ActOne Utilities
#####################################################################################
USER ais_user
COPY --chown=ais_user:ais_user resources/actone-util/* /home/ais_user
#####################################################################################

#####################################################################################
# Install WLX
#####################################################################################
COPY --chown=ais_user:ais_user resources/$WLX_VERSION $HOME/$WLX_VERSION
COPY --chown=ais_user:ais_user resources/container-configuration $HOME/$WLX_VERSION/conf
RUN chmod -R 744 $HOME/$WLX_VERSION
RUN cd $HOME/$WLX_VERSION/bin && \
	$AIS_SERVER_DIR/instances_manager/instances_manager $AIS_SERVER_DIR start --name actimize_server_1 && \
    $HOME/$WLX_VERSION/bin/actimize-installer install -i "AIS Steps" && \
    $AIS_SERVER_DIR/instances_manager/instances_manager $AIS_SERVER_DIR stop --name actimize_server_1 && \
	rm $AIS_SERVER_DIR/Instances/actimize_server_1/license/license.lic
#####################################################################################

#####################################################################################
# Build final solution image
#####################################################################################
FROM $FROM_IMAGE AS FINAL
ARG WLX_VERSION
COPY --chown=ais_user:ais_user --from=BUILDER $AIS_SERVER_DIR/Add-Ons $AIS_SERVER_DIR/Add-Ons
COPY --chown=ais_user:ais_user --from=BUILDER $AIS_SERVER_DIR/Instances/actimize_server_1 $AIS_SERVER_DIR/Instances/actimize_server_1
LABEL WLX_VERSION=$WLX_VERSION
#####################################################################################

#####################################################################################
#Remove later when deploaying in K8
#####################################################################################
COPY --chown=ais_user:ais_user resources/license/license.lic $AIS_SERVER_DIR/Instances/actimize_server_1/license/license.lic
####################################################################################

#####################################################################################
# RPMs installation
#####################################################################################
USER root
RUN --mount=target=/opt/installs/rpms,type=bind,source=resources/rpms if [ "$(ls -A /opt/installs/rpms)" ]; then \
        yum -y install ${AIS_SERVER_INSTALL_DIR}/rpms/*.rpm; \
        yum -y install tar \
        yum --assumeyes clean all && rm -rf /var/cache/yum; \
    fi
######################################################################################

#####################################################################################
# Set workdir
#####################################################################################
USER ais_user
WORKDIR $AIS_SERVER_DIR
#####################################################################################

