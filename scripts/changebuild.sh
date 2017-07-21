#!/bin/bash

# a script to change the build which runs for a specfic container
# usage changeBuild <service> <git-sha>

function usage
{
 echo "changebuild.sh [OPTIONS] <service> <buildGitSha>"
 echo "   Change running build in dynamease production environment"
 echo "  OPTIONS"
 echo "    -o : additionnal docker options that will be inserted in the docker run command"
 echo "    -h : help"

}

# find pre running tomcat container
function identify_container
{
    previouscontainer=''
    nbrContainer=$(docker ps -a | grep -c "$service"-)
    if [ $nbrContainer -eq 0 ];then
	     echo " No previous running container found for service ""$service"
    elif [ $nbrContainer -eq 1 ];then
       previouscontainer=$(docker ps -a | grep "$service"- | awk '{print $NF}' )
       echo "previous container $previouscontainer will be stopped and logged"
    else
      echo "Found $nbrContainer containers matching service $service, you will have to live with that or destroy them manually"
    fi
}

###################################
#      Main Script Execution      #
###################################

dockeroptions=''


# Option analysis
argindex=0
while getopts 'ho:' flag; do
  case "${flag}" in
    h)  usage ;
	  exit 0;;
    o) dockeroptions="${OPTARG}" ;
       argindex=$(($argindex+2));;
    *) error "Unexpected option ${flag}"
       usage
       ;;
  esac
done

allarguments=("$@")
service=${allarguments[$#-2]}
gitsha=${allarguments[$#-1]}


echo "$# arguments"
echo "Service $service"
echo "gitsha $gitsha"
echo "dockeroptions $dockeroptions"
echo "argindex : $argindex"

#if [ $# -ne 2 ]
#then
#  usage
#  exit 0
#fi



newcontainer="$service"-"$gitsha"

identify_container

# start new container
echo "starting tomcat container $newcontainer with additionnal docker options $dockeroptions"
docker run -d --name "$newcontainer"  $dockeroptions yvnicolas/$service:$gitsha

# wait for it to properly start
echo "$newcontainer"" started, waiting for it to be deployed"
sleep 30

# Activate it connecting the new container to the nginxnetwork
echo "switching ""$service"" release thru Nginx network connection"
docker network connect --alias $service nginxnet $newcontainer

# Stop old tomcat container and take logs for it
if [ $previouscontainer != '' ];then

  echo "stopping previous Tomcat container  $previouscontainer"
#  docker stop "$previouscontainer"
  echo "archiving logs to $HOME/logs/$service-$gitsha-`date +%Y%m%d-%H%M`"
  docker logs "$previouscontainer" > "$HOME"/logs/"$service"-"$gitsha"-`date +%Y%m%d-%H%M`
  docker rm -fv "$previouscontainer"

fi
