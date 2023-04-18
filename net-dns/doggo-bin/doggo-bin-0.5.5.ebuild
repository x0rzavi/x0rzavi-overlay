# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

DESCRIPTION="Command-line DNS Client for Humans"
HOMEPAGE="https://github.com/mr-karan/doggo"

LICENSE="GPL-3"
SLOT="0"
IUSE="zsh-completion fish-completion"

KEYWORDS="~amd64"
RESTRICT="mirror"

MY_PN="doggo"
MY_P="${MY_PN}-${PV}"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND=""
SRC_URI="https://github.com/mr-karan/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_amd64.tar.gz -> ${MY_P}.tar.gz"

QA_PREBUILT="/usr/bin/${MY_PN}"

src_unpack() {
	mkdir -p "${S}"
	cd "${S}" || die
	unpack "${MY_P}.tar.gz"
}

src_install() {
	dobin ${MY_PN}
	use zsh-completion && insinto /usr/share/zsh/site-functions/ && newins "${S}/completions/${MY_PN}.zsh" "_${MY_PN}"
	use fish-completion && insinto /usr/share/fish/vendor_completions.d/ && doins "${S}/completions/${MY_PN}.fish"
}
