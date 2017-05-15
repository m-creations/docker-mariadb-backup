# docker-mariadb-backup

A docker container for backing up a [MariaDB](http://mariadb.org) database with mysqldump and storing it in a SQL file.

## How to run

The container can be run as follows:

```
docker run -d v $HOME/data:/data -e DB_HOST=my-mariadb.example.com -e DB_USER=root -r DB_PASSWORD=root -e ZIP_CMD="bzip2" mcreations/mariadb-backup
```

the `ZIP_CMD` parameter can two values haben either bzip2 or gzip.

# Github Repo

https://github.com/m-creations/docker-mariadb-backup/
