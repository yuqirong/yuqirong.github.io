四大组件
=======
Activity
-----
* Activity的生命周期
* Activity的Launch Mode
* Activity工作的原理
* 打开一个 Activity 的过程
* 统计 App 启动时长和如何优化冷启动时间
* Activity 栈的应用场景
* 下拉状态栏是不是影响 Activity 的生命周期

Service
------
* bindService()和startService()的区别
* 在Service可以执行耗时操作吗?
* IntentService和ForgroundService
* 保持App不被杀死
* 怎么启动service，service和activity怎么进行数据交互

BroadCast Receiver
-------
* 静态广播和动态广播的区别
* 本地广播
* 粘性广播

Content Provider
------------
* ContentResolver的使用
* 继承ContentProvider
* Android系统为什么会设计ContentProvider，进程共享和线程安全问题

Fragment
=====
* Fragment的生命周期
* FragmentManager的原理
* FragmentPagerAdapter与FragmentStatePagerAdapter的区别

View
=======
* 自定义View
* 自定义ViewGroup
* View的滑动
* View的事件分发机制
* View的绘制流程
* ListView的原理
* WebView实现和JS交互
* SurfaceView和View的区别
* 封装view的时候怎么知道view的大小
* 计算一个view的嵌套层级
* listview图片加载错乱的原理和解决方案，listview是如何做缓存的？

动画
=======
* 逐帧动画、视图动画、属性动画
* 视图动画的原理
* 属性动画的原理

Handler
=======
* Handler、Looper、MessageQueue之间的关系
* Looper中的ThreadLocal
* HandlerThread
* AsyncTask原理
* handler发消息给子线程，looper怎么启动

图片加载
=====
* 三级缓存(LruCache、DiskLruCache)
* 主流图片加载框架解析
* 如何设计一个图片加载框架
* 图片加载库相关，bitmap如何处理大图，如一张30M的大图，如何预防OOM

Android安全
=====
* 反编译：apktool、dex2jar和jd-gui
* 代码混淆和加壳

性能优化
=====

Android架构
====
* MVC
* MVP
* MVVM

JNI开发
=====
* JNI开发流程

IPC
----
* 进程有哪些通信方式
* 

其他
====
* 插件化
* 动态加载
* 65k限制
* Serializable和Parcelable
* 文件和数据库哪个效率高
* 断点续传
* Android中asset文件夹和raw文件夹区别
* JVM 和Dalvik虚拟机的区别
* 多线程断点续传原理
* 动态权限适配方案，权限组的概念
* App 是如何沙箱化，为什么要这么做
