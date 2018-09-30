#!/bin/bash
#
# frist run docker-slim build.
#
SourceImage="kyos0109/nginx-distroless"
SourceImageTag=":${1:-latest}"
DockerSlimBaseDir=`echo ~/Documents/Docker/docker-slim`
DockerSlimBuild="$DockerSlimBaseDir/.images"
SlimImage="$SourceImage.slim"
SlimFilesDir="files"
FinalFiles="files.tar.xz"
CopyDir=('/etc/nginx' '/usr/lib/nginx' '/var/run' '/var/cache/nginx' '/var/log/nginx' '/usr/share/nginx/html')

##############################################
# get source temp container id.
BaseContainer=`docker create $SourceImage$SourceImageTag`

# get docker-slim image id.
SlimImageID=`docker images --no-trunc --quiet $SourceImage$SourceImageTag | cut -d ":" -f2`

# get files from build target dir.
cp -a $DockerSlimBuild/$SlimImageID/artifacts/* .

# copy build time shortage files.
for dir in ${CopyDir[*]}
do
	CopyParentsDir=$(dirname $dir)
	mkdir -p $SlimFilesDir$CopyParentsDir
	docker cp -aL $BaseContainer:$dir $SlimFilesDir$CopyParentsDir
done;

# delete build run files.
find ./$SlimFilesDir -iname "nginx.pid" -delete

# tar files.
cd $SlimFilesDir
tar Jcvf ../$FinalFiles *
cd -
rm -r $SlimFilesDir

# ADD files.tar.xz
sed -i .tmp "s/COPY\ $SlimFilesDir/ADD\ $FinalFiles/g" Dockerfile
rm Dockerfile.tmp

# rm temp source container
docker rm $BaseContainer