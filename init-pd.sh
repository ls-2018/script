# shellcheck disable=SC2148
rm -rf /root/.cargo /host_ssh /host_kube /Users/acejilam /resources
mkdir -p /Users/acejilam
mkdir -p /root/.cargo
ln -s /media/psf/script/ /Users/acejilam/script
ln -s /media/psf/resources /resources
ln -s /media/psf/.cargo/target/ /root/.cargo/target
ln -s /media/psf/.cargo/registry/ /root/.cargo/registry
ln -s /media/psf/.cargo/git/ /root/.cargo/git
ln -s /media/psf/.ssh/ /host_ssh
ln -s /media/psf/.kube/ /host_kube
