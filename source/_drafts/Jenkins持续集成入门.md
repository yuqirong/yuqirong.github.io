title: Jenkins持续集成入门
date: 2018-04-17 23:23:47
categories: Android Blog
tags: [Android,Jenkins]
---
Jenkins 是一款非常流行的持续集成工具，可以帮助你完成构建、打包等工作，让开发更加纯粹地关注开发。可以说，现在大多数公司都已经在使用 Jenkins 了，发展趋于成熟稳定。

那么在这里，我就对 Jenkins 的使用作一个入门的介绍吧，同时也算作自己摸索 Jenkins 的记录。

Jenkins 安装
============
首先是安装 Jenkins ，我们可以访问 Jenkins 官网 https://jenkins.io/ 去下载。

![Jenkins Download](/uploads/20180417/20180417234539.png)

Windows 系统有直接的安装包，下载下来后点击安装。安装完成后就会打开 http://localhost:8080 进入 Jenkins 。

成功进入后会看到如下画面，按照提示路径打开密码文件，输入初始密码：

![Input Password](/uploads/20180417/20180417235233.jpg)

之后，就是安装 Jenkins 的插件了，我们选择“安装推荐的插件”。

![Install Plugin](/uploads/20180417/20180417235712.jpg)

![Install Plugin](/uploads/20180417/20180417235716.jpg)

在此期间，可能有些插件因为 qiang 的原因，下载失败。我们可以选择跳过，等到后面进入插件管理中重新去下载。

下载完成之后，Jenkins 会提示我们需要创建一个管理员账号，那么我们就听它的话吧。

![Create Admin User](/uploads/20180417/20180417235756.jpg)

创建完成后，就正式进入到了 Jenkins 的页面。

![Welcome](/uploads/20180417/20180418000815.png)
