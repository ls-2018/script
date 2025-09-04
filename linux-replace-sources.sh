#!/usr/bin/env bash
set -v
touch ~/.hushlogin # 关闭登录提示
onlyUpdate=$1
rm -rf /etc/apt/sources.list.d/gierens.list

cat >/tmp/lsb_release <<'EOF'
# cat /usr/bin/lsb_release
#!/bin/sh

# SPDX-FileCopyrightText: 2021-2022 Gioele Barabucci
# SPDX-License-Identifier: ISC

set -eu

export LC_ALL="C.UTF-8"

help () {
	cat <<-EOD
		Usage: lsb_release [options]

		Options:
		  -h, --help         show this help message and exit
		  -v, --version      show LSB modules this system supports
		  -i, --id           show distributor ID
		  -d, --description  show description of this distribution
		  -r, --release      show release number of this distribution
		  -c, --codename     show code name of this distribution
		  -a, --all          show all of the above information
		  -s, --short        show requested information in short format
	EOD
	exit
}

show_id=false
show_desc=false
show_release=false
show_codename=false
short_format=false

options=$(getopt --name lsb_release -o hvidrcas -l help,version,id,description,release,codename,all,short -- "$@") || exit 2
eval set -- "$options"
while [ $# -gt 0 ] ; do
	case "$1" in
		-h|--help) help ;;
		-v|--version) ;;
		-i|--id) show_id=true ;;
		-d|--description) show_desc=true ;;
		-r|--release) show_release=true ;;
		-c|--codename) show_codename=true ;;
		-a|--all) show_id=true ; show_desc=true ; show_release=true ; show_codename=true ;;
		-s|--short) short_format=true ;;
		*) break  ;;
	esac
	shift
done

display_line () {
	label="$1"
	value="$2"

	if $short_format ; then
		printf "%s\n" "$value"
	else
		printf "%s:\t%s\n" "$label" "$value"
	fi
}

# Load release info from standard identification data files
[ -f /usr/lib/os-release ] && os_release=/usr/lib/os-release
[ -f /etc/os-release ] && os_release=/etc/os-release
[ "${LSB_OS_RELEASE-x}" != "x" ] && [ -f "$LSB_OS_RELEASE" ] && os_release="$LSB_OS_RELEASE"
[ "${os_release-x}" != "x" ] && . "$os_release"

# Mimic the output of Debian's Python-based lsb_release
# Capitalize ID
: "${ID=}"
ID="$(printf "%s" "$ID" | cut -c1 | tr '[:lower:]' '[:upper:]')$(printf "%s" "$ID" | cut -c2-)"
# Use NAME if set and different from ID only in capitalization.
if [ "${NAME-x}" != "x" ] ; then
	lower_case_id=$(printf "%s" "$ID" | tr '[:upper:]' '[:lower:]')
	lower_case_name=$(printf "%s" "$NAME" | tr '[:upper:]'  '[:lower:]')
	if [ "${lower_case_id}" = "${lower_case_name}" ] ; then
		ID="$NAME"
	fi
fi

# Generate minimal standard-conform output (if stdout is a TTY).
[ -t 1 ] && echo "No LSB modules are available." >& 2

if $show_id ; then
	display_line "Distributor ID" "${ID:-n/a}"
fi

if $show_desc ; then
	display_line "Description" "${PRETTY_NAME:-n/a}"
fi

if $show_release ; then
	display_line "Release" "${VERSION_ID:-n/a}"
fi

if $show_codename ; then
	display_line "Codename" "${VERSION_CODENAME:-n/a}"
fi

EOF

if command -v lsb_release &>/dev/null; then
	echo "lsb_release already exists"
else
	mv /tmp/lsb_release /usr/bin/lsb_release
	chmod +x /usr/bin/lsb_release
fi

curl -sSL https://linuxmirrors.cn/main.sh | bash -s -- \
	--source mirrors.aliyun.com \
	--protocol https \
	--use-intranet-source false \
	--install-epel true \
	--backup true \
	--upgrade-software false \
	--clean-cache false \
	--ignore-backup-tips

if command -v apt-get &>/dev/null; then
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
	apt-get update && echo "🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥"
	if [[ $onlyUpdate == "update" ]]; then
		apt install apt-transport-https ca-certificates -y
		apt install curl git make cmake htop bridge-utils net-tools inetutils-ping -y

		systemctl stop unattended-upgrades.service
		systemctl disable unattended-upgrades.service
	fi
fi

echo "success"

cat >/etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=114.114.114.114
EOF

if command -v systemctl &>/dev/null; then
	systemctl restart systemd-resolved
fi
if command -v resolvectl &>/dev/null; then
	resolvectl status
fi
