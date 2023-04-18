# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

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
	SRC_URI="https://github.com/hyprwm/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="BSD"
SLOT="0"
DOCS="LICENSE README.md"

RDEPEND="dev-libs/wayland
		media-libs/libglvnd
		media-libs/libjpeg-turbo
		x11-libs/pango
		x11-libs/cairo
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig
		dev-libs/wayland-protocols
		dev-util/cmake"

src_compile() {
	emake all
}

src_install () {
	dobin "build/${PN}"
	einstalldocs
}
