# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# https://gitweb.gentoo.org/repo/gentoo.git/tree/gui-libs/xdg-desktop-portal-wlr/xdg-desktop-portal-wlr-0.6.0.ebuild
# https://github.com/Wa1t5/useless-overlay/blob/main/gui-libs/xdg-desktop-portal-hyprland/xdg-desktop-portal-hyprland-9999.ebuild
# https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xdg-desktop-portal-hyprland-git

EAPI=8

inherit meson

DESCRIPTION="xdg-desktop-portal backend for hyprland"
HOMEPAGE="https://github.com/hyprwm/xdg-desktop-portal-hyprland"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_BRANCH="master"
	EGIT_CLONE_TYPE="shallow"
	EGIT_REPO_URI="https://github.com/hyprwm/${PN}.git"
else
	RESTRICT="mirror"
	KEYWORDS="~amd64"
fi

LICENSE="MIT"
SLOT="0/9999"
IUSE="elogind systemd"
REQUIRED_USE="?? ( elogind systemd )"
DOCS="LICENSE README.md"

DEPEND="
	>=media-video/pipewire-0.3.41:=
	dev-libs/inih
	dev-libs/wayland
	media-libs/mesa
	x11-libs/libdrm
	|| (
		systemd? ( >=sys-apps/systemd-237 )
		elogind? ( >=sys-auth/elogind-237 )
		sys-libs/basu
	)
"
# mesa is needed for gbm dep (which it hards sets to 'on')
RDEPEND="
	${DEPEND}
	sys-apps/xdg-desktop-portal
	>=dev-qt/qtbase-6.4.2
	>=dev-qt/qtwayland-6.4.2
	gui-apps/slurp
	gui-apps/grim
"
BDEPEND="
	>=dev-libs/wayland-protocols-1.24
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=()

	if use systemd; then
		emesonargs+=(-Dsd-bus-provider=libsystemd)
	elif use elogind; then
		emesonargs+=(-Dsd-bus-provider=libelogind)
	else
		emesonargs+=(-Dsd-bus-provider=basu)
	fi
	meson_src_configure
}

src_compile() {
	meson_src_compile
	cd hyprland-share-picker
	emake
}


src_install() {
	meson_install
	dobin hyprland-share-picker/build/hyprland-share-picker
}
