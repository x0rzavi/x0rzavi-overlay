# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Wayland clipboard manager"
HOMEPAGE="https://github.com/sentriz/cliphist"

LICENSE="GPL-3"
SLOT="0"
IUSE="+pie"
KEYWORDS="~amd64"
RESTRICT="mirror"

RDEPEND="gui-apps/wl-clipboard
		x11-misc/xdg-utils"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

SRC_URI="https://github.com/sentriz/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/x0rzavi/x0rzavi-overlay/raw/main/${CATEGORY}/${PN}/files/${P}-deps.tar.xz"
DOCS="readme.md LICENSE"

src_compile () {
	if use pie ; then
		ego build \
		--buildmode=pie \
		-trimpath \
		-ldflags "-s -w -X main.version=${PV}" \
		-o ${PN} .
	else
		ego build \
		-trimpath	\
		-ldflags "-s -w -X main.version=${PV}" \
		-o ${PN} .
	fi
}

src_install() {
	einstalldocs
	dobin ${PN}
}
