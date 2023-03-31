# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="One-stop ZFS backup & replication solution"
HOMEPAGE="https://github.com/zrepl/zrepl"

LICENSE="GPL-3"
SLOT="0"
IUSE="+pie"
KEYWORDS="~amd64"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

SRC_URI="https://github.com/zrepl/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		 https://github.com/x0rzavi/x0rzavi-overlay/raw/main/${CATEGORY}/${PN}/files/${P}-deps.tar.xz"
DOCS="README.md LICENSE"

src_compile () {
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_CPPFLAGS="${CXXFLAGS}"
	export CGO_CXXFLAGS="${CXXFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"

	if use pie ; then
		ego build \
		--buildmode=pie \
		-trimpath \
		-mod=readonly \
		-modcacherw \
		-ldflags "-s -w -linkmode external -X main.version=${PV}" \
		-o ${PN} .
	else
		ego build \
		-trimpath \
		-mod=readonly \
		-modcacherw \
		-ldflags "-s -w -linkmode external -X main.version=${PV}" \
		-o ${PN} .
	fi
}

src_install() {
	einstalldocs
	dobin ${PN}
}
