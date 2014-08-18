#!/bin/bash
#
# Startup script for the Tomcat server
#
# chkconfig: - 83 53
# description: Starts and stops the Tomcat daemon.
# processname: tomcat
# pidfile: /var/run/tomcat.pid

PORT=8080

# See how we were called.
export JAVA_HOME=/usr/lib/jvm/java-6-sun
export JAVA_OPTS="-server -Xmx512m -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=128m"
case $1 in
	start)

		export CLASSPATH=/usr/local/tomcat-6.0.36-$PORT/common/lib/servlet-api.jar
		export CLASSPATH=/usr/local/tomcat-6.0.36-$PORT/common/lib/jsp-api.jar
		sh /usr/local/tomcat-6.0.36-$PORT/bin/startup.sh
	;;
	stop)
		sh /usr/local/tomcat-6.0.36-$PORT/bin/shutdown.sh
	;;
	restart)
		sh /usr/local/tomcat-6.0.36-$PORT/bin/shutdown.sh
		sh /usr/local/tomcat-6.0.36-$PORT/bin/startup.sh
	;;
	*)
		echo "Usage: /etc/init.d/tomcat-6.0.36-$PORT start|stop|restart"
	;;
esac

exit 0
