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
git clone -b dev https://github.com/vernesong/OpenClash --depth 1
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
