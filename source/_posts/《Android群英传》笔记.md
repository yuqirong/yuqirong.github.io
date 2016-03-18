title: 《Android群英传》笔记
date: 2016-03-08 20:22:27
categories: Book Note
tags: [Android,《Android群英传》]
---
第六章：Android绘图机制与处理技巧
=======
6.4 Android绘图技巧
--------
* Canvas.save():保存画布。它的作用就是将之前的所有已绘制图像保存起来，让后续的操作就好像在一个新的图层上操作一样。

* Canvas.restore():合并图层操作。它的作用就是将我们在save()之后绘制的所有图像与save()之前的图像进行合并。

* Canvas.translate():画布平移，可理解为坐标系的平移。如在之前绘制的坐标系原点在(0,0)。在translate(x,y)之后，坐标原点在(x,y)。

* Canvas.rotate():画布翻转，可理解为坐标系的翻转。canvas.rotate(30);为按照坐标系的原点顺时针旋转30度。canvas.rotate(30,x,y);为按照坐标系的(x,y)点顺时针旋转30度。

* Canvas.saveLayer()、Canvas.saveLayerAlpha():将一个图层入栈。

* Canvas.restore()、Canvas.restoreToCount():将一个图层出栈。

6.5 Android图像处理之色彩特效处理
-------
* 色调：`setRotate(int axis,float degree)`设置颜色的色调。第一个参数，系统分别使用0、1、2来代表Red、Green、Blue三种颜色的处理。而第二个参数就是需要处理的值。

		ColorMatrix hueMatrix = new ColorMatrix();
        hueMatrix.setRotate(0, hue0);
        hueMatrix.setRotate(1, hue1);
        hueMatrix.setRotate(2, hue2);

通过上面的方法，可以为RGB三种颜色分量分别重新设置了不同的色调值。

* 饱和度：`setSaturation(float sat)`方法来设置颜色的饱和度，参数即代表设置颜色饱和度的值，代码如下所示。当饱和度为0时，图像就变成灰色图像了。

		ColorMatrix saturationMatrix = new ColorMatrix();
        saturationMatrix.setSaturation(saturation);

* 亮度：当三原色以相同的比例进行混合的时候，就会显示出白色。系统也正是使用这个原理来改变一个图像的亮度的，代码如下所示。当亮度为0时，图像就变成全黑了。

		ColorMatrix lumMatrix = new ColorMatrix();
        lumMatrix.setScale(lum,lum,lum,1);

* `postConcat()`方法将矩阵的作用效果混合，从而叠加处理效果，代码如下：

		ColorMatrix imageMatrix = new ColorMatrix();
    	imageMatrix.postConcat(hueMatrix);
        imageMatrix.postConcat(saturationMatrix);
        imageMatrix.postConcat(lumMatrix);

6.6 Android图像处理之图形特效处理
-------------------
* matrix.setRotate()——旋转变换
* matrix.setTranslate()——平移变换
* matrix.setScale()——缩放变换
* matrix.setSkew()——错切变换
* pre()和post()——提供矩阵的前乘和后乘运算

6.7 Android图像处理之画笔特效处理
--------------------
	mPaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
可以实现圆形ImageView。