#!/bin/bash
# 🔧 QuemOS Repository Auto Updater
# /repo dizininde bulunan Debian APT deposu için Release / InRelease dosyalarını yeniler.

set -e

# === KULLANICI AYARLARI ===
REPO_DIR="/home/user/GitHub/repo"     # 🔹 Depo kökü
DIST="stable"
COMPONENT="main"
ARCH="amd64"
GPG_KEY_ID="FD3D7643188459E6"         # 🔹 Kendi GPG anahtar kimliğini buraya yaz

echo "=== 🔄 QuemOS Repo Güncelleyici ==="
echo "Repo dizini: $REPO_DIR"
echo

# === 1️⃣ Packages dosyaları oluştur ===
echo "📦 Paket listesi oluşturuluyor..."
apt-ftparchive packages $REPO_DIR/pool/$COMPONENT > $REPO_DIR/dists/$DIST/$COMPONENT/binary-$ARCH/Packages
gzip -kf $REPO_DIR/dists/$DIST/$COMPONENT/binary-$ARCH/Packages
xz -kf $REPO_DIR/dists/$DIST/$COMPONENT/binary-$ARCH/Packages

# === 2️⃣ Release dosyası oluştur ===
echo "🗂️ Release dosyası hazırlanıyor..."

# apt-ftparchive.conf varsa onu kullan
if [ -f "$REPO_DIR/apt-ftparchive.conf" ]; then
    echo "⚙️  Harici yapılandırma bulundu: apt-ftparchive.conf"
    apt-ftparchive -c=$REPO_DIR/apt-ftparchive.conf release $REPO_DIR/dists/$DIST > $REPO_DIR/dists/$DIST/Release
else
    echo "⚙️  apt-ftparchive.conf bulunamadı, varsayılan yapılandırma uygulanıyor."
    cat > $REPO_DIR/apt-ftparchive.conf <<EOF
APT::FTPArchive::Release {
  Origin "QuemOS";
  Label "QuemOS Repo";
  Suite "$DIST";
  Codename "$DIST";
  Architectures "$ARCH";
  Components "$COMPONENT";
  Description "QuemOS Custom Repository";
};
EOF
    apt-ftparchive -c=$REPO_DIR/apt-ftparchive.conf release $REPO_DIR/dists/$DIST > $REPO_DIR/dists/$DIST/Release
fi

# === 3️⃣ GPG imzalama (/repo içinde yapılır) ===
echo "🔏 GPG imzası oluşturuluyor..."
cd $REPO_DIR
gpg --clearsign -u "$GPG_KEY_ID" -o dists/$DIST/InRelease dists/$DIST/Release
gpg -abs -u "$GPG_KEY_ID" -o dists/$DIST/Release.gpg dists/$DIST/Release

# === 4️⃣ Temizlik ===
echo "🧹 Geçici dosyalar temizleniyor..."
rm -f $REPO_DIR/apt.conf 2>/dev/null || true

# === 5️⃣ Sonuç ===
echo
echo "✅ Repo başarıyla güncellendi!"
echo "📁 Dosyalar:"
echo "  → $REPO_DIR/dists/$DIST/Release"
echo "  → $REPO_DIR/dists/$DIST/InRelease"
echo "  → $REPO_DIR/dists/$DIST/Release.gpg"
echo
echo "🔹 Değişiklikleri GitHub’a göndermek için:"
echo "  cd $REPO_DIR && git add . && git commit -m 'Repo updated' && git push"
