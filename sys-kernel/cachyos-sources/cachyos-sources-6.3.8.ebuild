# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI="8"
ETYPE="sources"
K_WANT_GENPATCHES="base extras"
K_GENPATCHES_VER="11"
K_NODRYRUN="1"
# UNIPATCH_STRICTORDER="1"

inherit kernel-2
detect_version
detect_arch

DESCRIPTION="Linux Kernel by CachyOS with different schedulers, patches and performance improvements"
HOMEPAGE="https://github.com/CachyOS/linux-cachyos"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

SRC_URI="${KERNEL_URI} ${GENPATCHES_URI} ${ARCH_URI}"
MY_KV="${KV_MAJOR}.${KV_MINOR}"
MY_FILESDIR="${FILESDIR}/${MY_KV}"

# Define USE flags for CPU schedulers
CPUSCHED="bmq pds bore cfs tt cachyos"
for sched in ${CPUSCHED}; do
	if [ "${sched}" = "cachyos" ]; then IUSE_CPUSCHED+=" +cpusched_${sched}" # Set default
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

# Define USE flags for per-VMA locking
VMA="standard stats none"
for config in ${VMA}; do
	if [ "${config}" = "standard" ]; then IUSE_VMA+=" +vma_${config}" # Set default
	else IUSE_VMA+=" vma_${config}"; fi
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
${IUSE_LRU} ${IUSE_VMA} ${IUSE_HUGEPAGE} damon lrng +auto_optimization disable_debug
${IUSE_ZSTDLEVEL} bcachefs"

