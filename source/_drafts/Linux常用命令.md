title: Linux常用命令
date: 2016-07-11 23:29:35
categories: Linux
tags: [Linux]
---
基础介绍
======

* 立即进行关机
	
	shotdown -h now

* 现在重新启动计算机

	shotdown -r now

* 现在重新启动计算机

	reboot

* 切换系统管理员账号

	su -

* 用户注销

	logout

* 打印当前目录的清单

	ls

* 打印当前目录的详细清单

	ls -l

* vi编辑器编写 Java 语言程序的过程
	1. vi Hello.java
	2. 按 i 键进入插入模式
	3. 编写代码
	4. 按 esc 键进入命令模式
	5. 按 wq 保存并退出，q! 退出但是不保存
	6. 编译 javac Hello.java
	7. 运行 java Hello

Linux目录结构：

root：存放root用户的相关文件
home：存放普通用户的相关文件
bin：存放常用命令的目录
sbin：要具有一定权限才可以使用的命令
mnt：默认挂载光驱和软驱的目录
boot：存放引导相关的文件
etc：存放配置相关的文件
var：存放一些经常变化的文件
usr：软件默认安装的目录

* 显示当前的路径： pwd
* 添加用户：useradd [用户名]
* 设置用户密码：passwd [用户名]
* 删除用户：userdel [用户名]
* 删除用户以及用户主目录：userdel -r [用户名]

命令：init
运行级别：
0 关机
1 单用户
2 多用户状态没有网络服务
3 多用户状态有网络服务
4 系统没有使用，留给用户
5 图形界面
6 重启
常用运行级别为3和5，要修改默认的运行级别可改文件/etc/inittab的id:5:initdefault:这一行中的数字

ls -a 显示隐藏文件
ls -al 显示隐藏文件并显示场列表形式
mkdir 建立目录
rmdir 删除空目录
touch 建立空文件
cp 复制命令
cp -r dir1 dir2 递归复制命令(复制子目录信息)
mv 移动文件和改文件名
rm 删除文件和目录
rm -rf * 删除所有内容
查找内容： grep -n [查找的内容] 查找的文件
find 查找文件或目录