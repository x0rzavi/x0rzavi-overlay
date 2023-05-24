# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

DESCRIPTION="Ping, but with a graph."
HOMEPAGE="https://github.com/orf/gping"

LICENSE="MIT"
SLOT="0"

KEYWORDS="~amd64"
RESTRICT="mirror"

MY_PN="gping"
MY_P="${MY_PN}-${PV}"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""
SRC_URI="https://github.com/orf/${MY_PN}/releases/download/${MY_PN}-v${PV}/${MY_PN}-Linux-x86_64.tar.gz -> ${MY_P}.tar.gz
		https://github.com/orf/${MY_PN}/releases/download/${MY_PN}-v${PV}/${MY_PN}.1"

QA_PREBUILT="/usr/bin/${MY_PN}"

src_unpack() {
	mkdir -p "${S}"
	cd "${S}" || die
	unpack "${MY_P}.tar.gz"
}

src_install() {
	dobin "${MY_PN}"
	doman "${DISTDIR}/${MY_PN}.1"
}