REQUIRED_USE="^^ ( ${IUSE_CPUSCHED//+} )
^^ ( ${IUSE_HZTICKS//+} )
^^ ( ${IUSE_TICKRATE//+} )
^^ ( ${IUSE_PREEMPT//+} )
^^ ( ${IUSE_LRU//+} )
^^ ( ${IUSE_VMA//+} )
^^ ( ${IUSE_HUGEPAGE//+} )
^^ ( ${IUSE_ZSTDLEVEL//+} )"

src_unpack() {
	kernel-2_src_unpack

	  # Select patches to apply
	  PATCH_LIST+=" ${MY_FILESDIR}/0001-cachyos-base-all.patch"

	  if use cpusched_cachyos; then
		  PATCH_LIST+=" ${MY_FILESDIR}/sched/0001-EEVDF.patch";
		  PATCH_LIST+=" ${MY_FILESDIR}/sched/0001-bore-eevdf.patch";
	  fi
	  if use cpusched_pds || use cpusched_bmq; then PATCH_LIST+=" ${MY_FILESDIR}/sched/0001-prjc-cachy.patch"; fi
	  if use cpusched_tt; then PATCH_LIST+=" ${MY_FILESDIR}/sched/0001-tt-cachy.patch"; fi
	  if use cpusched_bore; then
		  if use tune_bore; then PATCH_LIST+=" ${MY_FILESDIR}/misc/0001-bore-tuning-sysctl.patch"; fi
		  PATCH_LIST+=" ${MY_FILESDIR}/sched/0001-bore-cachy.patch"
	  fi

	  if use bcachefs; then PATCH_LIST+=" ${MY_FILESDIR}/misc/0001-bcachefs.patch"; fi
	  if use lrng; then PATCH_LIST+=" ${MY_FILESDIR}/misc/0001-lrng.patch"; fi

	# Apply all selected patches
	for patch in ${PATCH_LIST}; do
		unipatch "${patch}" || die "Patch: ${patch} failed"
	done

	  # Start configuring kernel
	  if use config; then
		  cp "${MY_FILESDIR}/config" .config
		  cp "${MY_FILESDIR}/config" arch/x86/configs/cachy_defconfig
		  scripts/config -e CACHY
		  elog "CachyOS kernel config installed as cachy_defconfig"
	  fi
	  if use auto_optimization; then "${MY_FILESDIR}/auto-cpu-optimization.sh"; fi

	  if use cpusched_pds; then scripts/config -e SCHED_ALT -d SCHED_BMQ -e SCHED_PDS -e PSI_DEFAULT_DISABLED; fi
	  if use cpusched_bmq; then scripts/config -e SCHED_ALT -e SCHED_BMQ -d SCHED_PDS -e PSI_DEFAULT_DISABLED; fi
	  if use cpusched_tt; then scripts/config -e TT_SCHED -e TT_ACCOUNTING_STATS; fi
	  if use cpusched_bore || use cpusched_cachyos; then scripts/config -e SCHED_BORE; fi

	  for rate in ${HZTICKS}; do
		  if use hzticks_300; then
			  scripts/config -e HZ_300 --set-val HZ 300
			  break
		  fi
		  if use "hzticks_${rate}"; then
			  scripts/config -d HZ_300 -e "HZ_${rate}" --set-val HZ "${rate}"
			  break
		  fi
	  done

	  if use NUMAdisable; then
		  scripts/config -d NUMA \
			  -d AMD_NUMA \
			  -d X86_64_ACPI_NUMA \
			  -d NODES_SPAN_OTHER_NODES \
			  -d NUMA_EMU \
			  -d USE_PERCPU_NUMA_NODE_ID \
			  -d ACPI_NUMA \
			  -d ARCH_SUPPORTS_NUMA_BALANCING \
			  -d NODES_SHIFT \
			  -u NODES_SHIFT \
			  -d NEED_MULTIPLE_NODES \
			  -d NUMA_BALANCING \
			  -d NUMA_BALANCING_DEFAULT_ENABLED
	  fi

	  scripts/config --set-val NR_CPUS 320

	  if use mq_deadline_disable; then scripts/config -d MQ_IOSCHED_DEADLINE; fi
	  if use kyber_disable; then scripts/config -d MQ_IOSCHED_KYBER; fi
	  if use per_gov; then
		  scripts/config -d CPU_FREQ_DEFAULT_GOV_SCHEDUTIL \
			  -e CPU_FREQ_DEFAULT_GOV_PERFORMANCE
	  fi

	  if use tickrate_perodic; then scripts/config -d NO_HZ_IDLE -d NO_HZ_FULL -d NO_HZ -d NO_HZ_COMMON -e HZ_PERIODIC; fi
	  if use tickrate_idle; then scripts/config -d HZ_PERIODIC -d NO_HZ_FULL -e NO_HZ_IDLE -e NO_HZ -e NO_HZ_COMMON; fi
	  if use tickrate_full; then scripts/config -d HZ_PERIODIC -d NO_HZ_IDLE -d CONTEXT_TRACKING_FORCE -e NO_HZ_FULL_NODEF -e NO_HZ_FULL -e NO_HZ -e NO_HZ_COMMON -e CONTEXT_TRACKING; fi

	  if use preempt_full; then scripts/config -e PREEMPT_BUILD -d PREEMPT_NONE -d PREEMPT_VOLUNTARY -e PREEMPT -e PREEMPT_COUNT -e PREEMPTION -e PREEMPT_DYNAMIC; fi
	  if use preempt_voluntary; then scripts/config -e PREEMPT_BUILD -d PREEMPT_NONE -e PREEMPT_VOLUNTARY -d PREEMPT -e PREEMPT_COUNT -e PREEMPTION -d PREEMPT_DYNAMIC; fi
	  if use preempt_server; then scripts/config -e PREEMPT_NONE_BUILD -e PREEMPT_NONE -d PREEMPT_VOLUNTARY -d PREEMPT -d PREEMPTION -d PREEMPT_DYNAMIC; fi

	  if use cc_harder; then
		  scripts/config -d CC_OPTIMIZE_FOR_PERFORMANCE \
			  -e CC_OPTIMIZE_FOR_PERFORMANCE_O3
	  fi

	  if use tcp_bbr2; then
		  scripts/config -m TCP_CONG_CUBIC \
			  -d DEFAULT_CUBIC \
			  -e TCP_CONG_BBR2 \
			  -e DEFAULT_BBR2 \
			  --set-str DEFAULT_TCP_CONG bbr2

		  scripts/config -m NET_SCH_FQ_CODEL \
			  -e NET_SCH_FQ \
			  -d DEFAULT_FQ_CODEL \
			  -e DEFAULT_FQ \
			  --set-str DEFAULT_NET_SCH fq
	  fi

	  if use lru_standard; then scripts/config -e LRU_GEN -e LRU_GEN_ENABLED -d LRU_GEN_STATS; fi
	  if use lru_stats; then scripts/config -e LRU_GEN -e LRU_GEN_ENABLED -e LRU_GEN_STATS; fi
	  if use lru_none; then scripts/config -d LRU_GEN; fi

	  if use vma_standard; then scripts/config -e PER_VMA_LOCK -d PER_VMA_LOCK_STATS; fi
	  if use vma_stats; then scripts/config -e PER_VMA_LOCK -e PER_VMA_LOCK_STATS; fi
	  if use vma_none; then scripts/config -d PER_VMA_LOCK; fi

	  if use hugepage_always; then scripts/config -d TRANSPARENT_HUGEPAGE_MADVISE -e TRANSPARENT_HUGEPAGE_ALWAYS; fi
	  if use hugepage_madvise; then scripts/config -d TRANSPARENT_HUGEPAGE_ALWAYS -e TRANSPARENT_HUGEPAGE_MADVISE; fi

	  if use damon; then
		  scripts/config -e DAMON \
			  -e DAMON_VADDR \
			  -e DAMON_DBGFS \
			  -e DAMON_SYSFS \
			  -e DAMON_PADDR \
			  -e DAMON_RECLAIM \
			  -e DAMON_LRU_SORT
	  fi

	  if use lrng; then
		  scripts/config -d RANDOM_DEFAULT_IMPL \
			  -e LRNG \
			  -e LRNG_SHA256 \
			  -e LRNG_COMMON_DEV_IF \
			  -e LRNG_DRNG_ATOMIC \
			  -e LRNG_SYSCTL \
			  -e LRNG_RANDOM_IF \
			  -e LRNG_AIS2031_NTG1_SEEDING_STRATEGY \
			  -m LRNG_KCAPI_IF \
			  -m LRNG_HWRAND_IF \
			  -e LRNG_DEV_IF \
			  -e LRNG_RUNTIME_ES_CONFIG \
			  -e LRNG_IRQ_DFLT_TIMER_ES \
			  -d LRNG_SCHED_DFLT_TIMER_ES \
			  -e LRNG_TIMER_COMMON \
			  -d LRNG_COLLECTION_SIZE_256 \
			  -d LRNG_COLLECTION_SIZE_512 \
			  -e LRNG_COLLECTION_SIZE_1024 \
			  -d LRNG_COLLECTION_SIZE_2048 \
			  -d LRNG_COLLECTION_SIZE_4096 \
			  -d LRNG_COLLECTION_SIZE_8192 \
			  --set-val LRNG_COLLECTION_SIZE 1024 \
			  -e LRNG_HEALTH_TESTS \
			  --set-val LRNG_RCT_CUTOFF 31 \
			  --set-val LRNG_APT_CUTOFF 325 \
			  -e LRNG_IRQ \
			  -e LRNG_CONTINUOUS_COMPRESSION_ENABLED \
			  -d LRNG_CONTINUOUS_COMPRESSION_DISABLED \
			  -e LRNG_ENABLE_CONTINUOUS_COMPRESSION \
			  -e LRNG_SWITCHABLE_CONTINUOUS_COMPRESSION \
			  --set-val LRNG_IRQ_ENTROPY_RATE 256 \
			  -e LRNG_JENT \
			  --set-val LRNG_JENT_ENTROPY_RATE 16 \
			  -e LRNG_CPU \
			  --set-val LRNG_CPU_FULL_ENT_MULTIPLIER 1 \
			  --set-val LRNG_CPU_ENTROPY_RATE 8 \
			  -e LRNG_SCHED \
			  --set-val LRNG_SCHED_ENTROPY_RATE 4294967295 \
			  -e LRNG_DRNG_CHACHA20 \
			  -m LRNG_DRBG \
			  -m LRNG_DRNG_KCAPI \
			  -e LRNG_SWITCH \
			  -e LRNG_SWITCH_HASH \
			  -m LRNG_HASH_KCAPI \
			  -e LRNG_SWITCH_DRNG \
			  -m LRNG_SWITCH_DRBG \
			  -m LRNG_SWITCH_DRNG_KCAPI \
			  -e LRNG_DFLT_DRNG_CHACHA20 \
			  -d LRNG_DFLT_DRNG_DRBG \
			  -d LRNG_DFLT_DRNG_KCAPI \
			  -e LRNG_TESTING_MENU \
			  -d LRNG_RAW_HIRES_ENTROPY \
			  -d LRNG_RAW_JIFFIES_ENTROPY \
			  -d LRNG_RAW_IRQ_ENTROPY \
			  -d LRNG_RAW_RETIP_ENTROPY \
			  -d LRNG_RAW_REGS_ENTROPY \
			  -d LRNG_RAW_ARRAY \
			  -d LRNG_IRQ_PERF \
			  -d LRNG_RAW_SCHED_HIRES_ENTROPY \
			  -d LRNG_RAW_SCHED_PID_ENTROPY \
			  -d LRNG_RAW_SCHED_START_TIME_ENTROPY \
			  -d LRNG_RAW_SCHED_NVCSW_ENTROPY \
			  -d LRNG_SCHED_PERF \
			  -d LRNG_ACVT_HASH \
			  -d LRNG_RUNTIME_MAX_WO_RESEED_CONFIG \
			  -d LRNG_TEST_CPU_ES_COMPRESSION \
			  -e LRNG_SELFTEST \
			  -d LRNG_SELFTEST_PANIC \
			  -d LRNG_RUNTIME_FORCE_SEEDING_DISABLE
	  fi

	  if use zstdlevel_ultra; then scripts/config --set-val MODULE_COMPRESS_ZSTD_LEVEL 19 -e MODULE_COMPRESS_ZSTD_ULTRA --set-val MODULE_COMPRESS_ZSTD_LEVEL_ULTRA 22 --set-val ZSTD_COMPRESSION_LEVEL 22; fi
	  if use zstdlevel_normal; then scripts/config --set-val MODULE_COMPRESS_ZSTD_LEVEL 9 -d MODULE_COMPRESS_ZSTD_ULTRA --set-val ZSTD_COMPRESSION_LEVEL 19; fi

	  if use disable_debug; then
		  scripts/config -d DEBUG_INFO \
			  -d DEBUG_INFO_BTF \
			  -d DEBUG_INFO_DWARF4 \
			  -d DEBUG_INFO_DWARF5 \
			  -d PAHOLE_HAS_SPLIT_BTF \
			  -d DEBUG_INFO_BTF_MODULES \
			  -d SLUB_DEBUG \
			  -d PM_DEBUG \
			  -d PM_ADVANCED_DEBUG \
			  -d PM_SLEEP_DEBUG \
			  -d ACPI_DEBUG \
			  -d SCHED_DEBUG \
			  -d LATENCYTOP \
			  -d DEBUG_PREEMPT
	  fi

	  scripts/config -e USER_NS
	  scripts/config --set-str DEFAULT_HOSTNAME "gentoo"
  }

  pkg_postinst() {
	  kernel-2_pkg_postinst
	  einfo "For more info on this patchset, and how to report problems, see:"
	  einfo "${HOMEPAGE}"
  }

  pkg_postrm() {
	  kernel-2_pkg_postrm
  }
