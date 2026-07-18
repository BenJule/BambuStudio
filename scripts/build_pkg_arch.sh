#!/bin/bash
# Build a pacman (.pkg.tar.zst) package from the already-compiled build/package/
# directory (Arch Linux). Mirrors scripts/build_deb.sh; run after BuildLinux.sh -s.
# fpm's pacman target is used so packaging works as root (makepkg refuses root).
set -e

ROOT=$(dirname "$(readlink -f "$0")")/..

BASE=$(grep 'set(SLIC3R_VERSION_BASE' "$ROOT/version.inc" | cut -d '"' -f2)
if [ -n "$BASE" ]; then
    COUNT=$(git -C "$ROOT" rev-list --count HEAD 2>/dev/null || echo "0")
    VERSION="${BASE}.${COUNT}"
else
    VERSION=$(grep 'set(SLIC3R_VERSION ' "$ROOT/version.inc" | cut -d '"' -f2)
fi
if [ -z "$VERSION" ]; then
    echo "Error: could not read version from version.inc" >&2
    exit 1
fi

PKGNAME="bambustudio"
ARCH="x86_64"
APPDIR="$ROOT/build/package"
PKGDIR="$ROOT/build/${PKGNAME}-pkgroot"
OUTFILE="$ROOT/build/${PKGNAME}-${VERSION}-1-${ARCH}.pkg.tar.zst"

if [ ! -f "$APPDIR/bin/bambu-studio" ]; then
    echo "Error: build/package/bin/bambu-studio not found." >&2
    echo "Run './BuildLinux.sh -s' first." >&2
    exit 1
fi

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

if ! command -v fpm >/dev/null 2>&1; then
    echo "Installing fpm..."
    $SUDO pacman -Sy --needed --noconfirm ruby gcc make fakeroot
    export PATH="$PATH:$(ruby -e 'print Gem.user_dir')/bin:/usr/bin/core_perl"
    # Ruby 3.4 dropped erb from the default gems; fpm needs it explicitly.
    gem install --user-install --no-document erb fpm
fi
export PATH="$PATH:$(ruby -e 'print Gem.user_dir')/bin"

echo "Building pacman package for BambuStudio ${VERSION}..."
rm -rf "$PKGDIR"
mkdir -p "$PKGDIR"

mkdir -p "$PKGDIR/usr/bin"
mkdir -p "$PKGDIR/usr/lib/$PKGNAME/bin"
mkdir -p "$PKGDIR/usr/share/applications"
mkdir -p "$PKGDIR/usr/share/icons/hicolor/192x192/apps"
mkdir -p "$PKGDIR/usr/share/icons/hicolor/128x128/apps"
mkdir -p "$PKGDIR/usr/share/icons/hicolor/32x32/apps"

cp "$APPDIR/bin/bambu-studio" "$PKGDIR/usr/lib/$PKGNAME/bin/"

find "$APPDIR/bin" -name "*.so*" \
    ! -name "libgtk*"     ! -name "libgdk*"      ! -name "libgdk-pixbuf*" \
    ! -name "libglib*"    ! -name "libgobject*"   ! -name "libgio*" \
    ! -name "libgmodule*" ! -name "libgthread*" \
    ! -name "libX*"       ! -name "libxcb*"       ! -name "libxkbcommon*" \
    ! -name "libwayland*" \
    ! -name "libdbus*"    ! -name "libudev*"      \
    ! -name "libsecret*"  ! -name "libfontconfig*" \
    ! -name "libfreetype*" ! -name "libpango*"    ! -name "libcairo*" \
    ! -name "libatk*"     ! -name "libharfbuzz*"  \
    -exec cp {} "$PKGDIR/usr/lib/$PKGNAME/" \;

cp -r "$APPDIR/resources" "$PKGDIR/usr/lib/$PKGNAME/"

cat > "$PKGDIR/usr/bin/$PKGNAME" <<'WRAPPER'
#!/bin/bash
export LD_LIBRARY_PATH="/usr/lib/bambustudio${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec /usr/lib/bambustudio/bin/bambu-studio "$@"
WRAPPER
chmod 755 "$PKGDIR/usr/bin/$PKGNAME"

sed 's|^Exec=.*|Exec=/usr/bin/bambustudio %U|' \
    "$APPDIR/BambuStudio.desktop" \
    > "$PKGDIR/usr/share/applications/$PKGNAME.desktop"

for SIZE in 192x192 128x128 32x32; do
    SRC="$APPDIR/usr/share/icons/hicolor/$SIZE/apps/BambuStudio.png"
    DST="$PKGDIR/usr/share/icons/hicolor/$SIZE/apps/$PKGNAME.png"
    [ -f "$SRC" ] && cp "$SRC" "$DST"
done

POST=$(mktemp)
cat > "$POST" <<'EOF'
#!/bin/bash
update-desktop-database /usr/share/applications 2>/dev/null || true
gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
EOF

rm -f "$OUTFILE"
fpm -s dir -t pacman -f \
    --name "$PKGNAME" --version "$VERSION" --iteration 1 --architecture "$ARCH" \
    --license "AGPL-3.0" --vendor "Bambu Lab" --url "https://bambulab.com" \
    --category "Graphics" \
    --description "BambuStudio 3D printing slicer.
Supports Bambu Lab 3D printers. Based on PrusaSlicer." \
    --depends gtk3 \
    --depends webkit2gtk-4.1 \
    --depends mesa \
    --depends glu \
    --depends dbus \
    --depends libsecret \
    --depends libxkbcommon \
    --depends gstreamer \
    --depends gst-plugins-base \
    --depends gst-plugins-good \
    --depends zenity \
    --after-install "$POST" \
    --after-remove "$POST" \
    -C "$PKGDIR" -p "$OUTFILE" \
    usr

rm -f "$POST"
echo "Created: $OUTFILE"
