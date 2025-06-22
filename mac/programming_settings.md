# Homebrew
> `Homebrew` 是一款针对 macOS 和 Linux 操作系统的免费开源软件包管理器，在 macOS 上很常用

可以在 [LCPU Getting Started](https://missing.lcpu.dev/basic/05-drive-your-computer-1#_1-1-3-macos-环境配置——以-m-系列芯片为例)
查看简要教程，或者去 [Homebrew 官网](https://brew.sh) 查看更丰富的文档

清华 Tuna 镜像站提供 [Homebrew 镜像](https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/)

`Homebrew` 的命名非常有特色，它使用 `cask` `keg` `rack` 等和 `brew` 相关的单词替换变成术语，可以在 [Homebrew 手册](https://docs.brew.sh/Manpage) 中查看

可以在 [Homebrew 包浏览器](https://formulae.brew.sh) 中查看软件包的相关信息





# 免密 sudo
> 此配置用于免密执行 `sudo`

执行命令
```bash
sudo visudo
```

找到以下配置
```bash
# root and users in group wheel can run anything on any machine as any user
root            ALL = (ALL) ALL
%admin          ALL = (ALL) ALL
```

在下面添加以下内容，注意把 username 替换为你的用户名
```bash
username ALL=(ALL) NOPASSWD: ALL
```