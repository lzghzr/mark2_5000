# mark2_5000
Xperia II系列更换四代电池后扩容模块
<br />
## 本模块并不会让电池更耐用，不要因此冒险刷本模块
<br />
<br />

四代电池数据来自 [sonyxperiadev/kernel](https://github.com/sonyxperiadev/kernel/tree/aosp/LA.UM.9.14.r1/arch/arm64/boot/dts/somc)
<br />

仅适配 Xperia 四代电池，并且根据四代电池数据修改了
1. 最高充电电压
2. 最高充电电流
3. 电池保护电压
4. 阶梯充电电压
5. 充电截止电流
<br />

如果你更换其他第三方电池，请勿直接使用本模块<br />
向电池供应商索要电池数据并自行修改以上数据
<br />

本项目提供的自动打包脚本，需要使用Linux并且安装zip，修改数据后运行 `./build.sh` 即可