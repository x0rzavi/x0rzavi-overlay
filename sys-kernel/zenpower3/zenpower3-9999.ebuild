# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-info linux-mod

DESCRIPTION="Linux kernel driver for reading temperature, voltage(SVI2), current(SVI2) and power(SVI2) for AMD Zen family CPUs, now with Zen 3 support!"
HOMEPAGE="https://git.exozy.me/Ta180m/zenpower3"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_BRANCH="master"
	GIT_CLONE_TYPE="shallow"
	EGIT_REPO_URI="https://git.exozy.me/Ta180m/${PN}.git"
else
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES="${FILESDIR}/${P}-use-symlink-to-detect-kernel-version.patch"

CONFIG_CHECK="HWMON
			  PCI
			  AMD_NB
			  ~!CONFIG_SENSORS_K10TEMP
"

WARNING_CONFIG_SENSORS_K10TEMP="Because zenpower is using same PCI device as k10temp,
								you have to disable k10temp first, either from kernel
								or by blacklisting the module"

BUILD_TARGETS="modules"
MODULE_NAMES="zenpower(misc:${S})"

src_compile() {
	export KV_FULL
	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install
	dobin zp_read_debug.sh
	dodoc README.md
}
