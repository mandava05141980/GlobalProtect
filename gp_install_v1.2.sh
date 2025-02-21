#!/bin/bash
#Date:03122024
#Version:1.0
####Script supported to Ubuntu,RHEL,CentOS,Rocky OS############
# Determine command type
cmd_type="ui"
if [ $# -gt 0 ]; then
    case $1 in
        --cli-only)
            cmd_type="cli-only";;
        --arm)
            cmd_type="arm";;
        --help)
            ;&
        *)
            cmd_type="usage";;
    esac
fi

# Determine Linux Distro and Version
. /etc/os-release

if [ $ID == "ubuntu" ]; then
    linux_ver=${VERSION_ID:0:2}
elif [[ $ID == "rhel" || $ID == "centos" || $ID == "rocky" ]]; then
    linux_ver=${VERSION_ID:0:1}
fi

# Install resolvconf on Ubuntu only
if [ $ID == "ubuntu" ]; then
    apt-get install -y resolvconf > /dev/null
fi

case $cmd_type in
    cli-only)
        # CLI Only Install
        case $ID in
            ubuntu)
                case $linux_ver in
                    14|16|18)
                        ;;
                    *)
                        apt-get install -y ./GlobalProtect_deb*.deb;;
                esac
                ;;
            rhel)
                ;&
            rocky)
                ;&
            centos)
                # Check if old GP package installed
                yum_output=$(yum list installed | grep globalprotect)
                if [[ $yum_output == *"globalprotect.x86"* ]]; then
                    echo "Older globalprotect detected...uninstalling..."
                    yum -y remove globalprotect
                fi
                
                yum -y install ./GlobalProtect_rpm-*;;
            *)
                echo "Error: Unsupported Linux Distro: $ID"
                exit
                ;;
        esac
        ;;

    arm)
        # ARM Install
        case $ID in
            ubuntu)
                case $linux_ver in
                    14|16|18)
                        ;;
                    *)
                        apt-get install -y ./GlobalProtect_deb_arm*.deb;;
                esac
                ;;
            rhel)
                ;&
            rocky)
                ;&
            centos)
                # Check if old GP package installed
                yum_output=$(yum list installed | grep globalprotect)
                if [[ $yum_output == *"globalprotect_arm.x86"* ]]; then
                    echo "Older globalprotect detected...uninstalling..."
                    yum -y remove globalprotect_arm
                fi
                
                yum -y install ./GlobalProtect_rpm_arm*;;
            *)
                echo "Error: Unsupported Linux Distro: $ID"
                exit
                ;;
        esac
        ;;

    ui)
        # UI Install
        case $ID in
            ubuntu)
                apt-get install -y gnome-tweak-tool gnome-shell-extension-top-icons-plus
                gnome-extensions enable TopIcons@phocean.net;;
            rhel)
                ;&
            rocky)
                ;&
            centos)
                # Check if old GP package installed
                yum_output=$(yum list installed | grep globalprotect)
                if [[ $yum_output == *"globalprotect_UI.x86"* ]]; then
                    echo "Older globalprotect detected...uninstalling..."
                    yum -y remove globalprotect_UI
                fi
            
                # RHEL Package Dependencies
                if [ "$ID" = "centos" ] || [ "$ID" = "rocky" ]; then
                    yum -y install epel-release
                elif [ "$ID" = "rhel" ]; then
                    if [ "$linux_ver" = "7" ]; then
                        yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
                    elif [ "$linux_ver" = "8" ]; then
                        yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
                    elif [ "$linux_ver" = "9" ]; then
                        yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
                    else
                        echo "Error: Unsupported RHEL version: $linux_ver"
                        exit
                    fi
                else
                    echo "Error: Unrecognized OS: $ID"
                    exit
                fi

                echo "yum: Installing Qt5 WebKit and wmctrl..."
                yum -y install qt5-qtwebkit wmctrl

                # Install
                yum -y install ./GlobalProtect_UI_rpm-*;;
            *)
                echo "Error: Unsupported Linux Distro: $ID";;
        esac
        ;;
    usage)
        ;&
    *)
        echo "Usage: $ sudo ./gp_install [--cli-only | --arm | --help]"
        echo "  --cli-only: CLI Only"
        echo "  --arm:      ARM"
        echo "  no options: UI"
        ;;
esac
