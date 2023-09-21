## 配置将ts文件编译成js文件

### 安装编译器

```bash
# 安装
npm install -g typescript
# 查看是否安装成功
tsc -v
```

### 命令行编译

```bash
tsc filename.ts
```

这时候会产生一个问题，就是产生的 `.js`和 `.ts`在同一个目录下，可以创建 `tsconfig.json`（可以手动创建，也可以使用 `tsc -init`生成这个文件），并配置 `"outDir":"target/directory"`，此时再运行上述命令，`.ts`就会生成到对应目录

### VSCode编译

配置 `.vscode/lauch.json`文件
