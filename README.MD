# Abstract

This repository contains a collection of self written scripts to make administering UNIX servers (developed on Debian based systems) easier.
The repository structure is based on `/usr/local` so scripts which should be run with root privileges are contained in the `sbin` directory while other non-privilegd scripts are located in the `bin` directory.

# Table of Contents

## (Docker) Backup Script

**Summary:**

- Backup script for [Docker](https://www.docker.com/) volumes
- Automatically mounts a given backup hard drive and unmounts it afterwards
- Automatically stops and restarts corresponding containers to keep data integrity
- Also backs up important system files if wanted
- Keeps backups of the last x (default 7) days
- Is able to upload all current backups to an SMB share

This bash script was written in order to dynamically backup all Docker volumes present on the system.
The main purpose of the script is to use it as a cron job to make a full backup of a dockerized server infrastructure.
To achieve that, beside backing up Docker volumes, it is also capable to create backups of important system files.
Docker containers which use the to-be-backuped container are automatically stopped and restarted during the backup process in order to keep the data consistent.
Given that there are mounting operations in this script, it is recommended to run it with root privileges.
Backups are are saved as `tar` compressed archive files.
After backing up, former backups which are older than a defined amount of days will be automatically deleted.
Additionally, the script is able to upload all backups (compressed into a .tar.gz file) to a remote SMB share like a NAS.

## Docker Compose update Script

**Summary:**

- Just updates your existing docker compose setup with the newest images
- Automatically cleans up your docker images afterwards (can be commented out)

This short script was written to have a unifrom way of updating existing docker compose setups.
As with an update naturally its images become unnecessary to keep, the currently saved images are cleaned up via `docker image prune`
If this behaviours is not wanted, make sure to comment out the last line before executing the script.
As this script only needs docker privileges, it is not recommended to run as root.
