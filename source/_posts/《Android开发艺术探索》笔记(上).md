title: 《Android开发艺术探索》笔记(上)
date: 2016-03-31 19:49:28
categories: Book Note
tags: [Android,《Android艺术开发探索》]
---
第一章：Activity的生命周期和启动模式
=======

1.1 Activity的生命周期全面分析
--------

**典型情况下的生命周期分析**

onStart()和onStop()是从Activity是否可见这个角度来回调的，而onResume()和onPause()是从Activity是否位于前台这个角度来回调的。

Activity A打开Activity B时，为了不影响B的显示，最好不要在Activity A的onPause()里执行一些耗时操作，可以考虑将这些操作放到onStop()里，这时B已经可见了。

**异常情况下的生命周期分析**

由于Activity是在异常情况下终止的，系统会调用onSaveInstanceState()来保存当前Activity的状态。这个方法的调用时机是在onStop()之前，但它和onPause()没有既定的时序关系，它既可能在onPause()之前调用，也可能在onPause()之后调用。需要强调的一点是，这个方法只会出现在Activity被异常终止的情况下，正常情况下系统不会调用onSaveInstanceState()这个方法。

当Activity被重新创建后，系统会调用onRestoreInstanceState()，并且把Activity销毁时onSaveInstanceState()方法所保存的Bundle对象作为参数同时传递给onRestoreInstanceState()和onCreate()方法。因此我们可以通过onRestoreInstanceState()和onCreate()方法来判断Activity是否重建了。如果被重建了，那么我们就可以取出之前保存的数据并恢复，从时序上来说，onRestoreInstanceState的调用时机在onStart()之后。

和Activity一样，每个View都有onSaveInstanceState()和onRestoreInstanceState()这两个方法。关于保存和恢复View层次结构，系统的工作流程是这样的：首先Activity会委托Window去保存数据，接着Window再委托它上面的顶级容器去保存数据。顶层容器是一个ViewGroup，一般来说它很可能是DecorWindow。最后顶层容器再去一一通知它的子元素来保存数据，这样整个数据保存过程就完成了。可以发现，这是一种典型的委托思想，上层委托下层、父层委托子元素去处理一件事情。至于数据恢复过程也是类似的，这里就不再重复介绍了。

Activity按照优先级从高到低，可以分为如下三种：

* 前台Activity——正在和用户交互的Activity，优先级最高。
* 可见但非前台Activity——比如Activity中弹出了一个对话框，导致Activity可见但是位于后台无法和用户直接交互。
* 后台Activity——已经被暂停的Activity，比如说执行了onStop，优先级最低。

如果不想Activity在屏幕旋转的时候重新创建，则：
	
	android:configChanges="orientation"

另外，若minSdkVersion和targetSdkVersion其中有一个低于13，则要在上面的基础上，加上screenSize，即：

	android:configChanges="orientation|screenSize"

1.2 Activity的启动模式
--------
**Activity的launchMode**

* standard 标准模式。每次启动会重新创建新的实例，谁启动了这个Activity，这个Activity就运行在启动仪它的那个Activity所在的栈里。另外要注意的是，当我们用ApplicationContext去启动standard模式的Activity的时候会报错，错误如下

		E/AndroidRuntime(674):andriod.util.AndroidRuntimeException: Calling startActivity from outside of an Activity context requires the FLAG_ACTIVITY_NEW_TASK flag.Is this really what you want?

	这是因为standard模式的Activity默认会进入启动它的Activity所属的任务栈中，但是由于非Activity类型的Context(如ApplicationContext)并没有所谓的任务栈，所以这就有问题了。解决这个问题的方法是为待启动Activity指定FLAG\_ACTIVITY\_NEW\_TASK标记位，这样启动的时候就会为它创建一个新的任务栈，这个时候待启动Activity实际上是以singleTask模式启动的。

* singleTop 栈顶复用模式。若该Activity已经位于任务栈的栈顶，那么该Activity不会被重新创建，同时它的onNewIntent()方法会被回调，通过此方法的参数我们可以取出当前请求的信息。而且它的onCreate()和onStart()并不会被调用。执行的是onPause() --> onNewIntent() --> onResume()。 如果该Activity已存在但不是位于栈顶，则该Activity仍然会被重新创建。

