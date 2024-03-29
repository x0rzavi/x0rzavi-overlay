# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

DESCRIPTION="Chromium running inside your terminal"
HOMEPAGE="https://github.com/fathyb/carbonyl"

LICENSE="BSD"
SLOT="0"

KEYWORDS="~amd64 ~arm64"
RESTRICT="mirror"

MY_PN="carbonyl"
MY_P="${MY_PN}-${PV}"

RDEPEND=""
DEPEND="${RDEPEND}
	dev-libs/expat
	dev-libs/nss
	media-libs/alsa-lib"
BDEPEND=""

BASE_URI="https://github.com/fathyb/${MY_PN}/releases/download/v${PV}/${MY_PN}.linux-"
SRC_URI="
	amd64? ( ${BASE_URI}amd64.zip -> ${MY_PN}-amd64-${PV}.zip )
	arm64? ( ${BASE_URI}arm64.zip -> ${MY_PN}-arm64-${PV}.zip )
"

QA_PREBUILT="/opt/${MY_P}/${MY_PN}"
QA_PRESTRIPPED="/opt/${MY_P}/libEGL.so
				/opt/${MY_P}/libvk_swiftshader.so
				/opt/${MY_P}/libvulkan.so.1
				/opt/${MY_P}/libGLESv2.so"

src_unpack() {
	mkdir -p "${S}"
	cd "${S}" || die
	unpack "${MY_PN}-${ARCH}-${PV}.zip"
}

src_install() {
	mkdir --parents "${D}/opt/"
	cp -r "${WORKDIR}/${P}/${MY_P}/" "${D}/opt/"
	dobin "${FILESDIR}/${MY_PN}"
}
