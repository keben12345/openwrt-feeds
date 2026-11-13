#!/bin/bash -e

# backup feeds
shopt -s extglob
mkdir -p /tmp/lite/
mv */ /tmp/lite/

# download feeds
git clone https://github.com/immortalwrt/luci immortalwrt/luci -b master --depth 1
git clone https://github.com/immortalwrt/packages immortalwrt/packages -b master --depth 1
git clone https://github.com/immortalwrt/homeproxy immortalwrt/luci-app-homeproxy --depth 1
git clone https://github.com/sbwml/openwrt_helloworld --depth 1
git clone https://github.com/nikkinikki-org/OpenWrt-nikki openwrt-nikki --depth 1
git clone https://github.com/pmkol/v2ray-geodata --depth 1
# git clone -b dev https://github.com/vernesong/OpenClash --depth 1

# OpenClash - 固定版本 v0.47.156
OPENCLASH_VERSION="v0.47.156"
OPENCLASH_REPO="https://github.com/vernesong/OpenClash"

echo "========================================"
echo "Downloading OpenClash ${OPENCLASH_VERSION}"
echo "========================================"

# 清理旧目录
rm -rf OpenClash

# 下载指定版本，不跟随 dev 最新更新
git clone \
    --branch "${OPENCLASH_VERSION}" \
    --depth 1 \
    --single-branch \
    "${OPENCLASH_REPO}" OpenClash

# 检查 Tag
ACTUAL_VERSION=$(git -C OpenClash describe --tags --exact-match HEAD)
if [ "${ACTUAL_VERSION}" != "${OPENCLASH_VERSION}" ]; then
    echo "ERROR: OpenClash version mismatch!"
    exit 1
fi

# 检查 Commit，防止 Tag 指向意外变更
ACTUAL_COMMIT=$(git -C OpenClash rev-parse HEAD)
EXPECTED_COMMIT="c3a33c1"

if [ "${ACTUAL_COMMIT:0:7}" != "${EXPECTED_COMMIT}" ]; then
    echo "ERROR: OpenClash commit mismatch!"
    echo "Expected: ${EXPECTED_COMMIT}"
    echo "Actual:   ${ACTUAL_COMMIT}"
    exit 1
fi

echo "OpenClash version: ${ACTUAL_VERSION}"
echo "OpenClash commit:  ${ACTUAL_COMMIT}"

# 后续原有整理步骤保持不变

rm -rf immortalwrt/luci-app-homeproxy/{.git,.github,LICENSE,README}
rm -rf openwrt_helloworld/{sing-box,luci-app-homeproxy,luci-app-nikki,nikki,v2ray-geodata,luci-app-openclash,luci-app-ssr-plus}
rm -rf v2ray-geodata/.git
mv -f openwrt_helloworld/*.patch ./
mv OpenClash/*/ ./
rm -rf OpenClash

# helloworld
mv openwrt_helloworld/*/ ./
rm -rf openwrt_helloworld

# luci-app-dae
mv immortalwrt/luci/applications/luci-app-dae ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-dae/Makefile
mv immortalwrt/packages/net/dae ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' dae/Makefile


# luci-app-nikki
mv openwrt-nikki/*/ ./
rm -rf openwrt-nikki

git clone https://github.com/nikkinikki-org/OpenWrt-momo OpenWrt-momo --depth 1
mv OpenWrt-momo/*/ ./
rm -rf OpenWrt-momo

mv immortalwrt/luci-app-homeproxy ./



# rm -rf immortalwrt *.patch
# rm -rf img
# ls -d */ | xargs -n 1 basename | paste -sd ' ' - > packages.txt
ls -d */ | xargs -n 1 basename | grep "^luci-app" | while read pkg; do
    echo "CONFIG_PACKAGE_${pkg}=y"
done > packages.txt
