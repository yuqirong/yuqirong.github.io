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

通过Serializable来实现对象的序列化和反序列化(User类实现了Serializable接口)：

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

有两个需要注意一下：

* 静态成员变量属于类不属于对像，所以不会参与序列化过程；
* 用transient关键字标记的成员变量不参与序列化过程。

**Parcelable接口**

Serializable是Java中的序列化接口，其使用起来简单但是开销很大，序列化和反序列化过程需要大量I/O操作。而Parcelable是Android中的序列化方式，因此更适合在Android平台上，它的缺点就是使用起来稍微麻烦点，但是它的效率很高，因此推荐使用Parcelable。

**Binder**

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



