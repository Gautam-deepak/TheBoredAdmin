#!/bin/bash
# buildme.sh    Runs a build Jenkins build job that requires a crumb
# e.g.
# $ ./buildme.sh 'builderdude:monkey123' 'awesomebuildjob' 'http://paton.example.com:8080'
# Replace with your admin credentials, build job name and Jenkins URL
#
# More background:
# https://support.cloudbees.com/hc/en-us/articles/219257077-CSRF-Protection-Explained

USERPASSWORD=$1
JOB=$2
SERVER="http://localhost:8080"

# File where web session cookie is saved
COOKIEJAR="$(mktemp)"
CRUMB=$(curl -f -s -u "$USERPASSWORD" --cookie-jar "$COOKIEJAR" "$SERVER/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")
status=$?
if [[ $status -eq 0 ]] ; then
  curl -f -s -X POST -u "$USERPASSWORD" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/job/"$JOB"/build
  status=$?
  if [[ $status -eq 0 ]]; then
  	echo "Successfully invoked the jenkins job - $JOB"
  else
    echo "Failed to invoke the Jenkins Job - $JOB"
  fi
fi
rm "$COOKIEJAR"
exit $status
