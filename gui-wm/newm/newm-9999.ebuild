# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
#DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_10 )
inherit distutils-r1

DESCRIPTION="A Wayland compositor written with laptops and touchpads in mind."
HOMEPAGE="https://github.com/jbuchermn/newm"

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

RDEPEND="gui-libs/pywm
		dev-python/pycairo
		dev-python/psutil
		dev-python/python-pam
		dev-python/pyfiglet
		dev-python/dasbus
		dev-python/fuzzywuzzy"
DEPEND="${RDEPEND}"
BDEPEND="${RDEPEND}
		virtual/pkgconfig"

python_install_all () {
	insinto /usr/share/wayland-sessions
	doins ${S}/newm/resources/newm.desktop
	python_doscript ${S}/bin/.start-newm
	distutils-r1_python_install_all
}
