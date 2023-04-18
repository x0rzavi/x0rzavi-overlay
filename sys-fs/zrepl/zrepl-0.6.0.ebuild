# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit go-module systemd

DESCRIPTION="One-stop ZFS backup & replication solution"
HOMEPAGE="https://github.com/zrepl/zrepl"

LICENSE="GPL-3"
SLOT="0"
IUSE="+pie zsh-completion bash-completion"

KEYWORDS="~amd64"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

SRC_URI="https://github.com/zrepl/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		 https://github.com/x0rzavi/x0rzavi-overlay/raw/main/${CATEGORY}/${PN}/files/${P}-deps.tar.xz"
DOCS="README.md LICENSE"

src_compile () {
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_CPPFLAGS="${CXXFLAGS}"
	export CGO_CXXFLAGS="${CXXFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"

	if use pie ; then
		ego build \
		--buildmode=pie \
		-trimpath \
		-mod=readonly \
		-modcacherw \
		-ldflags "-s -w -linkmode external -X github.com/zrepl/zrepl/version.zreplVersion=${PV}" \
		-o "${PN}" .
	else
		ego build \
		-trimpath \
		-mod=readonly \
		-modcacherw \
		-ldflags "-s -w -linkmode external -X main.version=${PV}" \
		-o "${PN}" .
	fi
}

src_install() {
	dobin "${PN}"
	einstalldocs

	if use zsh-completion ; then
		"${D}/usr/bin/${PN}" gencompletion zsh _zrepl
		insinto /usr/share/zsh/site-functions
		doins _zrepl
	fi
	if use bash-completion ; then
		"${D}/usr/bin/${PN}" gencompletion bash zrepl
		insinto /usr/share/bash-completion/completions
		doins zrepl
	fi

	insinto "/usr/share/${PN}/samples"
	doins config/samples/*

	# doinitd dist/openrc/zrepl
	newinitd "${FILESDIR}/zrepl-0.6.0.initd" zrepl
	systemd_dounit dist/systemd/zrepl.service
}
