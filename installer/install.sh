# Usage:
#        sudo bash install.sh install Port Server [User]
#        Installs Java, Tomcat, and AutoplotServlet in /usr/local
#        and starts AutoplotServlet on Port 8082.  Test is made
#        by requesting an image from Server:Port.

# If false, will ssh files to server.
LOCAL=true
INSTALLPATH=/usr/local

# Usage:
#        bash install.sh update Port Server
#        Updates and restarts AutoplotServlet on Server, Port 8082


# TODO:
# Check that curl is available.

# Usage:   bash install.sh install Port Path
# Example: bash install.sh install 8082 /tmp/autoplot
#          Installs and starts an AutoplotServlet on this machine
#          in directory /tmp/autoplot running on port 8082.

# Usage:   bash install.sh install Port Path Server
# Example: bash install.sh install 8082 /tmp/autoplot autoplot.org 
#          Installs and starts an AutoplotServlet on autoplot.org
#          in directory /tmp/autoplot running on port 8082.  You must
#          have ssh access to Server.

# Usage:   bash install.sh update Port Server
# Example: bash install.sh update 8082 autoplot.org
#          Downloads and installs the most recent AutoplotServlet and
#          uploads and restarts it using the Tomcat Servlet Manager.

Port=$2
# Remove http:// and any trailing slash from Server
Server=${3%/}
Server=${Server#http://}
User=$4

# If this is uncommented, this war file will be used.  Otherwise warfile at $WARURL is used.
#WARFILE=/home/weigel/AutoplotServlet.war

WARURL=http://autoplot.org/hudson/job/autoplot-jar-servlet/lastSuccessfulBuild/artifact/autoplot/AutoplotServlet/dist/AutoplotServlet.war
TESTURL="$Server:$Port/AutoplotServlet/SimpleServlet?url=vap%2Btsds%3Ahttp%3A%2F%2Ftimeseries.org%2Fget.cgi%3FStartDate%3D20030101%26EndDate%3D20080831%26ext%3Dbin%26out%3Dtsml%26ppd%3D1440%26param1%3DOMNI_OMNIHR-26-v0&process=&font=sans-8&format=image%2Fpng&width=700&height=400&column=5em%2C100%25-10em&row=3em%2C100%25-3em&timeRange=2003-mar&renderType=&color=%230000ff&fillColor=%23aaaaff&foregroundColor=%23ffffff&backgroundColor=%23000000"

# Add $Port-8080 to each default port in server.xml
Delta=$(($Port-8080))
ConnectorPort=$((8009+$Delta))
RedirectPort=$((8443+$Delta))
ShutdownPort=$((8005+$Delta))

if [ $1 = "install" ]; then

    # Install JRE
    if [ ! -d "/usr/lib/jvm/jre1.6.0_$VER" ]; then
	#echo "Skipping JRE install"	
	sudo bash install-sun-java6.sh
    else
	echo "install.sh: Found /usr/lib/jvm/jre1.6.0_$VER.  No JRE install needed."
    fi

    # Download Tomcat
    # curl http://www.eng.lsu.edu/mirrors/apache/tomcat/tomcat-6/v6.0.36/bin/apache-tomcat-6.0.36.tar.gz > tomcat/apache-tomcat-6.0.36.tar.gz 

    # Install Tomcat
    if [ $LOCAL = "true" ]; then
	if [ -d "$INSTALLPATH/tomcat-6.0.36-$Port" ]; then
	    echo "Removing $INSTALLPATH/tomcat-6.0.36-$Port"
	    sudo rm -rf $INSTALLPATH/tomcat-6.0.36-$Port
	    #echo "Found $INSTALLPATH/tomcat-6.0.36-$Port.  Skipping Tomcat install."
	    #exit;
	fi
    fi

    if [ -d ./tomcat-6.0.36-$Port ]; then
	echo "Removing ./apache-tomcat-6.0.36";
	rm -rf tomcat-6.0.36
    fi

    echo "Untarring tomcat/apache-tomcat-6.0.36.tar.gz"
    tar zxf tomcat/apache-tomcat-6.0.36.tar.gz 
    mv apache-tomcat-6.0.36 tomcat-6.0.36-$Port

    if [[ ${!WARFILE} || ! -e $WARFILE ]];then
	if [ ${!WARFILE} ];then
	    echo "WARFILE variable is not defined.  Will download."
	fi
	if [ ! -e $WARFILE ];then
	    echo "$WARFILE not found.  Will download."
	fi
        echo "Downloading WAR file from $WARURL"
	curl $WARURL > tomcat-6.0.36-$Port/webapps/AutoplotServlet.war
    else
	echo "$WARFILE found.  Copy to tomcat webapps directory."
        cp $WARFILE tomcat-6.0.36-$Port/webapps/
    fi

    cp tomcat-6.0.36-$Port/conf/server.xml . 
    /usr/bin/perl -pi -e "s/8080/"$Port"/g" server.xml
    /usr/bin/perl -pi -e "s/8009/"$ConnectorPort"/g" server.xml
    /usr/bin/perl -pi -e "s/8443/"$RedirectPort"/g" server.xml
    /usr/bin/perl -pi -e "s/8005/"$ShutdownPort"/g" server.xml
    
    cp conf/tomcat.sh .
    /usr/bin/perl -pi -e "s/8080/"$Port"/g" tomcat.sh
#    /usr/bin/perl -pi -e "s/\/usr\/local/"$INSTALLPATH"/g" tomcat.sh

    mv server.xml tomcat-6.0.36-$Port/conf
    sudo cp conf/tomcat-users.xml tomcat-6.0.36-$Port/conf

    if [ $LOCAL = "true" ]; then
	sudo mv tomcat-6.0.36-$Port $INSTALLPATH
	sudo mv tomcat.sh /etc/init.d/tomcat-6.0.36-$Port
	sudo chmod 744 /etc/init.d/tomcat-6.0.36-$Port
	sudo /etc/init.d/tomcat-6.0.36-$Port start
	sudo update-rc.d tomcat-6.0.36-$Port defaults 98 02
    else
	echo "Doing remote install"
	mv tomcat.sh tomcat-6.0.36-$Port/tomcat-6.0.36-$Port
	tar zcf tomcat-6.0.36-$Port.tgz tomcat-6.0.36-$Port
	scp tomcat-6.0.36-$Port.tgz $User@$Server:/tmp

	echo "Untarring and restarting Tomcat on remote server."
	command="ssh root@$Server 'cd $INSTALLPATH;tar zxf /tmp/tomcat-6.0.36-$Port.tgz;$INSTALLPATH/tomcat-6.0.36-$Port/tomcat-6.0.36-$Port restart'"
	eval $command
	rm -rf tomcat-6.0.36-$Port
	rm -rf tomcat-6.0.36-$Port.tgz
	rm -rf apache-tomcat-6.0.36
    fi
    echo "Sleeping for 3 seconds to let application deploy before testing."
    sleep 3
    bash install.sh test $Port $Server 
    bash install.sh test $Port $Server
fi

# Test
if [ $1 = "test" ]; then
   echo "Testing URL: "$TESTURL
   curl $TESTURL > install.png
   type=$(file install.png)
   if [[ $type == *PNG* ]];then
       display install.png
   else
       echo "ERROR:";
       head install.png
   fi
fi

# Update
if [ $1 = "update" ]; then

    if [[ ! ${!WARFILE} || ! -e $WARFILE ]];then
	if [ ${!WARFILE} ];then
	    echo "WARFILE variable is not defined.  Will download."
	fi
	if [ ! -e $WARFILE ];then
	    echo "$WARFILE not found.  Will download."
	fi
    echo "Downloading war file from hudson"
	curl $WARURL > /tmp/AutoplotServlet.war
    fi
    echo "Uploading war file to $Server:$Port"
    curl -u tomcat:autoplotservlet --upload-file /tmp/AutoplotServlet.war "$Server:$Port/manager/deploy?path=/AutoplotServlet&update=true"
    rm -f /tmp/AutoplotServlet.war
    echo "Sleeping for 2 seconds to let application deploy."
    echo "First attempt after update often fails.  Will try a second time."
    sleep 2
    bash install.sh test $Port $Server $User
    echo "Making another request because the first one often fails when an update is made (Even if we sleep for longer before making first request).  Why?"
    bash install.sh test $Port $Server $User
    rm -f /tmp/AutoplotServlet.war
fi
