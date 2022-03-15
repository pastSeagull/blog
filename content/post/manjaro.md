---
title: manjaro 的一些配置
date: 2020-12-20 11:04:32
tags:
---

为啥又把系统换成回了manjaro了呢，起因是因为win10的system占用我的CPU，然后安全中心一直在扫描病毒占用内存。几年前的垃圾电脑已经无法正常的使用了，打个饥荒都卡成那样了，拖个海妖让我回档了两次？
<!--more-->

# manjaro
然后manjaro配置基本烂大街了，我这就算是记录一下我个人出现的问题,和一些配置啥的。
先说一下电脑，SSD + HDD，然后系统安装在SSD，不是双系统

首先win10制作启动盘安装换源啥的就不说了
换源跟新好了之后开始安装应用报了个错误

`/usr/lib/chromium/chromium: /usr/lib/libc.so.6: version `GLIBC_2.32' not found (required by /usr/lib/chromium/chromium) `

然后论坛找到了解决的方法
```s
$:  pacman -F libc.so.6

core/glibc 2.32-5 [已安装]
    usr/lib/libc.so.6
core/lib32-glibc 2.32-5 [已安装]
    usr/lib32/libc.so.6
community/aarch64-linux-gnu-glibc 2.32-1
    usr/aarch64-linux-gnu/lib/libc.so.6
community/riscv64-linux-gnu-glibc 2.32-1 (risc-v)
    usr/riscv64-linux-gnu/lib/libc.so.6
archlinuxcn/arm-linux-gnueabihf-glibc 2.31-1
    usr/arm-linux-gnueabihf/lib/libc.so.6

$:  pamac upgrade
// 然后开始跟新，我不知道是不是我第一次更新炸了还是啥

然后又报了个签名错误
修改 /etc/pacman.config

再次更新，又报了个文件已经安装？？？
然后  su root   rm  直接删除

最后更新，一切正常。

```

因为我是双硬盘，然后其他硬盘开机没有挂载进去
```s
sudo fdisk -l  // 查看硬盘信息看它的数据类型，有需求的话可以直接查一下修改类型，或安装新硬盘上去挂载目录

df -h // 查看硬盘挂载分区信息

ls -al /dev/disk/by-uuid    // 查询UUID

修改 /etc/fstab 文件

<file system>	<dir>	<type>	<options>	<dump>	<pass>


```

好了基本出现的问题就这样了，代理用的是Qv2ray，开始安装软件和环境了。


# node
```s
sudo pacman -S nodejs npm

// 修改npm全局安装包

// 查看全局安装包在哪里
npm root -g

npm config set prefix ''

// 修改 cache
npm config set cache ''

// 查看一下位置对不对
npm config ls

// yarn 

yarn config  set global-folder ""

yarn config set cache-folder ""

yarn global dir

export PATH=$PATH:/run/media/gaviota/F/node/npm/global/bin/

```

