# Copyright 2023 Avishek Sen
# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v3

EAPI=8

DESCRIPTION="ZFS Bootloader for root-on-ZFS systems with support for snapshots and native full disk encryption"
HOMEPAGE="https://zfsbootmenu.org"
SRC_URI="https://github.com/zbm-dev/zfsbootmenu/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
DOCS="LICENSE"

RDEPEND="
app-shells/fzf
sys-apps/kexec-tools
sys-block/mbuffer
dev-perl/Sort-Versions
dev-perl/Config-IniFiles
dev-perl/YAML-PP
dev-perl/boolean
dev-libs/openssl
sys-libs/ncurses
sys-fs/zfs
sys-kernel/dracut"

src_compile () {
	if [[ -f Makefile ]] || [[ -f GNUmakefile ]] || [[ -f makefile ]]; then
		emake DESTDIR="${D}" || die "emake failed"
	fi
}

pkg_postinst () {
	elog "Please consult upstream doumentation to install the bootloader
	https://github.com/zbm-dev/zfsbootmenu"
}
