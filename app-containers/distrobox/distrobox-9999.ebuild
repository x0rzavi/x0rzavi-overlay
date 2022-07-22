# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Use any linux distribution inside your terminal. Enable both backward and forward compatibility with software and freedom to use whatever distribution you’re more comfortable with."
HOMEPAGE="https://github.com/89luca89/distrobox
		  https://distrobox.privatedns.org"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_BRANCH="main"
	EGIT_CLONE_TYPE="shallow"
	EGIT_REPO_URI="https://github.com/89luca89/${PN}.git"
else
	RESTRICT="mirror"
	SRC_URI="https://github.com/89luca89/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
fi

LICENSE="GPL-3"
SLOT="0"

RDEPEND="|| ( app-containers/docker app-containers/podman )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_install () {
	${S}/install --prefix ${D}/usr
}
