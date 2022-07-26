# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
#DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_10 )
inherit distutils-r1

DESCRIPTION="Wayland compositor core employing wlroots - aims to handle the actual layout logic in python."
HOMEPAGE="https://github.com/jbuchermn/pywm"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_BRANCH="master"
	EGIT_CLONE_TYPE="shallow"
	EGIT_REPO_URI="https://github.com/jbuchermn/${PN}.git"
else
	# Maybe I'll add stable packages once it releases
	KEYWORDS="~amd64"
fi

#LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="dev-lang/python
		gui-libs/wlroots
		dev-python/imageio
		dev-python/numpy
		dev-python/pycairo
		dev-python/python-evdev"
DEPEND="${RDEPEND}"
BDEPEND="${RDEPEND}
		virtual/pkgconfig"
