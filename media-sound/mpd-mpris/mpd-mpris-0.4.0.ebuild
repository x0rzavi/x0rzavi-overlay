# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd go-module

DESCRIPTION="An implementation of the MPRIS protocol for MPD."
HOMEPAGE="https://github.com/natsukagami/mpd-mpris"
LICENSE="MIT BSD-2"
SLOT="0"
IUSE="+pie"
KEYWORDS="~amd64"
RESTRICT="mirror"

RDEPEND="media-sound/mpd"
DEPEND="${RDEPEND}"

SRC_URI="https://github.com/natsukagami/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		 https://github.com/x0rzavi/x0rzavi-overlay/raw/main/${CATEGORY}/${PN}/files/${P}-deps.tar.xz"

src_compile() {
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
		-o ${PN} cmd/mpd-mpris/*.go
	else
		ego build \
		-trimpath \
		-mod=readonly \
		-modcacherw \
		-ldflags "-s -w -linkmode external -X main.version=${PV}" \
		-o ${PN} cmd/mpd-mpris/*.go
	fi
}

src_install() {
	local DOCS=( "LICENSE" "README.md" )
	einstalldocs

	dobin "${PN}"

	systemd_douserunit mpd-mpris.service
}
