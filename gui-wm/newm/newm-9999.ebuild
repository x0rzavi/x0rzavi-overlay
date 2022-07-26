# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
inherit python-single-r1

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

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
		gui-libs/pywm
		dev-python/pycairo
		dev-python/psutil
		dev-python/python-pam
		dev-python/pyfiglet[python_targets_python3_9]
		dev-python/dasbus
		dev-python/fuzzywuzzy"
DEPEND="${RDEPEND}"
BDEPEND="${RDEPEND}"

src_compile () {
	"${EPYTHON}" setup.py build
}

src_install () {
	"${EPYTHON}" setup.py install --root="${D}" --optimize=1
	python_optimize
	
	einstalldocs
	insinto /usr/share/wayland-sessions
	doins ${S}/newm/resources/newm.desktop
}