* singleTask 栈内复用模式。这是一种单实例模式，在这种模式下，只要Activity在一个栈中存在，那么多次启动此Activity都不会重新创建实例，和singleTop一样，系统也会回调其onNewsIntent()。具体一点，当一个具有singleTask模式的Activity请求启动后，比如说Activity A，系统首先会寻找是否存在A想要的任务栈，如果不存在，就重新创建一个任务栈，然后创建A的实例后把A放到栈中。如果存在把A所需的任务栈，这时要看A是否在栈中有实例存在，如果有实例存在，那么系统就会把A调到栈顶(会把在栈中所有处于A之上的Activity全部出栈)并调用它的onNewsIntent()方法，如果实例不存在，就创建A的实例并把A压入栈中。

	设ActivityA的 android:launchMode="singleTask" 方式，且ActivityA正处于栈中，但不是栈顶，栈顶为ActivityB，点击按钮启动ActivityA，则：
	B: onPause() -> A: onNewIntent() -> A:onRestart() -> A: onStart() -> A:onResume() -> B: onStop() -> B: onDestroy()

* singleInstance 单实例模式。这是一种加强的singleTask模式，它除了具有singleTask模式的所有特性外，还加强了一点，那就是具有此种模式的Activity只能单独地位于一个任务栈中。换句话说，比如Activity A是singleInstance模式，当A启动后，系统会为它创建一个新的任务栈，然后A独自在这个新的任务栈中，由于栈内复用的特性，后续的请求均不会创建新的Activity。除非这个独特的任务栈被系统销毁了。

`android:taskAffinity`：可以翻译为任务相关性。这个参数标识了一个Activity所需要的任务栈的名字，默认情况下，所有Activity所需的任务栈的名字为报名。当然，我们可以为每个Activity都单独制定TaskAffinity属性，这个属性必须不能和包名相同，否则就相当于没有指定。TaskAffinity属性主要和singleTask启动模式或者allowTaskReparenting属性配对使用，在其他情况下没有意义。另外，任务栈分为前台任务栈和后台任务栈，后台任务栈中的Activity位于暂停状态，用户可以通过切换将后台任务栈再次调到前台。

* 当TaskAffinity和singleTask启动模式配对使用的时候，它是具有该模式的Activity的目前任务栈的名字，待启动的Activity会运行在名字和TaskAffinity相同的任务栈中。

* 当TaskAffinity和allowTaskReparenting结合的时候，这种情况比较复杂，会产生特殊的效果。当一个应用A启动了应用B的某个Activity后，如果这个Activity的allowTaskReparenting属性为true的话，那么当应用B被启动后，此Activity会直接从应用A的任务栈转移到应用B的任务栈中。

**Activity的Flags**

* Intent.FLAG\_ACTIVITY\_NEW\_TASK：为Activity指定“singleTask”启动模式，其效果和在XML中指定该启动模式相同。

* Intent.FLAG\_ACTIVITY\_SINGLE\_TOP：使用singleTop模式来启动一个Activity，与指定android:launchMode="singleTop"效果相同。

* Intent.FLAG\_ACTIVITY\_CLEAR\_TOP：具有此标记位的Activity，当它启动时，在同一个任务栈中所有位于它上面的Activity都要出栈。这个模式一般需要和FLAG\_ACTIVITY\_NEW\_TASK配合使用。

* Intent.FLAG_ACTIVITY\_EXCLUDE\_FROM\_RECENTS：具有这个标记的Activity不会出现在历史Activity的列表中，当某些情况下我们不希望用户通过历史列表回到我们的Activity的时候这个标记比较有用。它等同于在XML中指定Activity的属性`android:excludeFromRecents="true"`。

1.3 IntentFilter的匹配规则
--------
* action匹配规则：要求intent中的action 存在 且 必须和过滤规则中的其中一个相同 区分大小写；
* category匹配规则：系统会默认加上一个android.intent.category.DEAFAULT，所以intent中可以不存在category，但如果存在就必须匹配其中一个；
* data匹配规则：data由两部分组成，mimeType和URI，要求和action相似。如果没有指定URI，URI但默认值为content和file（schema）。如果要为intent指定完整的data，必须要调用setDataAndType方法。

第二章：IPC机制
=======

2.1 Android IPC简介
--------

2.2 Android中的多进程模式
--------
**开启多进程模式**

在Android中使用多进程只有一个办法，那就是给四大组件(Activity、Service、Receiver、ContentProvider)在AndroidMenifest中指定android:process属性。另外还有一种非常规的多进程方法，那就是通过JNI在native层去fork一个新的进程。

