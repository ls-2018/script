#!/usr/bin/env bash
rm -rf ~/.cargo /host_ssh /host_kube /Users/acejilam /resources
mkdir -p /Users/acejilam
mkdir -p ~/.cargo
ln -s /media/psf/script/ /Users/acejilam/script
ln -s /media/psf/resources /resources
ln -s /media/psf/.cargo/target/ ~/.cargo/target
ln -s /media/psf/.cargo/registry/ ~/.cargo/registry
ln -s /media/psf/.cargo/git/ ~/.cargo/git
ln -s /media/psf/.ssh/ /host_ssh
ln -s /media/psf/.kube/ /host_kube
