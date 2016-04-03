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

* singleTop 栈顶复用模式。若该Activity已经位于任务栈的栈顶，那么该Activity不会被重新创建，同时它的onNewIntent()方法会被回调，通过此方法的参数我们可以取出当前请求的信息。而且它的onCreate()和onStart()并不会被调用。执行的是onNewIntent()-->onResume()。 如果该Activity已存在但不是位于栈顶，则该Activity仍然会被重新创建。

* singleTask 栈内复用模式。这是一种单实例模式，在这种模式下，只要Activity在一个栈中存在，那么多次启动此Activity都不会重新创建实例，和singleTop一样，系统也会回调其onNewsIntent()。具体一点，当一个具有singleTask模式的Activity请求启动后，比如说Activity A，系统首先会寻找是否存在A想要的任务栈，如果不存在，就重新创建一个任务栈，然后创建A的实例后把A放到栈中。如果存在把A所需的任务栈，这时要看A是否在栈中有实例存在，如果有实例存在，那么系统就会把A调到栈顶(会把在栈中所有处于A之上的Activity全部出栈)并调用它的onNewsIntent()方法，如果实例不存在，就创建A的实例并把A压入栈中。

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

1.1 Android IPC简介
--------
