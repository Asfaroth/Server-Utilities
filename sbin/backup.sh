#!/bin/bash
export LANG="en_US.UTF-8"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Config ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Edit to fit your system configuration

BACKUPDRIVE=/dev/sda # Drive which should be mounted as the backup location, leave empty to disable
BACKUPMOUNT=/mnt/sda # Mount point of the drive
BACKUPBASE=/mnt/sda/backups # Main backup directory
BACKUPDIR=$BACKUPBASE/$(date +"%Y%m%d%H%M") # Directory where the backup should be saved

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Init Stuff ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Initializes and checks all needed dependencies

# Mounting drive if it is defined
if [ ! -z "$BACKUPDRIVE" ]; then
    mount $BACKUPDRIVE $BACKUPMOUNT
fi

# Creating backup directory if it is not present
if [ ! -d $BACKUPDIR ]; then
        mkdir -p $BACKUPDIR
fi
echo "Saving backups to $BACKUPDIR"
echo -e "\n"

echo "Pulling alpine...."
VOLUME=$(docker volume ls -q) # Gathering all volumes
docker pull alpine:latest # Pulling alpine to have a backup environment

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Docker Backup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The main backup process takes place here
# WARNING: The script assumes that Docker Containers are already running. Stopped containers will be running afterwards if they have a mounted volume

echo -e "\n"
for i in $VOLUME; do
        echo "Handling volume $i"

        CONTAINER=$(docker ps -q --filter volume=$i)
        echo "Stopping containers..."
        for j in $CONTAINER; do
                docker container stop $j
        done

        mkdir $BACKUPDIR/$i
        docker run --rm -v $BACKUPDIR/$i:/backup -v $i:/data:ro alpine:latest sh -c "cd /data && /bin/tar -czf /backup/backup.tar.gz ."

        echo "(Re-) Starting containers..."
        for j in $CONTAINER; do
                docker container start $j
        done
        echo -e "\n"
done

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Custom Backups ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Add custom backup operations here, delete or comment out to disable

echo "Backing up system files..."
mkdir $BACKUPDIR/system_files

tar -czf $BACKUPDIR/system_files/home.tar.gz /home # Example for backing up home directory
tar -czf $BACKUPDIR/system_files/etc.tar.gz /etc # Example for backing up etc directory
tar --exclude='/var/lib/docker' -czf $BACKUPDIR/system_files/var_lib.tar.gz /var/lib # Example for backing up var/lib directory

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Cleanup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Old backups are deleted here and the drive is unmounted if configured

echo -e "\n"
echo "Cleaning up old backups..."
find $BACKUPBASE/* -mtime +7 -exec rm -rf {} \;

if [ ! -z "$BACKUPDRIVE" ]; then
    umount $BACKUPDRIVE
fi
