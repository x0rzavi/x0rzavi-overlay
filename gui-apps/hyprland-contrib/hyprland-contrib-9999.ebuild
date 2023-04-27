# Copyright 2023 Gentoo Authors
# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

DESCRIPTION="Community scripts and utilities for Hypr projects"
HOMEPAGE="https://github.com/hyprwm/contrib"

MY_PN="contrib"
inherit git-r3
EGIT_REPO_URI="https://github.com/hyprwm/${MY_PN}.git"

KEYWORDS="~amd64"
LICENSE="BSD"
SLOT="0"
IUSE="grimblast scratchpad shellevents hyprprop"

RDEPEND="
	grimblast? (
		 gui-apps/grim
		 gui-apps/slurp
		 gui-apps/wl-clipboard
		 x11-libs/libnotify
	)
	hyprprop? (
		gui-apps/slurp
		app-misc/jq
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	grimblast? ( app-text/scdoc )
	shellevents? ( app-text/scdoc )
	hyprprop? ( app-text/scdoc )
"

src_install() {
	use grimblast && emake PREFIX="${ED}/usr" -C "grimblast" install
	use scratchpad && emake PREFIX="${ED}/usr" -C "scratchpad" install
	use shellevents && emake PREFIX="${ED}/usr" -C "shellevents" install
	use hyprprop && emake PREFIX="${ED}/usr" -C "hyprprop" install
}
