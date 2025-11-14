docker rm nfs-server --force

# docker run -d --name nfs-server --network=kind -e NFS_EXPORT_0='/nfs  *(rw,fsid=1,async,insecure,no_root_squash)' -v /Volumes/Tf/data/nfs:/nfs --cap-add SYS_ADMIN -p 2049:2049 erichough/nfs-server

docker run -d --name nfs-server --network=kind -e NFS_EXPORT_0='/nfs  *(rw,fsid=1,async,insecure,no_root_squash)' -v /Volumes/Tf/data/nfs:/nfs --privileged -p 2049:2049 erichough/nfs-server
