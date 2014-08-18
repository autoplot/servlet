#!/bin/bash
# Usage: sudo ./install-sun-java6.sh

# Install 64-bit Sun JDK and JRE on linux

#Simple method that works on Ubuntu 10.04
#sudo add-apt-repository "deb http://archive.canonical.com/ lucid partner"
#sudo apt-get update
#sudo apt-get install sun-java6-jdk sun-java6-jre sun-java6-bin sun-java6-plugin

# Works on Ubuntu 10.04 and later.
# Shoud add an "update alternatives" instead of doing ln -s
# Need to log-in to Oracle site to download Java 6 so use copies here.

# JRE
VER=38
if [ ! -d "/usr/lib/jvm/jre1.6.0_$VER" ]; then
    chmod u+x jre-6u$VER-linux-x64.bin
    ./jre-6u$VER-linux-x64.bin
    mkdir -p /usr/lib/jvm
    mv jre1.6.0_$VER /usr/lib/jvm
fi

ln -sf /usr/lib/jvm/jre1.6.0_$VER/ /usr/lib/jvm/java-6-sun/
ln -sf /usr/lib/jvm/jre1.6.0_$VER/bin/java /usr/bin/java
ln -sf /usr/lib/jvm/jre1.6.0_$VER/bin/javaws /usr/bin/javaws

# JDK
VER=37 
if [ ! -d "/usr/lib/jvm/jdk1.6.0_$VER" ]; then
    chmod u+x jdk-6u$VER-linux-x64.bin
    ./jdk-6u$VER-linux-x64.bin
    mkdir -p /usr/lib/jvm
    mv jdk1.6.0_$VER /usr/lib/jvm/
fi
ln -sf /usr/lib/jvm/jdk1.6.0_$VER/bin/javac /usr/bin/javac
ln -sf /usr/lib/jvm/jdk1.6.0_$VER /usr/lib/jvm/java-6-sun/jdk
ln -sf /usr/lib/jvm/jdk1.6.0_$VER /usr/lib/jvm/java-6-sun/jdk


