# 警告
warning () {
  ui_print "***************************************"
  ui_print "********     ！！！警告！！！   *********"
  ui_print "***************************************"
  ui_print "**  请确保手边有电脑并且已备份dtbo.img  **"
  ui_print "**  本脚本仅适用于二代换四代电池使用     **"
  ui_print "**  由于无法检测电池信息，请自行判断     **"
  ui_print "**  安装后需重启设备                   **"
  ui_print "**  第一次安装时可能造成系统电量异常     **"
  ui_print "**  无需担心，正常使用、充电即可         **"
  ui_print "***************************************"
}

# 首次安装提示
TIMESTAMP=`date +%s`
DIRPATH=/data/adb/mark2_5000
if [ -d $DIRPATH ]; then
  DIRTIMESTAMP=`stat -c %Y $DIRPATH`
  TIMECHA=$(( $DIRTIMESTAMP - $TIMESTAMP + 300 ))
  if [ $TIMECHA -gt 0 ]; then
    warning
    ui_print "**  距上次安装不足300秒                **"
    ui_print "**  请再仔细考虑${TIMECHA}秒后再次安装         **"
    abort "***************************************"
  fi
else
  warning
  ui_print "**  因为本次为首次安装，即将退出         **"
  ui_print "**  请仔细考虑300秒后再次安装           **"
  mkdir $DIRPATH
  abort "***************************************"
fi

# 显示警告信息
warning

# 设置路径
MODBINPATH=$MODPATH/bin
MODDTBOPATH=$MODPATH/dtbo

# 添加运行权限
chmod +x $MODBINPATH/*

# 卸载用
cp -rf $MODBINPATH $MODDTBOPATH $DIRPATH

# 获取当前插槽
SLOT=$(getprop ro.boot.slot_suffix)

if [ "$SLOT" != "_a" ] && [ $SLOT != "_b" ]; then
  ui_print "**  未获取到正确插槽                   **"
  abort "***************************************"
else
  # 提取dtbo.img
  dd if=/dev/block/by-name/dtbo$SLOT of=$MODDTBOPATH/dtbo.img &> /dev/null
fi

if [ $? != 0 ]; then
  ui_print "**  未能提取到dtbo.img                **"
  abort "***************************************"
fi

# 提取dtbo.dtbo
$MODBINPATH/mkdtimg dump $MODDTBOPATH/dtbo.img -b $MODDTBOPATH/dtbo.dtbo -o /dev/null

# 获取机型信息
MODEL=$($MODBINPATH/fdtget $MODDTBOPATH/dtbo.dtbo.0 / model)

if [[ "$MODEL" =~ "PDX-203" ]]; then
  ui_print "**  当前机型为Xperia 1 II             **"
  $MODBINPATH/fdtoverlay -i $MODDTBOPATH/dtbo.dtbo.0 -o $MODDTBOPATH/new_dtbo.dtbo $MODDTBOPATH/overlay_pdx203.dtbo
  rm $MODPATH/system/product/overlay/FrameworkRes-PDX206-PowerProfile.apk
elif [[ "$MODEL" =~ "PDX-204" ]]; then
  ui_print "**  当前机型为Xperia Pro              **"
  $MODBINPATH/fdtoverlay -i $MODDTBOPATH/dtbo.dtbo.0 -o $MODDTBOPATH/new_dtbo.dtbo $MODDTBOPATH/overlay_pdx203.dtbo
  rm $MODPATH/system/product/overlay/FrameworkRes-PDX206-PowerProfile.apk
elif [[ "$MODEL" =~ "PDX-206" ]]; then
  ui_print "**  当前机型为Xperia 5 II             **"
  $MODBINPATH/fdtoverlay -i $MODDTBOPATH/dtbo.dtbo.0 -o $MODDTBOPATH/new_dtbo.dtbo $MODDTBOPATH/overlay_pdx206.dtbo
  rm $MODPATH/system/product/overlay/FrameworkRes-PDX203-PowerProfile.apk
else
  ui_print "**  不支持此机型                      **"
  abort "***************************************"
fi

# 生成new_dtbo.img
$MODBINPATH/mkdtimg create $MODDTBOPATH/new_dtbo.img --page_size=4096 $MODDTBOPATH/new_dtbo.dtbo &> /dev/null

# 刷入dtbo
dd if=$MODDTBOPATH/new_dtbo.img of=/dev/block/by-name/dtbo$SLOT &> /dev/null

if [ $? != 0 ]; then
  ui_print "**  未能刷入new_dtbo.img              **"
  abort "***************************************"
fi

ui_print "**  安装成功，请重启设备                **"
ui_print "***************************************"
