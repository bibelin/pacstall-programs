pkgbase="libada"
pkgname=("libada2" "libada-dev")
pkgdesc="WHATWG-compliant and fast URL parser written in modern C++"
pkgver="2.9.2"
arch=("all")
url="https://github.com/ada-url/ada"
license=("Apache-2.0" "MIT")
makedepends=("cmake" "gcc")
source=(
  "${url}/archive/refs/tags/v${pkgver}.tar.gz"
)
sha256sum=(
  "f41575ad7eec833afd9f6a0d6101ee7dc2f947fdf19ae8f1b54a71d59f4ba5ec"
)
# During the build the library downloads https://github.com/cpm-cmake/CPM.cmake
# and then uses it to fetch some other git repos.
# I'm not sure if this can be worked around.
external_connection=true
maintainer="bibelin <balian1belin@yandex.ru>"

build() {
  cmake -B build -S "ada-${pkgver}" \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="/usr" \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF
  cmake --build build -j"${NCPU}"

  mkdir output
  DESTDIR="${srcdir}/output" cmake --install build
}

package_libada2() {
  install -Dm755 "output/usr/bin/adaparse" "${pkgdir}/usr/bin/adaparse"
  find "output/usr/lib" -type "f" -exec install -Dm644 "{}" -t "${pkgdir}/usr/lib/$(gcc -dumpmachine)/" \;
  local license
  for license in "APACHE" "MIT"; do
    install -Dm644 "ada-${pkgver}/LICENSE-${license}" -t "${pkgdir}/usr/share/doc/libada2/"
  done
}

package_libada-dev() {
  pkgdesc="${pkgdesc} (development files)"
  find "output/usr/include" -type "f" -exec install -Dm644 "{}" -t "${pkgdir}/usr/include/" \;
  local license
  for license in "APACHE" "MIT"; do
    install -Dm644 "ada-${pkgver}/LICENSE-${license}" -t "${pkgdir}/usr/share/doc/libada-dev/"
  done
}
