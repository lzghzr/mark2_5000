VERSION=`cat module.prop | head -n 4 | tail -n 1 | sed 's/.\{12\}//'`
sed -i "3s/[0-9]\+/$VERSION/" ./module.prop
sed -i "2,3s/[0-9]\+/$VERSION/" ./update.json
sed -i "4s/v[0-9]\+/v$VERSION/g" ./update.json

rm -f ./mark2_5000_v${VERSION}.zip
dtc -@ -I dts -O dtb -o ./dtbo/origin_pdx203.dtbo ./dts/origin_pdx203.dts &> /dev/null
dtc -@ -I dts -O dtb -o ./dtbo/origin_pdx206.dtbo ./dts/origin_pdx206.dts &> /dev/null
dtc -@ -I dts -O dtb -o ./dtbo/overlay_pdx203.dtbo ./dts/overlay_pdx203.dts &> /dev/null
dtc -@ -I dts -O dtb -o ./dtbo/overlay_pdx206.dtbo ./dts/overlay_pdx206.dts &> /dev/null
zip -qr mark2_5000_v${VERSION}.zip ./ -i "bin/*" -i "dtbo/*.dtbo" -i "META-INF/*" -i "system/*" -i "customize.sh" -i "module.prop" -i "uninstall.sh"
