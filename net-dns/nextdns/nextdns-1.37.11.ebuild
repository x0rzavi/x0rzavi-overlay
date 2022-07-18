# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="NextDNS CLI client (DoH Proxy)"
HOMEPAGE="https://${PN}.io"

LICENSE="MIT"
SLOT="0"
IUSE="+pie"
KEYWORDS="~amd64"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="dev-lang/go
		 dev-vcs/git
		 virtual/pkgconfig"

SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/x0rzavi/x0rzavi-overlay/raw/main/${CATEGORY}/${PN}/files/${P}-deps.tar.xz"

src_compile () {
	if use pie ; then
		ego build \
		--buildmode=pie \
		-trimpath \
		-ldflags "-X main.version=${PV}" \
		-o ${PN} .
	else
		ego build \
		-trimpath	\
		-ldflags "-X main.version=${PV}" \
		-o ${PN} .
	fi
}

src_install() {
	einstalldocs
	dobin ${PN}
}
