# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="13"
K_NODRYRUN="1"
UNIPATCH_STRICTORDER="1"

inherit kernel-2
detect_version
detect_arch

KEYWORDS="~amd64"
HOMEPAGE="https://github.com/CachyOS/linux-cachyos"

DESCRIPTION="Linux Kernel by CachyOS with patches and performance improvements"
SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"
MY_KV="${KV_MAJOR}.${KV_MINOR}"
MY_FILESDIR="${FILESDIR}/${MY_KV}"

# Define USE flags for CPU schedulers
CPUSCHED="bmq pds bore cfs tt eevdf"
for sched in ${CPUSCHED}; do
	if [ "${sched}" = "eevdf" ]; then IUSE_CPUSCHED+=" +cpusched_${sched}" # Set default
	else IUSE_CPUSCHED+=" cpusched_${sched}"; fi
done

# Define USE flags for HZ ticks
HZTICKS="100 250 300 500 600 750 1000"
for rate in ${HZTICKS}; do
	if [ "${rate}" = "500" ]; then IUSE_HZTICKS+=" +hzticks_${rate}" # Set default
	else IUSE_HZTICKS+=" hzticks_${rate}"; fi
done

# Define USE flags for tick rate
TICKRATE="full idle perodic"
for tick in ${TICKRATE}; do
	if [ "${tick}" = "full" ]; then IUSE_TICKRATE+=" +tickrate_${tick}" # Set default
	else IUSE_TICKRATE+=" tickrate_${tick}"; fi
done

# Define USE flags for preempt
PREEMPT="full voluntary server"
for type in ${PREEMPT}; do
	if [ "${type}" = "full" ]; then IUSE_PREEMPT+=" +preempt_${type}" # Set default
	else IUSE_PREEMPT+=" preempt_${type}"; fi
done

# Define USE flags for LRU
LRU="standard stats none"
for config in ${LRU}; do
	if [ "${config}" = "standard" ]; then IUSE_LRU+=" +lru_${config}" # Set default
	else IUSE_LRU+=" lru_${config}"; fi
done

# Define USE flags for transparent hugepage
HUGEPAGE="always madvise"
for type in ${HUGEPAGE}; do
	if [ "${type}" = "always" ]; then IUSE_HUGEPAGE+=" +hugepage_${type}" # Set default
	else IUSE_HUGEPAGE+=" hugepage_${type}"; fi
done

# Define USE flags for ZSTD compression level
ZSTDLEVEL="ultra normal"
for type in ${ZSTDLEVEL}; do
	if [ "${type}" = "normal" ]; then IUSE_ZSTDLEVEL+=" +zstdlevel_${type}" # Set default
	else IUSE_ZSTDLEVEL+=" zstdlevel_${type}"; fi
done

IUSE="+config ${IUSE_CPUSCHED} tune_bore NUMAdisable +cc_harder +per_gov +tcp_bbr2
	${IUSE_HZTICKS} ${IUSE_TICKRATE} ${IUSE_PREEMPT} +mq_deadline_disable +kyber_disable
	${IUSE_LRU} ${IUSE_HUGEPAGE} damon lrng +use_auto_optimization disable_debug
	zstd_compression ${IUSE_ZSTDLEVEL} bcachefs +latency_nice"

REQUIRED_USE="^^ ( ${IUSE_CPUSCHED//+} )
			^^ ( ${IUSE_HZTICKS//+} )
			^^ ( ${IUSE_TICKRATE//+} )
			^^ ( ${IUSE_PREEMPT//+} )
			^^ ( ${IUSE_LRU//+} )
			^^ ( ${IUSE_HUGEPAGE//+} )
			^^ ( ${IUSE_ZSTDLEVEL//+} )"

src_unpack() {
	kernel-2_src_unpack

	# unipatch "${MY_FILESDIR}/0001-cachyos-base-all.patch"
	UNIPATCH_LIST+="${MY_FILESDIR}/0001-cachyos-base-all.patch"
	if use config; then
		cp "${MY_FILESDIR}/config/config-eevdf" .config
		scripts/config -e CACHY
		elog " "
		elog "CachyOS kernel config installed"
		elog " "
	fi
	if use auto_optimization; then "${MY_FILESDIR}/auto-cpu-optimization.sh"; fi

	# if use latency_nice; then
	# 	if use cpusched_bore || use cpusched_cfs; 
	# 		then unipatch "${MY_FILESDIR}/misc/0001-Add-latency-priority-for-CFS-class.patch"
	# 	fi
	# fi

	if use cpusched_eevdf; then UNIPATCH_LIST+=" ${MY_FILESDIR}/sched/0001-EEVDF.patch"; fi
	# if use cpusched_eevdf; then unipatch "${MY_FILESDIR}/sched/0001-EEVDF.patch"; fi
	# if use cpusched_pds || use cpu_sched_bmq; then unipatch "${MY_FILESDIR}/sched/0001-prjc-cachy.patch"; fi
	# if use cpusched_tt; then unipatch "${MY_FILESDIR}/sched/0001-tt-cachy.patch"; fi
	# if use cpusched_bore; then
	# 	if use tune_bore; then unipatch "${MY_FILESDIR}/misc/0001-bore-tuning-sysctl.patch"; fi
	# 	unipatch "${MY_FILESDIR}/sched/0001-bore-cachy.patch"; fi
	# # if use cpusched_cfs; then unipatch "${MY_FILESDIR}/sched/0001-EEVDF.patch"; fi

	# if use bcachefs; then unipatch "${MY_FILESDIR}/misc/0001-bcachefs.patch"; fi
	# if use lrng; then unipatch "${MY_FILESDIR}/misc/0001-lrng.patch"; fi
}

pkg_postinst() {
	kernel-2_pkg_postinst
	einfo "For more info on this patchset, and how to report problems, see:"
	einfo "${HOMEPAGE}"
}
