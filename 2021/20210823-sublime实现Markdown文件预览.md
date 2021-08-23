#   sublime实现Markdown文件预览

---

##  安装Markdown Preview

支持在浏览器中预览markdown文件

+   Ctrl+Shift+p, 输入 Install Package，输入Markdown Preview, 安装。
+   安装成功后，打开配置文件 Preferences -> Package Settings -> Markdown Preview -> Settings，设置左侧enable_autoreload为true。

```json
{
    "enable_autoreload": true
}
```

+   自定义快捷键
+   在Preferences -> Key Bindings打开的文件的右侧栏的中括号中添加：

```json
{
    "keys":
    [
        "alt+m"
    ],
    "command": "markdown_preview",
    "args":
    {
        "target": "browser",
        "parser": "markdown"
    }
}
```

+   keys 自己设置的按键。
+   parser: Markdown文件的浏览方式, “github”: 使用Github在线API解析markdown; “markdown”: 使用浏览器本地打开。

##  安装LiveReload

+   LiveReload是一个可实时刷新的插件，可用于Markdown，HTML等。
+   Ctrl+Shift+p, 输入 Install Package，输入LiveReload, 安装。
+   安装成功后, 再次Ctrl+shift+p, 输入LiveReload: Enable/disable plug-ins --> 选择 Simple Reload

搞定,每次编辑过.md文件后, 保存, 就会在浏览器自动更新页面。
