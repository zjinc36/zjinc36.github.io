# fcitx4在gnome活动界面搜索框无法输入中文

这个问题无法解决，只是做个记录

具体查看这个讨论

[gnome 活动界面搜索框无法输入中文](https://github.com/fcitx/fcitx/issues/510)

fcitx4 在 gnome 活动界面搜索框无法输入中文的原因：

> fcitx4 是没办法在这个版本的 gnome shell 搜索框用的，因为gnome shell 代码直接调用了 ibus 接口，不再经过 gtk im module。

# 不算解决方案的方案

使用 fcitx5，fcitx5 能使用是因为模拟了 ibus 的接口实现的

但是还有个问题，fcitx5 在 gnome 41 上面的搜索框里面可以打出汉字, 但是看不到输入项候选面板

通过使用这个扩展解决：https://extensions.gnome.org/extension/261/kimpanel/