进程名以“:”开头的进程属于当前应用的私有进程，其他应用的组件不可以和它跑在同一个进程中，而进程名不以“:”开头的进程属于全局过程，其他应用可以通过ShareUID方式和它跑在同一个进程中。

我们知道Android系统会为每个应用分配一个唯一的UID，具有相同UID的应用才能共享数据。这里要说明的是，两个应用通过ShareUID跑在同一个进程中是有要求的，需要这两个应用有相同的ShareUID并且签名相同才可以。在这种情况下，它们可以互相访问对方的私有数据，比如data目录、组件信息等，不管它们是否跑在同一个进程中。当然如果它们跑在同一个进程中，那么除了能共享data目录、组件信息，还可以共享内存数据，或者说他们看起来就像是一个应用的两个部分。

**多进程模式的运行机制**

Android会为每一个应用分配一个独立的虚拟机，或者说为每个进程都分配一个独立的虚拟机，不同的虚拟机在内存分配上有不同的地址空间，这就导致在不同的虚拟机中访问同一个类的对象会产生多份副本。

一般来说，使用多进程会造成如下几方面的问题：

1. 静态成员和单例模式完全失效；
2. 线程同步机制完全失效；
3. SharedPreferences的可靠性下降；
4. Application会多次创建。

2.3 IPC基础概念介绍
--------

**Serializable接口**

Serializable接口是Java中为对象提供标准的序列化和反序列化操作的接口，通过Serializable来实现对象的序列化和反序列化(User类实现了Serializable接口)：

``` java
	// 序列化过程
	User user = new User(0,"jake",true);
	ObjectOutputStream out = new ObjectOutputStream(new FileOutputStream("cache.txt"));
	out.writeObject(user);
	out.close();

	// 反序列化过程
	ObjectInputStream in = new ObjectInputStream(new FileInputStream("cache.txt"))；
	User newUser = (User)in.readObject();
	in.close();
```

恢复的对象newUser和user的内容完全一样，但是两者并不是同一个对象。

原则上序列化后的数据中的serialVerionUID只有和当前类的serialVersionUID相同才能够正常地被反序列化。

serialVersionUID的详细工作机制：序列化的时候系统会把当前类的serialVersionUID写入序列化的文件中，当反序列化的时候系统会去检测文件中的serialVersionUID，看它是否和当前类的serialVersionUID一致，如果一致就说明序列化的类的版本和当前类的版本是相同的，这个时候可以成功反序列化；否则说明版本不一致无法正常反序列化。一般来说，我们应该手动指定serialVersionUID的值。

有两个需要注意一下：

* 静态成员变量属于类不属于对像，所以不会参与序列化过程；
* 用transient关键字标记的成员变量不参与序列化过程。

**Parcelable接口**

Serializable是Java中的序列化接口，其使用起来简单但是开销很大，序列化和反序列化过程需要大量I/O操作。而Parcelable是Android中的序列化方式，因此更适合在Android平台上，它的缺点就是使用起来稍微麻烦点，但是它的效率很高，因此推荐使用Parcelable。Parcelable接口可以在Binder中自由传输，Parcelable主要用在内存序列化上，可以直接序列化的有Intent、Bundle、Bitmap以及List和Map等等，下面是一个实现了Parcelable接口的示例：

``` java
public class Book implements Parcelable {
    public int bookId;
    public String bookName;
    public Book() {
    }

    public Book(int bookId, String bookName) {
        this.bookId = bookId;
        this.bookName = bookName;
    }

    //“内容描述”，如果含有文件描述符返回1，否则返回0，几乎所有情况下都是返回0
    public int describeContents() {
        return 0;
    }

    //实现序列化操作，flags标识只有0和1，1表示标识当前对象需要作为返回值返回，不能立即释放资源，几乎所有情况都为0
    public void writeToParcel(Parcel out, int flags) {
        out.writeInt(bookId);
        out.writeString(bookName);
    }

    //实现反序列化操作
    public static final Parcelable.Creator<Book> CREATOR = new Parcelable.Creator<Book>() {
        //从序列化后的对象中创建原始对象
        public Book createFromParcel(Parcel in) {
            return new Book(in);
        }
        public Book[] newArray(int size) {//创建指定长度的原始对象数组
            return new Book[size];
        }
    };

    private Book(Parcel in) {
        bookId = in.readInt();
        bookName = in.readString();
    }

}
```

