# Copyright 2021 Gentoo Authors
# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

PYTHON_COMPAT=( python3_11 )
inherit optfeature python-single-r1

DESCRIPTION="Quickly create and run optimised Windows, macOS and Linux desktop virtual machines"
HOMEPAGE="https://github.com/quickemu-project/quickemu"
SRC_URI="https://github.com/quickemu-project/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
DOCS="README.md LICENSE"

DEPEND="
	${PYTHON_DEPS}
	>=app-emulation/qemu-6.0.0[gtk,sdl,spice,smartcard,usbredir,virtfs]
	>=app-shells/bash-4.0:=
	sys-apps/coreutils
	|| (
		sys-firmware/edk2-ovmf
		sys-firmware/edk2-ovmf-bin
	)
	sys-apps/grep
	app-misc/jq
	sys-apps/lsb-release
	sys-process/procps
	app-cdr/cdrtools
	sys-apps/usbutils
	sys-apps/util-linux
	sys-apps/sed
	net-misc/socat
	app-emulation/spice[smartcard]
	net-misc/spice-gtk[gtk3,smartcard,usbredir]
	app-crypt/swtpm
	net-misc/wget
	x11-misc/xdg-user-dirs
	x11-apps/xrandr
	net-misc/zsync
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install () {
	python_doscript macrecovery macrecovery
	dobin quickemu
	dobin quickget

	doman docs/quickget.1
	doman docs/quickemu.1
	doman docs/quickemu_conf.1
}

pkg_postinst() {
	optfeature "faster downloads" net-misc/aria2
}
