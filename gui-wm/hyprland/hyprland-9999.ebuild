# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit ninja-utils

DESCRIPTION="A dynamic tiling Wayland compositor that doesn't sacrifice on its looks."
HOMEPAGE="https://github.com/hyprwm/Hyprland"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_BRANCH="main"
	EGIT_CLONE_TYPE="shallow"
	EGIT_REPO_URI="https://github.com/vaxerski/${PN}.git"
else
	# Maybe I'll add stable packages once it releases
	KEYWORDS="~amd64"
fi

LICENSE="BSD-3"
SLOT="0"
IUSE=""

RDEPEND="x11-libs/libxcb
		 x11-base/xcb-proto
		 x11-libs/xcb-util
		 x11-libs/xcb-util-keysyms
		 x11-libs/libXfixes
		 x11-libs/libX11
		 x11-libs/libXcomposite
		 x11-apps/xinput
		 x11-libs/libXrender
		 x11-libs/pixman
		 dev-libs/wayland-protocols
		 gui-libs/wlroots
		 x11-libs/cairo
		 x11-libs/pango
"
DEPEND="${RDEPEND}"
BDEPEND="|| ( >=sys-devel/gcc-12.1.0 >=sys-devel/clang-15 )
		 dev-util/ninja
		 dev-util/cmake
		 dev-util/meson
		 gui-libs/wlroots
		 virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${P}-fix-insecure-rpaths.patch"
)

src_compile() {
	# Build hyprland and wlroots
	emake fixwlr
	cd ${S}/subprojects/wlroots && meson ${S}/subprojects/wlroots/build/ --buildtype=release \
		&& eninja -C ${S}/subprojects/wlroots/build/ && cd ${S} || die "Building wlroots unsuccessful!"
	emake protocols
	emake release
	cd ${S}/hyprctl && emake all
}

src_install() {
	# Install wlroots library
	insinto /usr/lib64/
	doins ${S}/subprojects/wlroots/build/libwlroots.so.11032

	# Install hyprland sessions
	insinto /usr/share/wayland-sessions
	doins ${S}/example/hyprland.desktop

	# Install hyprland binaries
	dobin ${S}/build/Hyprland ${S}/hyprctl/hyprctl

	# Install hyprland default wallpapers
	insinto /usr/share/hyprland
	doins ${S}/assets/wall_2K.png ${S}/assets/wall_4K.png ${S}/assets/wall_8K.png
}
