#!/usr/bin/env bash
set -euo pipefail
# Help: curl https://sh.wss.moe/waylyrics.help

echo "=== Waylyrics Build & Install ==="
echo "Help: curl https://sh.wss.moe/waylyrics.help"
echo "Contact: https://wyf9.top/c"
echo ""

sudo apt install -y git rustup build-essential libssl-dev libgtk-4-dev libdbus-1-dev libmimalloc-dev gettext

rustup update stable

mkdir -p gittemp && cd gittemp
git clone https://github.com/waylyrics/waylyrics.git
cd waylyrics

export WAYLYRICS_THEME_PRESETS_DIR=/usr/share/waylyrics/themes
cargo build --release --locked --target-dir target

sudo cp ./target/release/waylyrics /usr/bin/
sudo chmod 755 /usr/bin/waylyrics

sudo cp ./metainfo/io.github.waylyrics.Waylyrics.gschema.xml /usr/share/glib-2.0/schemas/
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

cd ./locales/zh_CN/LC_MESSAGES/
msgfmt waylyrics.po
sudo cp ./messages.mo /usr/share/locale/zh_CN/LC_MESSAGES/waylyrics.mo
cd ../../..

sudo cp -r ./res/icons/* /usr/share/icons/
sudo cp ./metainfo/io.github.waylyrics.Waylyrics.desktop /usr/share/applications/
sudo chmod 644 /usr/share/applications/io.github.waylyrics.Waylyrics.desktop

sudo mkdir -p /usr/share/waylyrics/themes/
sudo cp -r ./themes/* /usr/share/waylyrics/themes/
sudo chmod 755 -R /usr/share/waylyrics/themes/

sudo cp ./metainfo/io.github.waylyrics.Waylyrics.metainfo.xml /usr/share/metainfo/
sudo update-desktop-database

cd ../.. && rm -rf gittemp

echo "Done."
