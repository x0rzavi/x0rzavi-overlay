# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit cmake

CACHY_COMMIT="eed6f55fdaf207d36b428ae69337aa06b9a8664a" # ananicy rules by CACHYOS

DESCRIPTION="Ananicy rewritten in C++ for much lower CPU and memory usage"
HOMEPAGE="https://gitlab.com/ananicy-cpp/ananicy-cpp"
SRC_URI="https://gitlab.com/ananicy-cpp/ananicy-cpp/-/archive/v${PV}/${PN}-v${PV}.tar.bz2
		https://github.com/CachyOS/ananicy-rules/archive/${CACHY_COMMIT}.tar.gz -> ananicy-rules-${CACHY_COMMIT}.tar.gz"
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd +bpf"

RDEPEND="
	dev-cpp/nlohmann_json
	dev-libs/libfmt
	dev-libs/spdlog
	systemd? ( sys-apps/systemd )
	bpf? ( dev-libs/elfutils dev-libs/libbpf dev-util/bpftool )
"
DEPEND="
	${RDEPEND}
	dev-cpp/std-format
"
BDEPEND="bpf? ( sys-devel/clang )"

PATCHES=(
	#"${FILESDIR}/${P}-system-std-format.patch"
	#"${FILESDIR}/${P}-bpf-nostackprotector.patch"
)

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DENABLE_SYSTEMD=$(usex systemd)
		-DUSE_EXTERNAL_FMTLIB=ON
		-DUSE_EXTERNAL_JSON=ON
		-DUSE_EXTERNAL_SPDLOG=ON
		-DUSE_BPF_PROC_IMPL=$(usex bpf)
		-DBPF_BUILD_LIBBPF=OFF
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	insinto /etc
	mv "${WORKDIR}/ananicy-rules-${CACHY_COMMIT}" "${WORKDIR}/ananicy.d" || die
	doins -r "${WORKDIR}/ananicy.d"
}
