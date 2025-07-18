# FROM registry.cn-hangzhou.aliyuncs.com/acejilam/golang:1.20 as go
# RUN go env -w GOPROXY=https://goproxy.cn,direct && go env -w GO111MODULE=on
# WORKDIR /demo
# RUN go mod init demo && go install github.com/br0xen/boltbrowser@latest
# FROM quay.io/coreos/etcd:v3.5.2 as builder

# FROM centos:7
# WORKDIR /
# COPY --from=builder /usr/local/bin/etcd /usr/local/bin/etcd
# COPY --from=builder /usr/local/bin/etcdctl /usr/local/bin/etcdctl
# COPY --from=go /go/bin/* /usr/local/bin/
# #USER 65532:65532
# ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# RUN yum install wget --no-verbose tree ping net-tools which blotbrowser -y
# EXPOSE 2379/tcp
# EXPOSE 2380/tcp
# CMD   [ "/usr/local/bin/etcd"]

docker rm etcd0 --force
docker rm etcd1 --force
docker rm etcd2 --force

docker network ls
docker network rm etcd
docker network create --subnet 172.19.0.0/16 etcd

docker network inspect etcd

docker run -d --name etcd0 --network etcd --ip 172.19.1.10 -P registry.cn-hangzhou.aliyuncs.com/acejilam/etcd:3.5.2 etcd \
	-name etcd0 \
	-advertise-client-urls http://172.19.1.10:2379,http://172.19.1.10:4001 \
	-listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
	-initial-advertise-peer-urls http://172.19.1.10:2380 \
	-listen-peer-urls http://0.0.0.0:2380 \
	--quota-backend-bytes=$((16 * 1024 * 1024)) \
	-initial-cluster-token etcd-cluster-1 \
	-initial-cluster etcd0=http://172.19.1.10:2380,etcd1=http://172.19.1.11:2380,etcd2=http://172.19.1.12:2380 \
	-initial-cluster-state new

docker run -d --name etcd1 --network etcd --ip 172.19.1.11 registry.cn-hangzhou.aliyuncs.com/acejilam/etcd:3.5.2 etcd \
	-name etcd1 \
	-advertise-client-urls http://172.19.1.11:2379,http://172.19.1.11:4001 \
	-listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
	-initial-advertise-peer-urls http://172.19.1.11:2380 \
	--quota-backend-bytes=$((16 * 1024 * 1024)) \
	-listen-peer-urls http://0.0.0.0:2380 \
	-initial-cluster-token etcd-cluster-1 \
	-initial-cluster etcd0=http://172.19.1.10:2380,etcd1=http://172.19.1.11:2380,etcd2=http://172.19.1.12:2380 \
	-initial-cluster-state new

docker run -d --name etcd2 --network etcd --ip 172.19.1.12 registry.cn-hangzhou.aliyuncs.com/acejilam/etcd:3.5.2 etcd \
	-name etcd2 \
	-advertise-client-urls http://172.19.1.12:2379,http://172.19.1.12:4001 \
	-listen-client-urls http://0.0.0.0:2379,http://0.0.0.0:4001 \
	-initial-advertise-peer-urls http://172.19.1.12:2380 \
	--quota-backend-bytes=$((16 * 1024 * 1024)) \
	-listen-peer-urls http://0.0.0.0:2380 \
	-initial-cluster-token etcd-cluster-1 \
	-initial-cluster etcd0=http://172.19.1.10:2380,etcd1=http://172.19.1.11:2380,etcd2=http://172.19.1.12:2380 \
	-initial-cluster-state new

docker exec -it etcd0 bin/sh

#etcdctl --endpoints http://172.19.1.10:2379,http://172.19.1.11:2379,http://172.19.1.12:2379 set /foo bar
#ETCDCTL_API=3 etcdctl --endpoints http://172.19.1.10:2379,http://172.19.1.11:2379,http://172.19.1.12:2379 get /foo

#ETCDCTL_API=3 etcdctl --endpoints http://172.19.1.10:2379,http://172.19.1.11:2379,http://172.19.1.12:2379 put foo bar
#ETCDCTL_API=3 etcdctl --endpoints http://172.19.1.10:2379,http://172.19.1.11:2379,http://172.19.1.12:2379 get foo

# ETCDCTL_API=3 etcdctl --endpoints http://172.19.1.10:2379,http://172.19.1.11:2379,http://172.19.1.12:2379 -w=table member list
