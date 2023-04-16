# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="13"
K_SECURITY_UNSUPPORTED="1"
K_NODRYRUN="1"
# EXTRAVERSION="-cachy"

inherit kernel-2
detect_version
detect_arch

KEYWORDS="~amd64"
HOMEPAGE="https://github.com/CachyOS/linux-cachyos"

CPU_SCHED="bmq pds bore cfs tt eevdf"
for sched in ${CPU_SCHED}; do
	IUSE_CPU_SCHED+=" cpu_sched_${sched}"
done
IUSE="${IUSE_CPU_SCHED} +cachy"
REQUIRED_USE="^^ ( ${IUSE_CPU_SCHED} )"

DESCRIPTION="Linux Kernel by CachyOS with patches and performance improvements"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"
MY_KV="${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}"

src_unpack() {
	#if use cpu_sched_eevdf; then UNIPATCH_LIST+="${FILESDIR}/0001-EEVDF.patch"; fi
	if use cachy; then UNIPATCH_LIST+="${FILESDIR}/${MY_KV}-cachyos-base-all.patch"; fi
	kernel-2_src_unpack
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