**Binder**

Binder是Android的一个类，它继承了IBinder接口。从IPC的角度来说，Binder是Android中的一种跨进程通信方式，Binder还可以理解为一种虚拟的物理设备，它的设备驱动是/dev/binder，该通信方式在Linux中没有；从Android Framework角度来说，Binder是ServiceManager连接各种Manager(ActivityManager、WindowManager等等)和相应ManagerService的桥梁；从Android应用层来说，Binder是客户端和服务端进行通信的媒介，当bindService的时候，服务端会返回一个包含了服务端业务调用的Binder对象，通过这个Binder对象，客户端就可以获取服务端提供的服务或者数据，这里的服务包含普通服务和基于AIDL的服务。

在Android开发中，Binder主要用在Service中，包括AIDL和Messenger，其中普通Service中的Binder不涉及进程间通信，较为简单；而Messenger的底层其实是AIDL，正是Binder的核心工作机制。

AIDL工具根据AIDL文件自动生成的Java接口的解析：首先，它声明了几个接口方法，同时还声明了几个整型的id用于标识这些方法，id用于标识在transact过程中客户端所请求的到底是哪个方法；接着，它声明了一个内部类Stub，这个Stub就是一个Binder类，当客户端和服务端都位于同一个进程时，方法调用不会走跨进程的transact过程，而当两者位于不同进程时，方法调用需要走transact过程，这个逻辑由Stub内部的代理类Proxy来完成。

AIDL接口的核心就是它的内部类Stub和Stub内部的代理类Proxy。 下面分析其中的方法：

* `DESCRIPTOR`:Binder的唯一标识，一般用当前Binder的类名表示，比如“com.example.android.MyAIDLInterface”。
* `asInterface(android.os.IBinder obj)`：用于将服务端的Binder对象转换成客户端所需的AIDL接口类型的对象，这种转换过程是区分进程的，如果客户端和服务端是在同一个进程中，那么这个方法返回的是服务端的Stub对象本身，否则返回的是系统封装的Stub.Proxy对象。
* `asBinder()`：返回当前Binder对象。
* `onTransact(int code, android.os.Parcel data, android.os.Parcel reply, int flags)`：这个方法运行在服务端中的Binder线程池中，当客户端发起跨进程请求时，远程请求会通过系统底层封装后交由此方法来处理。这个方法的原型是`public Boolean onTransact(int code, Parcelable data, Parcelable reply, int flags)`服务端通过code可以知道客户端请求的目标方法，接着从data中取出所需的参数，然后执行目标方法，执行完毕之后，将结果写入到reply中。如果此方法返回false，说明客户端的请求失败，利用这个特性可以做权限验证(即验证是否有权限调用该服务)。
* `Proxy#[Method]`：代理类中的接口方法，这些方法运行在客户端，当客户端远程调用此方法时，它的内部实现是：首先创建该方法所需要的参数，然后把方法的参数信息写入到_data中，接着调用transact方法来发起RPC请求，同时当前线程挂起；然后服务端的onTransact方法会被调用，直到RPC过程返回后，当前线程继续执行，并从_reply中取出RPC过程的返回结果，最后返回_reply中的数据。

Binder的工作机制原理图：

![Binder的工作机制原理图](/uploads/20160809/20160814201234.png)

Binder的两个重要方法linkToDeath和unlinkToDeath：
Binder运行在服务端，如果由于某种原因服务端异常终止了的话会导致客户端的远程调用失败，所以Binder提供了两个配对的方法linkToDeath和unlinkToDeath，通过linkToDeath方法可以给Binder设置一个死亡代理，当Binder死亡的时候客户端就会收到通知，然后就可以重新发起连接请求从而恢复连接了。
如何给Binder设置死亡代理呢？

(一). 声明一个DeathRecipient对象，DeathRecipient是一个接口，其内部只有一个方法bindeDied，实现这个方法就可以在Binder死亡的时候收到通知了。

``` java
private IBinder.DeathRecipient mDeathRecipient = new IBinder.DeathRecipient() {
    @Override
    public void binderDied() {
        if (mRemoteBookManager == null) return;
        mRemoteBookManager.asBinder().unlinkToDeath(mDeathRecipient, 0);
        mRemoteBookManager = null;
        // TODO:这里重新绑定远程Service
    }
};
```

