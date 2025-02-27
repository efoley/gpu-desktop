#!/bin/bash
echo "$1"
echo "$2@$3"
ssh -i "$1" -l "$2" -t "$3" bash -c "'
sudo yum update -y
sudo setenforce 0
sudo yum install -y wget
sudo yum install -y epel-release
sudo yum groupinstall -y "MATE Desktop"
wget https://github.com/rncry/gpu-desktop/raw/master/VirtualGL-2.4.1.x86_64.rpm
wget https://github.com/rncry/gpu-desktop/raw/master/turbovnc-1.2.80.x86_64.rpm
sudo yum install -y libXaw libXmu libXt xauth xdpyinfo glx-utils libXp xterm xorg-x11-xdm  xorg-x11-fonts-100dpi xorg-x11-fonts-ISO8859-9-100dpi xorg-x11-fonts-misc xorg-x11-fonts-Type1 gcc kernel-devel libGLU

# this will give us OpenGL header files
sudo yum install -y mesa-libGL-devel

sudo rpm -ivh turbovnc-1.2.80.x86_64.rpm
sudo rpm -ivh VirtualGL-2.4.1.x86_64.rpm
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/346.47/NVIDIA-Linux-x86_64-346.47.run
chmod +x NVIDIA-Linux-x86_64-346.47.run
sudo ./NVIDIA-Linux-x86_64-346.47.run -s -Z
sudo reboot
'"

while ! ssh -i "$1" -l "$2" -t "$3" bash -c "echo 'hi world'" &>/dev/null; do :; done

ssh -i "$1" -l "$2" -t "$3" 'sudo yum groupinstall -y "X Window System"'

ssh -i "$1" -l "$2" -t "$3" bash -c "'
sudo setenforce 0
sudo ./NVIDIA-Linux-x86_64-346.47.run -s
sudo /opt/VirtualGL/bin/vglserver_config -config +s +f +t
wget https://github.com/rncry/gpu-desktop/raw/master/xorg.conf
sudo cp xorg.conf /etc/X11/xorg.conf
wget https://github.com/rncry/gpu-desktop/raw/master/.Xclients
chmod +x .Xclients
cp .Xclients ~$2/.
sudo reboot
'"

while ! ssh -i "$1" -l "$2" -t "$3" bash -c "echo 'hi world'" &>/dev/null; do :; done

ssh -i "$1" -l "$2" -t "$3" bash -c "'
sudo xinit &
echo "$4" | /opt/TurboVNC/bin/vncpasswd -f >> passwd
chmod 600 passwd
mkdir -p ~/.vnc
cp passwd ~/.vnc/
sudo reboot
'"

while ! ssh -i "$1" -l "$2" -t "$3" bash -c "echo 'hi world'" &>/dev/null; do :; done

ssh -i "$1" -l "$2" -t "$3" bash -c "'
sudo iptables -I INPUT -p tcp --dport 5901 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 5801 -j ACCEPT
sudo iptables-save
'"

ssh -i "$1" -l "$2" "$3" '/opt/TurboVNC/bin/vncserver'
