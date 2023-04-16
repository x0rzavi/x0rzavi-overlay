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

# Define USE flags for CPU schedulers
CPU_SCHED="bmq pds bore cfs tt eevdf"
for sched in ${CPU_SCHED}; do
	if [ "${sched}" = "eevdf" ]; then IUSE_CPU_SCHED+=" +cpu_sched_${sched}" # Set default
	else IUSE_CPU_SCHED+=" cpu_sched_${sched}"; fi
done

IUSE="${IUSE_CPU_SCHED} +config"
REQUIRED_USE="^^ ( "${IUSE_CPU_SCHED//+}" )"

DESCRIPTION="Linux Kernel by CachyOS with patches and performance improvements"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"
MY_KV="${KV_MAJOR}.${KV_MINOR}.${KV_PATCH}"

src_unpack() {
	UNIPATCH_LIST+=" ${FILESDIR}/${MY_KV}-cachyos-base-all.patch"

	if use cpu_sched_eevdf; then UNIPATCH_LIST+=" ${FILESDIR}/sched/${MY_KV}-EEVDF.patch"; fi
	kernel-2_src_unpack
	if use config; then
		cp "${FILESDIR}/config/6.2.11-config-eevdf" .config
		scripts/config -e CACHY
		elog "CachyOS config installed"
	fi
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}

pkg_postrm() {
	kernel-2_pkg_postrm
}