(二). 在客户端绑定远程服务成功之后，给binder设置死亡代理：

``` java
mRemoteBookManager.asBinder().linkToDeath(mDeathRecipient, 0);
```

2.4 IPC方式
----------

1. 使用Bundle：Bundle实现了Parcelable接口，Activity、Service和Receiver都支持在Intent中传递Bundle数据。

2. 使用文件共享：这种方式简单，适合在对数据同步要求不高的进程之间进行通信，并且要妥善处理并发读写的问题。
	
	SharedPreferences是一个特例，虽然它也是文件的一种，但是由于系统对它的读写有一定的缓存策略，即在内存中会有一份SharedPreferences文件的缓存，因此在多进程模式下，系统对它的读写就变得不可靠，当面对高并发读写访问的时候，有很大几率会丢失数据，因此，不建议在进程间通信中使用SharedPreferences。

3. 使用Messenger：Messenger是一种轻量级的IPC方案，它的底层实现就是AIDL。Messenger是以串行的方式处理请求的，即服务端只能一个个处理，不存在并发执行的情形。

	Messenger的工作原理：

	![Messenger的工作原理图](/uploads/20160809/20160809234757.png)

4. 使用AIDL:首先建一个Service和一个AIDL接口，接着创建一个类继承自AIDL接口中的Stub类并实现Stub类中的抽象方法，在Service的onBind方法中返回这个类的对象，然后客户端就可以绑定服务端Service，建立连接后就可以访问远程服务端的方法了。

	AIDL使用的注意点：

	(1). AIDL支持的数据类型：基本数据类型、String和CharSequence、ArrayList、HashMap、Parcelable以及AIDL；
	(2). 某些类即使和AIDL文件在同一个包中也要显式import进来；
	(3). AIDL中除了基本数据类，其他类型的参数都要标上方向：in、out或者inout；
	(4). AIDL接口中支持方法，不支持声明静态变量；
	(5). 为了方便AIDL的开发，建议把所有和AIDL相关的类和文件全部放入同一个包中，这样做的好处是，当客户端是另一个应用的时候，可以直接把整个包复制到客户端工程中。
	(6). AIDL方法是在服务端的Binder线程池中执行的，因此当多个客户端同时连接的时候，会存在多个线程同时访问的情形，所以要在AIDL方法中处理线程同步。
	(7). RemoteCallbackList是系统专门提供的用于删除跨进程Listener的接口。RemoteCallbackList是一个泛型，支持管理任意的AIDL接口，因为所有的AIDL接口都继承自IInterface接口。
	(8). 客户端调用远程服务方法时，因为远程方法运行在服务端的binder线程池中，同时客户端线程会被挂起，所以如果该方法过于耗时，而客户端又是UI线程，会导致ANR，所以当确认该远程方法是耗时操作时，应避免客户端在UI线程中调用该方法。同理，当服务器调用客户端的listener方法时，该方法也运行在客户端的binder线程池中，所以如果该方法也是耗时操作，请确认运行在服务端的非UI线程中。另外，因为客户端的回调listener运行在binder线程池中，所以更新UI需要用到handler。
	(9). 客户端通过IBinder.DeathRecipient来监听Binder死亡，也可以在onServiceDisconnected中监听并重连服务端。区别在于前者是在binder线程池中，访问UI需要用Handler，后者则是UI线程。
	(10). AIDL可通过自定义权限在onBind或者onTransact中进行权限验证。

5. 使用ContentProvider
1.ContentProvider主要以表格的形式来组织数据，并且可以包含多个表；
2.ContentProvider还支持文件数据，比如图片、视频等，系统提供的MediaStore就是文件类型的ContentProvider；
3.ContentProvider对底层的数据存储方式没有任何要求，可以是SQLite、文件，甚至是内存中的一个对象都行；
4.要观察ContentProvider中的数据变化情况，可以通过ContentResolver的registerContentObserver方法来注册观察者；

6. 使用Socket
Socket是网络通信中“套接字”的概念，分为流式套接字和用户数据包套接字两种，分别对应网络的传输控制层的TCP和UDP协议。

