# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

DESCRIPTION="Policy-driven snapshot management and replication tools for ZFS"
HOMEPAGE="https://github.com/jimsalterjrs/sanoid"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_BRANCH="master"
	EGIT_CLONE_TYPE="shallow"
	EGIT_REPO_URI="https://github.com/jimsalterjrs/${PN}.git"
else
	RESTRICT="mirror"
	SRC_URI="https://github.com/jimsalterjrs/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="-* ~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
DOCS="CHANGELIST LICENSE README.md sanoid.conf"

RDEPEND="dev-perl/Config-IniFiles
		 dev-perl/Capture-Tiny
		 sys-apps/pv
		 app-arch/lzop
		 app-arch/zstd
		 app-arch/gzip
		 app-arch/lz4
		 app-arch/gzip
		 sys-block/mbuffer
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_install () {
	dobin sanoid syncoid findoid
	insinto "/etc/${PN}"
	doins sanoid.defaults.conf
	insinto /etc/cron.d
	newins "${FILESDIR}/${PN}.cron" "${PN}"
	einstalldocs
}

pkg_postinst() {
	elog "Create a config file in /etc/sanoid/sanoid.conf"
	elog "An example is provided in /usr/share/doc/${PF}"
	elog "/etc/cron.d/sanoid executes \`sanoid --cron\` every 15 minutes."
}
