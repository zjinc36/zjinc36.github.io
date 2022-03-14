# 一般用什么作为HashMap的key

----

一般用Integer、String 这种不可变类当HashMap当key,而且String最为常用。

+	因为字符串是不可变的，所以在它创建的时候hashcode就被缓存了，不需要重新计算。这就是HashMap中的键往往都使用字符串的原因。
+	因为获取对象的时候要用到equals()和hashCode()方法，那么键对象正确的重写这两个方法是非常重要的,这些类已经很规范的重写了hashCode()以及equals()方法。