2.5 Binder连接池
--------
(1). 当项目规模很大的时候，创建很多个Service是不对的做法，因为service是系统资源，太多的service会使得应用看起来很重，所以最好是将所有的AIDL放在同一个Service中去管理。整个工作机制是：每个业务模块创建自己的AIDL接口并实现此接口，这个时候不同业务模块之间是不能有耦合的，所有实现细节我们要单独开来，然后向服务端提供自己的唯一标识和其对应的Binder对象；对于服务端来说，只需要一个Service，服务端提供一个queryBinder接口，这个接口能够根据业务模块的特征来返回相应的Binder对象给它们，不同的业务模块拿到所需的Binder对象后就可以进行远程方法调用了。
Binder连接池的主要作用就是将每个业务模块的Binder请求统一转发到远程Service去执行，从而避免了重复创建Service的过程。

(2). 作者实现的Binder连接池BinderPool的[实现源码](https://github.com/singwhatiwanna/android-art-res/blob/master/Chapter_2/src/com/ryg/chapter_2/binderpool/BinderPool.java)，建议在AIDL开发工作中引入BinderPool机制。

2.6 选用合适的IPC方式
---------

![选用合适的IPC方式](/uploads/20160809/20160814191325.png)

// TODO

第三章：View的事件体系
=======

3.1 View基础知识
--------
**View的位置参数**

* View的宽高和坐标关系：width = right - left，height = top - bottom。
* View在平移过程中，top和left表示的是原始左上角的位置信息，其值不会改变，发生改变的是x、y、translationX、translationY这四个参数。x是View左上角的坐标，translation是view移动后相对于父容器的偏移量，所以有x = left + translationX。y的原理相同。

**MotionEvent和TouchSlop**

TouchSlop是系统所能识别出的被认为是滑动的最小距离。这是一个常量，和设备有关，在不同设备上这个值可能是不同的，通过如下方式即可获取这个常量：`ViewConfiguration.get(getContext()).getScaledTouchSlop()`。当两次滑动事件的滑动距离小于TouchSlop时就可以认为不是滑动。

**VelocityTracker、GestureDetector和Scroller**

1.VelocityTracker

速度追踪。用于追踪手指在滑动过程中的速度，包括水平和竖直方向的速度。首先，在View的onTouchEvent方法中追踪当前单击事件的速度。

	VelocityTracker velocityTracker = VelocityTracker.obtain();
	velocityTracker.addMovement(event);

获取当前的速度：

	velocityTracker.computeCurrentVelocity(1000); //表示的是一个时间单元或者说时间间隔
	int xVelocity = (int) velocityTracker.getXVelocity();
	int yVelocity = (int) velocityTracker.getYVelocity();

当不用它的时候，需要调用clear()方法来重置并回收内存：

	velocityTracker.clear();
	velocityTracker.recycle();

2.GestureDetector

手势检测，用于辅助检测用户的单击、滑动、长按、双击等行动。

首先，需要创建一个GestureDetector对象并实现OnGestureListener接口，根据需要我们还可以实现OnDoubleTapListener从而能够监听双击行为：

	GestureDetector mGestureDetector = new GestureDetector(this);
	// 解决长按屏幕后无法拖动的现象
	mGestureDetector.setIsLongpressEnabled(false)；

接着，接管目标View的onTouchEvent方法，在待监听View的onTouchEvent方法中添加如下实现：

	boolean consume = mGestureDetector.onTouchEvent(event);
	return consume;

做完了上面两步，我们就可以有选择地实现OnGestureListener和OnDoubleTapListener中的方法了。

3.Scroller

在3.2节中详细介绍。

3.2 View的滑动
--------
* 使用scrollTo/scrollBy：操作简单，适合对View内容的滑动

* 使用动画：操作简单，主要适用于没有交互的View和实现复杂的动画效果

* 改变布局参数：操作稍微复杂，使用于有交互的View

3.3 弹性滑动
---------
* 使用Scroller

* 通过动画

* 使用Handler延时策略

3.4 View的事件分发机制
--------
当一个点击事件产生后，它的传递过程遵循如下顺序：Activity->Window->View。即事件总是先传递给Activity，Activity再传递给Window，最后Window再传递给顶级View。顶级View接收到事件后，就会按照事件分发机制去分发事件。

主要过程：Activity的dispatchTouchEvent-->Window的superDispatchTouchEvent(Window实际上是一个抽象类，而它的实现类为PhoneWindow)-->DecorView的superDispatchTouchEvent(DecorView是继承自FrameLayout，是Activity的根View)-->分发到子View中(即分发到contentView中)。

注意点：

* 如果一个View的onTouchEvent返回false，那么它的父容器的onTouchEvent将会被调用，依此类推。如果所有的元素都不处理这个事件，那么这个事件将会最终传递给Activity处理，即Activity的onTouchEvent方法会被调用。

* 某个view一旦开始处理事件，如果它不消耗ACTION\_DOWN事件，那么同一事件序列的其他事件都不会再交给它来处理，并且事件将重新交给它的父容器去处理(调用父容器的onTouchEvent方法)；如果它消耗ACTION\_DOWN事件，但是不消耗其他类型事件，那么这个点击事件会消失，父容器的onTouchEvent方法不会被调用，当前view依然可以收到后续的事件，但是这些事件最后都会传递给Activity处理。

* View的enable属性不影响onTouchEvent的默认返回值。哪怕一个view是disable状态，只要它的clickable或者longClickable有一个是true，那么它的onTouchEvent就会返回true。

* 通过requestDisallowInterceptTouchEvent方法可以在子元素中干预父元素的事件分发过程，但是ACTION_DOWN事件除外。

* ViewGroup的dispatchTouchEvent方法中有一个标志位FLAG\_DISALLOW\_INTERCEPT，这个标志位就是通过子view调用requestDisallowInterceptTouchEvent方法来设置的，一旦设置为true，那么ViewGroup不会拦截该事件。

3.5 View的滑动冲突
--------
**常见的滑动冲突场景**

常见的滑动冲突场景可以简单分为如下三种：

* 场景1——外部滑动方向和内部滑动方向不一致
* 场景2——外部滑动方向和内部滑动方向一致
* 场景3——上面两种情况的嵌套

**滑动冲突处理规则**

可以根据滑动距离和水平方向形成的夹角；或者根绝水平和竖直方向滑动的距离差；或者两个方向上的速度差等

**滑动冲突的解决方式**

外部拦截法：点击事件都先经过父容器的拦截处理，如果父容器需要此事件就拦截，如果不需要就不拦截。该方法需要重写父容器的onInterceptTouchEvent方法，在内部做相应的拦截即可，其他均不需要做修改。

伪代码如下：

	public boolean onInterceptTouchEvent(MotionEvent event) {
	    boolean intercepted = false;
	    int x = (int) event.getX();
	    int y = (int) event.getY();
	
	    switch (event.getAction()) {
	    case MotionEvent.ACTION_DOWN: {
	        intercepted = false;
	        break;
	    }
	    case MotionEvent.ACTION_MOVE: {
	        int deltaX = x - mLastXIntercept;
	        int deltaY = y - mLastYIntercept;
	        if (父容器需要拦截当前点击事件的条件，例如：Math.abs(deltaX) > Math.abs(deltaY)) {
	            intercepted = true;
	        } else {
	            intercepted = false;
	        }
	        break;
	    }
	    case MotionEvent.ACTION_UP: {
	        intercepted = false;
	        break;
	    }
	    default:
	        break;
	    }
	
	    mLastXIntercept = x;
	    mLastYIntercept = y;
	
	    return intercepted;
	}


内部拦截法：父容器不拦截任何事件，所有的事件都传递给子元素，如果子元素需要此事件就直接消耗掉，否则就交给父容器来处理。这种方法和Android中的事件分发机制不一致，需要配合requestDisallowInterceptTouchEvent方法才能正常工作。

伪代码如下：

子元素：

	public boolean dispatchTouchEvent(MotionEvent event) {
	    int x = (int) event.getX();
	    int y = (int) event.getY();
	
	    switch (event.getAction()) {
	    case MotionEvent.ACTION_DOWN: {
	        getParent().requestDisallowInterceptTouchEvent(true);
	        break;
	    }
	    case MotionEvent.ACTION_MOVE: {
	        int deltaX = x - mLastX;
	        int deltaY = y - mLastY;
	        if (当前view需要拦截当前点击事件的条件，例如：Math.abs(deltaX) > Math.abs(deltaY)) {
	            getParent().requestDisallowInterceptTouchEvent(false);
	        }
	        break;
	    }
	    case MotionEvent.ACTION_UP: {
	        break;
	    }
	    default:
	        break;
	    }
	
	    mLastX = x;
	    mLastY = y;
	    return super.dispatchTouchEvent(event);
	}

父元素：

	@Override
    public boolean onInterceptTouchEvent(MotionEvent event) {
        int action = event.getAction();
        if(action == MotionEvent.ACTION_DOWN){
			return false;
		}else{
			return true;
		}
    }

第四章：View的工作原理
=======

4.1 初识ViewRoot和DecorView
--------
ViewRoot对应于ViewRootImpl类，它是连接WindowManager和DecorView的纽带，View的三大流程均是通过ViewRoot来完成。在ActivityThread中，当Activity对象被创建完毕后，会将DecorView添加到Window中，同时会创建ViewRootImpl对象，并将ViewRootImpl对象和DecorView建立关联，这个过程可参看如下源码：

	root = new ViewRootImpl(view.getContext(), display);
	root.setView(view, wparams, panelParentView);




第七章：Android动画深入分析
=======
7.1 View动画
-----------------
(1)Android动画可分为三大类：view动画、帧动画和属性动画，属性动画是API 11(Android 3.0)的新特性，帧动画一般也认为是view动画。
(2)AnimationSet的属性android:shareInterpolator表示集合中的动画是否共享同一个插值器，如果集合不指定插值器，那么子动画需要单独指定所需的插值器或者使用默认值。
(3)自定义动画需要继承Animation抽象类，并重新它的initialize和applyTransformation方法，在initialize方法中做一些初始化工作，在applyTransformation方法中进行相应的矩阵变换，很多时候需要采用Camera类来简化矩阵变换的过程。
(4)帧动画使用比较简单，但是容易引起OOM，所以在使用的时候应尽量避免使用过多尺寸较大的图片。

7.2 View动画的特殊使用场景
--------

**Activity的切换效果**

`overridePendingTransition(int enterAnim, int exitAnim)`这个方法必须在`startActivity(Intent)`或者`finish()`之后被调用才能生效。

Fragment也可以添加切换动画，可以通过FragmentTransaction中的setCustomAnimations()方法来添加切换动画，这个切换动画需要是View动画。

7.3 属性动画
--------
**使用属性动画**

动画默认时间间隔为300ms，默认帧率为10ms/帧。

nineoldandroids对属性动画做了兼容，在API 11以前的版本其内部是通过代理View动画来实现的，因此在Android低版本上，他的本质还是View动画，尽管使用方法看起来是属性动画。

**对任意属性做动画**

属性动画的原理：属性动画要求动画作用的对象提供该属性的get和set方法，属性动画根据外界传递的该属性的初始值和最终值，以动画的效果多次去调用set方法，每次传递给set方法的值都不一样，确切来说是随着时间的推移，所传递的值越来越接近最终值。总结一下，我们对object的属性abc做动画，如果想让动画生效，要同时满足两个条件：

(1). object必须提供setAbc方法，如果动画的时候没有传递初始值，那么还要提供getAbc方法，因为系统要去取abc属性的初始值(如果这条不满足，程序直接Crash)

(2). object的setAbc对属性abc所做的改变必须能够通过某种方法反映出来，比如会带来UI的改变之类(如果这条不满足，动画无效果但不会Crash)

如果有时动画不生效的原因只满足条件1而未满足条件2，官方文档上告诉我们有3种解决方法：

* 给你的对象加上get和set方法，如果你有权限的话；
* 用一个类来包装原始对象，间接为其提供get和set方法；
* 采用ValueAnimator，监听动画过程，自己实现属性的改变。

**属性动画的工作原理**



7.4 使用动画的注意事项
--------
* OOM：尽量避免使用帧动画，使用的话应尽量避免使用过多尺寸较大的图片；
* 内存泄露：属性动画中的无限循环动画需要在Activity退出的时候及时停止，否则将导致Activity无法释放而造成内存泄露。view动画不存在这个问题；
* 兼容性问题：某些动画在3.0以下系统上有兼容性问题；
* view动画的问题：view动画是对view的影像做动画，并不是真正的改变view的状态，因此有时候动画完成之后view无法隐藏，即setVisibility(View.GONE)失效了，此时需要调用view.clearAnimation()清除view动画才行。
* 不要使用px；
* 动画元素的交互：在android3.0以前的系统上，view动画和属性动画，新位置均无法触发点击事件，同时，老位置仍然可以触发单击事件。从3.0开始，属性动画的单击事件触发位置为移动后的位置，view动画仍然在原位置；
* 硬件加速：使用动画的过程中，建议开启硬件加速，这样会提高动画的流畅性。