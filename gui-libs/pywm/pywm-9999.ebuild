# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit python-single-r1

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

LICENSE="MIT"
SLOT="0"
IUSE=""

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
		gui-libs/wlroots
		dev-python/imageio
		dev-python/numpy
		dev-python/pycairo
		dev-python/python-evdev"
DEPEND="${RDEPEND}"
BDEPEND="${RDEPEND}"

src_compile () {
	"${EPYTHON}" setup.py build
}

src_install () {
	"${EPYTHON}" setup.py install --root="${D}" --optimize=1
	python_optimize
	einstalldocs
}
