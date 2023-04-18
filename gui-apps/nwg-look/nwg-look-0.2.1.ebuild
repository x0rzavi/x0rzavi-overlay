# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit go-module

DESCRIPTION="GTK3 settings editor adapted to work in the sway / wlroots environment"
HOMEPAGE="https://github.com/nwg-piotr/nwg-look"

LICENSE="MIT"
SLOT="0"
IUSE="+pie"

KEYWORDS="~amd64"
RESTRICT="mirror"

RDEPEND="x11-apps/xcur2png
		x11-libs/gtk+"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

SRC_URI="https://github.com/nwg-piotr/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		 https://github.com/x0rzavi/x0rzavi-overlay/raw/main/${CATEGORY}/${PN}/files/${P}-deps.tar.xz"
DOCS="README.md"

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
		-o "bin/${PN}" .
	else
		ego build \
		-trimpath \
		-mod=readonly \
		-modcacherw \
		-ldflags "-s -w -linkmode external -X main.version=${PV}" \
		-o "bin/${PN}" .
	fi
}

src_install() {
	einstalldocs
	insinto "/usr/share/${PN}"
	doins stuff/main.glade
	insinto "/usr/share/${PN}/langs"
	doins langs/*
	insinto /usr/share/applications/
	doins "stuff/${PN}.desktop"
	insinto /usr/share/pixmaps/
	doins "stuff/${PN}.svg"
	dobin "bin/${PN}"
}
