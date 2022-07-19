# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Command-line DNS Client for Humans"
HOMEPAGE="https://github.com/mr-karan/doggo"

LICENSE="GPL-3"
SLOT="0"
IUSE="+pie"
KEYWORDS="~amd64"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

SRC_URI="https://github.com/mr-karan/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/x0rzavi/x0rzavi-overlay/raw/main/${CATEGORY}/${PN}/files/${P}-deps.tar.xz"

src_compile () {
	if use pie ; then
		ego build \
		--buildmode=pie \
		-trimpath \
		-ldflags "-s -w -X main.Version=${PV}" \
		-o ${PN} ${S}/cmd/doggo
	else
		ego build \
		-trimpath	\
		-ldflags "-s -w -X main.version=${PV}" \
		-o ${PN} ${S}/cmd/doggo
	fi
}

src_install() {
	einstalldocs
	dobin ${PN}
}
