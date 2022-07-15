# 安装时创建
DIRPATH=/data/adb/mark2_5000 

# 设置路径
MODBINPATH=$DIRPATH/bin
MODDTBOPATH=$DIRPATH/dtbo

# 获取当前插槽
SLOT=$(getprop ro.boot.slot_suffix)

if [ "$SLOT" != "_a" ] && [ $SLOT != "_b" ]; then
  echo "未获取到正确插槽"
  exit 1
else
  # 提取dtbo.img
  dd if=/dev/block/by-name/dtbo$SLOT of=$MODDTBOPATH/dtbo.img &> /dev/null
fi

if [ $? != 0 ]; then
  echo "未能提取到dtbo.img"
  exit 1
fi

# 提取dtbo.dtbo
$MODBINPATH/mkdtimg dump $MODDTBOPATH/dtbo.img -b $MODDTBOPATH/dtbo.dtbo -o /dev/null

# 获取机型信息
MODEL=$($MODBINPATH/fdtget $MODDTBOPATH/dtbo.dtbo.0 / model)

if [ "$MODEL" == "Sony Mobile Communications. PDX-203(KONA)" ]; then
  echo "当前机型为Xperia 1 II"
  $MODBINPATH/fdtoverlay -i $MODDTBOPATH/dtbo.dtbo.0 -o $MODDTBOPATH/new_dtbo.dtbo $MODDTBOPATH/origin_pdx203.dtbo
elif [ "$MODEL" == "Sony Mobile Communications. PDX-206(KONA)" ]; then
  echo "当前机型为Xperia 5 II"
  $MODBINPATH/fdtoverlay -i $MODDTBOPATH/dtbo.dtbo.0 -o $MODDTBOPATH/new_dtbo.dtbo $MODDTBOPATH/origin_pdx206.dtbo
else
  echo "不支持此机型"
  exit 1
fi

# 生成new_dtbo.img
$MODBINPATH/mkdtimg create $MODDTBOPATH/new_dtbo.img --page_size=4096 $MODDTBOPATH/new_dtbo.dtbo &> /dev/null

# 刷入dtbo
dd if=$MODDTBOPATH/new_dtbo.img of=/dev/block/by-name/dtbo$SLOT &> /dev/null

if [ $? != 0 ]; then
  echo "未能还原dtbo.img"
  exit 1
fi

echo "bye"
# 清理残留
rm -rf $DIRPATH
