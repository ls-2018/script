podman machine reset -f
brew uninstall podman
sudo /opt/podman/bin/podman-mac-helper uninstall
sudo rm /etc/paths.d/podman-pkg
sudo rm -rfv /opt/podman

rm -rf ~/.local/share/containers/podman
rm -rf ~/.config/containers/podman
rm -rf ~/.local/share/containers/storage
rm -rf ~/.local/share/containers/podman-desktop

rm -rf /Applications/Podman\ Desktop.app/