#!/bin/bash
# buildme.sh    Runs a build Jenkins build job with multiple parameter values
# e.g.
# $ ./buildme.sh 'builderdude:monkey123' 'awesomebuildjob' 'http://paton.example.com:8080' 'PARAM1_NAME=param1_value' 'PARAM2_NAME=param2_value'
# Replace with your admin credentials, build job name, Jenkins URL, and parameter values

USERPASSWORD=$1
JOB=$2
SERVER=$3
shift 3
PARAM_VALUES=("$@")

# File where web session cookie is saved
COOKIEJAR="$(mktemp)"
CRUMB=$(curl -f -s -u "$USERPASSWORD" --cookie-jar "$COOKIEJAR" "$SERVER/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")
status=$?
if [[ $status -eq 0 ]]; then
  # Construct the build request URL with parameter values
  BUILD_URL="$SERVER/job/$JOB/buildWithParameters?"
  for PARAM_VALUE in "${PARAM_VALUES[@]}"; do
    BUILD_URL+="&$PARAM_VALUE"
  done
  curl -f -s -X POST -u "$USERPASSWORD" --cookie "$COOKIEJAR" -H "$CRUMB" "$BUILD_URL"
  status=$?
  if [[ $status -eq 0 ]]; then
    echo "Successfully invoked the Jenkins job - $JOB with parameter values"
  else
    echo "Failed to invoke the Jenkins Job - $JOB"
  fi
fi
rm "$COOKIEJAR"
exit $status

# ./invoke_jenkins_job_wp.sh 'novaprime:Pakalu@1234' 'ansiblefreestyle' 'http://localhost:8080' 'playbook_hosts=nodes'