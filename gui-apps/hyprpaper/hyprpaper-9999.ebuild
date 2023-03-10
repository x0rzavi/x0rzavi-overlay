# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Hyprpaper is a blazing fast wayland wallpaper utility with IPC controls"
HOMEPAGE="https://github.com/hyprwm/hyprpaper"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_BRANCH="main"
	EGIT_CLONE_TYPE="shallow"
	EGIT_REPO_URI="https://github.com/hyprwm/${PN}.git"
else
	RESTRICT="mirror"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0"
IUSE=""
DOCS="LICENSE README.md"

RDEPEND="dev-libs/wayland
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig
		dev-libs/wayland-protocols
		dev-util/cmake"

src_compile() {
	make all
}

src_install () {
	dobin build/${PN}
	einstalldocs
}
