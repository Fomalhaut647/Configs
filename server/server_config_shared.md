## 前言
这是自用的服务器快速配置指南，用于临时租用的一次性的 Ubuntu 服务器

- [镜像配置](#镜像配置)
  - [Ubuntu 镜像](#ubuntu-镜像)
    - [Ubuntu 22.04](#ubuntu-2204)
    - [Ubuntu 24.04](#ubuntu-2404)
  - [Pypi 镜像（北大源）](#pypi-镜像北大源)
  - [Hugging-Face 镜像](#hugging-face-镜像)
- [更新软件包列表和升级系统](#更新软件包列表和升级系统)
- [创建非 root 用户 \& 配置 SSH 密钥登录](#创建非-root-用户--配置-ssh-密钥登录)
  - [关闭密码登录](#关闭密码登录)
  - [安装并配置 sudo](#安装并配置-sudo)
  - [使用终端而不是 VS Code 连接](#使用终端而不是-vs-code-连接)
- [配置 `zsh`](#配置-zsh)
  - [安装 `zsh`](#安装-zsh)
  - [安装 `oh my zsh` 和 `plugins`](#安装-oh-my-zsh-和-plugins)
  - [设置本地字体](#设置本地字体)
- [配置 Github](#配置-github)
  - [配置 SSH](#配置-ssh)
  - [初始化](#初始化)
  - [配置 .gitignore](#配置-gitignore)
    - [`.gitignore_global`](#gitignore_global)
    - [`.gitignore`](#gitignore)
- [设置默认的文本编辑器](#设置默认的文本编辑器)
  - [安装 cursor (code) 命令](#安装-cursor-code-命令)
- [安装 Cuda](#安装-cuda)
  - [Ubuntu 自动安装](#ubuntu-自动安装)
  - [下载并执行安装包](#下载并执行安装包)
  - [配置环境变量](#配置环境变量)
  - [验证安装](#验证安装)
  - [安装 NVIDIA Container Toolkit](#安装-nvidia-container-toolkit)
- [安装 Python 环境（mini-conda）](#安装-python-环境mini-conda)
- [安装 Docker](#安装-docker)
- [使用 mihomo 来完成网络代理](#使用-mihomo-来完成网络代理)
  - [获取config.yaml](#获取configyaml)
  - [使用校园网](#使用校园网)
- [安全配置](#安全配置)
  - [安全设置 API 密钥](#安全设置-api-密钥)
    - [核心思想](#核心思想)
    - [操作步骤](#操作步骤)
      - [第一步：创建私密文件](#第一步创建私密文件)
      - [第二步：添加你的 API 密钥](#第二步添加你的-api-密钥)
      - [第三步：设置文件权限（关键安全步骤）](#第三步设置文件权限关键安全步骤)
      - [第四步：配置全局 Git 忽略](#第四步配置全局-git-忽略)
      - [第五步：让 Shell 自动加载密钥](#第五步让-shell-自动加载密钥)
      - [第六步：应用更改并验证](#第六步应用更改并验证)
    - [总结](#总结)
  - [防火墙](#防火墙)



# 镜像配置
## Ubuntu 镜像
在 [PKU 镜像](https://mirrors.pku.edu.cn/Help/Ubuntu) 中选择合适的版本，然后配置

### Ubuntu 22.04
使用命令修改
```bash
sudo sed -ri.bak -e 's/\/\/.*?(archive.ubuntu.com|mirrors.*?)\/ubuntu/\/\/mirrors.pku.edu.cn\/ubuntu/g' -e '/security.ubuntu.com\/ubuntu/d' /etc/apt/sources.list
```
注：该命令表示将 `archive.ubuntu.com` 和 `mirrors.*` 替换为 `mirrors.pku.edu.cn`，并把 `security.ubuntu.com` 删除。

修改文件后需要更新索引：
```bash
sudo apt-get update
sudo apt-get upgrade    # 顺便 upgrade
```

### Ubuntu 24.04
手动替换原有的/etc/apt/sources.list.d/ubuntu.sources文件内容为：
```
Types: deb
URIs: https://mirrors.pku.edu.cn/ubuntu
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
# Types: deb-src
# URIs: https://mirrors.pku.edu.cn/ubuntu
# Suites: noble noble-updates noble-backports
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# Types: deb-src
# URIs: http://security.ubuntu.com/ubuntu/
# Suites: noble-security
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 预发布软件源，不建议启用

# Types: deb
# URIs: https://mirrors.pku.edu.cn/ubuntu
# Suites: noble-proposed
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# # Types: deb-src
# # URIs: https://mirrors.pku.edu.cn/ubuntu
# # Suites: noble-proposed
# # Components: main restricted universe multiverse
# # Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

修改文件后需要更新索引：
```bash
sudo apt-get update
sudo apt-get upgrade    # 顺便升级了
```



## Pypi 镜像（北大源）
```bash
pip install pip -U -i https://mirrors.pku.edu.cn/pypi/web/simple    # 首先将pip版本升级至10.0.0+
pip config set global.index-url https://mirrors.pku.edu.cn/pypi/web/simple
```



## Hugging-Face 镜像
```bash
echo 'export HF_ENDPOINT="https://hf-mirror.com"' >> ~/.bashrc
echo 'export HF_HUB_DOWNLOAD_ENDPOINT="https://hf-mirror.com"' >> ~/.bashrc
```





# 更新软件包列表和升级系统
```bash
sudo apt update && sudo apt upgrade -y
```

设置时区为上海
```bash
sudo timedatectl set-timezone Asia/Shanghai
```





# 创建非 root 用户 & 配置 SSH 密钥登录
获取本地公钥，复制屏幕上显示的 `ssh-ed25519 AAA...` 整行内容
```zsh
cat ~/.ssh/id_ed25519.pub
```

创建用户，然后断开连接（部分服务器禁止创建空密码）
```bash
sudo adduser username

usermod -aG sudo username    # 为新用户添加 sudo 权限
```

在本地使用 `ssh-copy-id` 指令登录，这个指令会自动配置密钥信息
```zsh
ssh-copy-id username@server_ip
```



## 关闭密码登录
1. 编辑 `sshd_config`
```bash
sudo vim /etc/ssh/sshd_config
```

2. 找到如下内容
```bash
# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no
```

3. 设置 `PasswordAuthentication` 为 `no` 并取消注释
```bash
# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no
#PermitEmptyPasswords no
```

4. 检查配置文件是否有语法错误
```bash
sudo sshd -t
```

5. 重启 SSH 服务
```bash
sudo systemctl restart ssh
```



## 安装并配置 sudo
`sudo` 命令是一个可执行的程序（通常位于 `/usr/bin/sudo`），而部分轻量化的服务器没有安装这个程序，所以即使把 `username` 加入到了 `sudo` 用户组里，也无法使用 `sudo` 指令，此时我们需要使用 `root` 用户来安装并配置 `sudo`

```bash
which sudo    # 使用这条指令来检查 sudo 是否已经安装

apt install sudo -y    # 安装 sudo
```

初始情况下，使用 `sudo` 命令时需要输入密码，而我们已经禁用密码了，所以我们必须配置免密使用 `sudo` （即使可以使用密码，也建议配置免密，你也不想每次使用 `sudo` 都要输入密码吧）

以 `root` 身份执行以下命令
```bash
visudo
```

在打开的文件中找到这一行配置
```
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
```

添加 `NOPASSWD:`，然后保存并退出
```
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) NOPASSWD:ALL
```

使用 `username` 重连，然后用这个指令检查 `sudo` 是否正常工作
```bash
sudo whoami    # 预期输出 "root"
```



## 使用终端而不是 VS Code 连接
使用终端连接时激活的是 Login Shell，使用 VS Code 连接时激活的是 Non-Login Shell，它们加载的环境变量可能不同

如果使用终端连接时出现了环境变量 bug，可以在 `~/.profile` 中添加以下内容，这样在使用 Login Shell 时会额外加载 `~/.bashrc` 文件
```bash
# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
```



# 配置 `zsh`
## 安装 `zsh`
```bash
sudo apt install zsh
chsh -s $(which zsh)    # 大部分 Linux 的默认 shell 为 bash，需要更改为 zsh
```

重启终端

检查默认 shell 是否是 zsh
```bash
$SHELL --version
```
> 如果默认 shell 还是 bash，可以尝试重启服务器



## 安装 `oh my zsh` 和 `plugins`
```bash
git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh    # 使用 Gitee 镜像

# 修改更新源（可选）
cd ~/.oh-my-zsh
git remote set-url origin https://gitee.com/mirrors/oh-my-zsh.git
cd
```

复制并覆盖 `.zshrc`

安装第三方 `plugins`
```zsh
git clone https://github.com/zsh-users/zsh-completions.git \
  ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

安装 `Powerlevel10k`
> 一个好看的 UI
> 但这个主题似乎会导致 Cursor 侧边 AI 执行终端指令之后卡住，慎用

```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

重启终端，配置 `Powerlevel10k`



## 设置本地字体
可以根据需要设置本地字体（建议完成）
[MesloLGS NF](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#meslo-nerd-font-patched-for-powerlevel10k)
> 由于字体渲染在本地进行，所以字体配置应该在本地而不是服务器进行





# 配置 Github
## 配置 SSH
创建一个临时密钥，然后将这个新生成的公钥 (your_repo_name.pub) 添加到你个人 GitHub 帐户的 SSH Key 列表中（路径：Settings -> SSH and GPG keys）
```bash
ssh-keygen -t ed25519 -f ~/.ssh/your_repo_name -C "your_repo_name"
# 如果不怕混淆密钥，可以不加 -f ~/.ssh/your_repo_name
```

使用以下指令检查与 Github 的 SSH 连接
```bash
ssh -T git@github.com
```

如果使用个性化密钥名，且连接 Github 时出错，在 `~/.ssh/config` （如果文件不存在，新建文件即可）中添加以下内容或许可以修复 bug
```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/your_repo_name
```

在结束项目开发后，记得去 Github 设置里删除这个临时密钥



## 初始化
> 如果已经配置了 `git` `zsh plugins`，不用配置别名
```bash
# 设置你的用户名 (必做)
git config --global user.name "Your Name"

# 设置你的邮箱 (必做)
git config --global user.email "your_email@example.com"

# 设置默认分支名
git config --global init.defaultBranch main

# 设置默认文本编辑器
git config --global core.editor "cursor --wait"

# 处理行尾换行符 (非常重要，特别是跨平台协作)
# Windows 用户推荐设置
git config --global core.autocrlf true

# macOS / Linux 用户推荐设置
git config --global core.autocrlf input

# 让 git pull 更安全
git config --global pull.rebase true

# 启用颜色高亮（默认启用）
git config --global color.ui auto

# 高效别名 (Alias) (示例)
# --------------------
# 基础命令缩写
# --------------------
# 用 'git a' 代替 'git add .'
git config --global alias.a "add ."
# 用 'git s' 代替 'git status'
git config --global alias.s "status -s"
# 用 'git c' 代替 'git checkout'
git config --global alias.c "checkout"
# 用 'git b' 代替 'git branch'
git config --global alias.b "branch"
# 用 'git cm' 代替 'git commit -m'
git config --global alias.cm "commit -m"    # (用法: git cm "你的提交信息")
# 用 'git p' 代替 'git push'
git config --global alias.p "push"
# 用 'git pl' 代替 'git pull'
git config --global alias.pl "pull"

# --------------------
# 实用组合命令
# --------------------
# 撤销暂存区的文件 (unstage)
git config --global alias.unstage "reset HEAD --"
# 查看最后一次的提交内容
git config --global alias.last "log -1 HEAD"
# 添加所有变更并提交
git config --global alias.ca "commit -a -m" 
# (用法: git ca "你的提交信息")

# --------------------
# 超级日志 (Gemini 2.5 pro 倾情推荐)
# --------------------
# 一个格式化、带图形和颜色、显示所有分支的日志
git config --global alias.l "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
```

也可以直接配置 `~/.gitconfig`
```bash
# Git 全局配置文件
# ==================================

# (必做) 设置你的身份信息
[user]
    name = Your Name              # <-- 请替换成你的名字
    email = your_email@example.com # <-- 请替换成你的邮箱

# 核心设置
[core]
    # 设置默认文本编辑器
    editor = cursor --wait
    # (重要) 处理行尾换行符
    # 如果你在 Windows 上开发，使用 true
    # 如果你在 macOS 或 Linux 上开发，使用 input
    autocrlf = input             # <-- 根据你的操作系统选择 true 或 input

# 新仓库的默认设置
[init]
    # 设置默认分支名为 main
    defaultBranch = main

# pull 命令的默认行为
[pull]
    # 让 git pull 使用 rebase 而不是 merge，保持提交历史整洁
    rebase = true

# 启用颜色高亮
[color]
    ui = auto

# 高效别名 (Alias)
# --------------------
[alias]
    # --- 基础命令缩写 ---
	a = add .
    s = status -s
    c = checkout
    b = branch
    cm = commit -m
    p = push
    pl = pull

    # --- 实用组合命令 ---
    # 撤销暂存区的文件 (unstage)
    unstage = reset HEAD --
    # 查看最后一次的提交内容
    last = log -1 HEAD
    # 添加所有变更并提交
    ca = commit -a -m

    # --- 超级日志 (Gemini 2.5 pro 倾情推荐) ---
    # 一个格式化、带图形和颜色、显示所有分支的日志
    l = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all
```



## 配置 .gitignore
由于操作系统、IDE 与你的个人开发环境相关，虽然你需要忽略相关的文件，但是合作者可能使用不同的操作系统和 IDE，他需要忽略不同的文件，所以这部分最好写在全局 `.gitignore_global` 中而不是放在项目级的 `.gitignore` 中

而项目使用的语言或者数据集等，与项目本身相关，无论谁都需要忽略，这种需要放在 `.gitignore` 中

使用这个[网站](https://www.toptal.com/developers/gitignore)，根据操作系统、IDE、语言来自动生成 `.gitignore` 文件

### `.gitignore_global`
配置的逻辑是，`Git` 使用 `git config --global core.excludesfile file` 把 `file` 中的文件添加到全局忽略中

所以我们先在用户目录下创建 `.gitignore_global` 文件（这是一个常用的文件名，你可以使用其他名字），然后在里面添加需要全局忽略的文件，最后把这个文件添加到 `Git` 的全局忽略中

```bash
# 添加到 Git 全局忽略
git config --global core.excludesfile ~/.gitignore_global

# 配置 .gitignore_global
touch ~/.gitignore_global
cursor ~/.gitignore_global

# 最后把使用网站生成的代码复制进去
```

### `.gitignore`
正常配置即可





# 设置默认的文本编辑器
## 安装 cursor (code) 命令
安装之后，可以在终端中使用 `cursor file` 或用 `code file` 来用 Cursor (VS Code) 打开文件

1. 在 Cursor 中使用 `Cmd/Crtl + Shift + P` 打开命令面板

2. 键入 `shell`

3. 选择 `Shell Command: Install 'cursor' command` 来安装 cursor

4. 现在就可以使用 `cursor file` 来用 Cursor 打开文件了

> 如果选择 `Shell Command: Install 'code' command`，则可以使用 `code` 来打开文件

> VS Code 可以进行类似的配置，选择 `Shell Command: Install 'code' command in PATH`，然后就可以使用 `code file` 来用 VS Code 打开文件了





# 安装 Cuda
> Ubuntu 自带了一个开源的 NVIDIA 驱动 `nouveau`，它可能与官方闭源驱动冲突，可能需要禁用

如果手动安装 Cuda，Cuda 更新、卸载繁琐，在更新 Linux 内核后或其他更新后可能会出现兼容性问题

所以除非需要使用特定版本的 `CUDA`，否则建议使用 `sudo ubuntu-drivers autoinstall` 自动安装 `Driver`，
然后使用下载并执行官方安装包来安装 `Toolkit` 等



## Ubuntu 自动安装
```bash
sudo ubuntu-drivers autoinstall
```



## 下载并执行安装包
先安装核心依赖包
```bash
sudo apt update
sudo apt install build-essential dkms linux-headers-$(uname -r)
```

访问[NVIDIA CUDA Toolkit 下载中心](https://developer.nvidia.com/cuda-downloads)

选择对应的操作系统、架构、发行版、版本、安装类型（推荐 `runfile (local)`）并执行官方给出的指令，
可能需要在执行安装包之前给安装包添加可执行权限 `sudo chmod +x cuda_xxx.run`

在 `CUDA Installer` 选项界面，取消勾选 `Driver`，然后安装
> 安装 `nvidia-fs` 需要安装依赖包 `MOFED`，它的安装非常复杂，单机开发项目的话不建议勾选

安装结果示例
```
===========
= Summary =
===========

Driver:   Not Selected
Toolkit:  Installed in /usr/local/cuda-12.9/

Please make sure that
 -   PATH includes /usr/local/cuda-12.9/bin
 -   LD_LIBRARY_PATH includes /usr/local/cuda-12.9/lib64, or, add /usr/local/cuda-12.9/lib64 to /etc/ld.so.conf and run ldconfig as root

To uninstall the CUDA Toolkit, run cuda-uninstaller in /usr/local/cuda-12.9/bin
***WARNING: Incomplete installation! This installation did not install the CUDA Driver. A driver of version at least 575.00 is required for CUDA 12.9 functionality to work.
To install the driver using this installer, run the following command, replacing <CudaInstaller> with the name of this run file:
    sudo <CudaInstaller>.run --silent --driver

Logfile is /var/log/cuda-installer.log
```



## 配置环境变量
把 `cuda-xxx` 替换成对应的版本
```bash
echo 'export PATH=/usr/local/cuda-xxx/bin${PATH:+:${PATH}}' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-xxx/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc
```



## 验证安装
执行 `nvidia-smi` 指令查看 GPU 型号、驱动版本、CUDA Version
> `nvidia-smi` 显示的 `CUDA Version` 是指该 _驱动_ 最高支持的 CUDA 版本，不代表你安装的 CUDA Toolkit 版本

执行 `nvcc --version` 查看 `Cuda Toolkit` 版本

安装之后最好重启服务器
```bash
sudo reboot
```

可以额外安装 `nvtop` 来检测 `GPU` 信息（类似 `htop`）
```bash
sudo apt install nvtop
```



## 安装 NVIDIA Container Toolkit
如果需要在 Docker 中使用 CUDA，需要安装 `NVIDIA Container Toolkit`

[Installing the NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

安装之后需要重启 Docker `sudo systemctl restart docker`





# 安装 Python 环境（mini-conda）
> 以 x86-64 架构的 Linux 服务器为例
1. 使用北大镜像源下载安装包

> 如果想使用官方安装包，打开这个网站 [conda-forge/miniforge](https://github.com/conda-forge/miniforge/releases) 下载对应的安装包并复制到服务器上，如果已经配置网络代理，可以直接 wget
```bash
# 北大镜像源
wget https://mirrors.pku.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh

# 官方安装包（示例）
wget https://github.com/conda-forge/miniforge/releases/download/25.3.0-3/Miniforge3-Linux-x86_64.sh
```

2. 安装
```bash
# 先添加执行权限
chmod +x Miniconda3-latest-Linux-x86_64.sh

./Miniconda3-latest-Linux-x86_64.sh
# 可以使用 q 来退出查看说明文档，一般来说各种询问全部回答 yes 就可以了
```

3. 重启终端，从而启用 conda 环境

4. 创建并切换虚拟环境
```bash
conda create --name your_env python=3.13
conda activate your_env
```

5. 安装常用的 python 库（示例）
```bash
pip install numpy matplotlib seaborn scikit-learn transformers scipy jupyterlab
pip3 install torch torchvision torchaudio

# 注意 opencv 已经弃用，应该安装 opencv-python
pip install opencv-python 
pip install nltk
```

可以去 [Pytorch Installation](https://pytorch.org/get-started/locally/) 查看针对不同配置的具体的 `Pytorch` 安装指令





# 安装 Docker
[🚀 Docker — 从入门到实践](https://yeasy.gitbook.io/docker_practice)

这是一个知名的写给中国大陆用户的 Docker 中文教程

1. 安装 Docker [以 Ubuntu 为例](https://yeasy.gitbook.io/docker_practice/install/ubuntu)

2. 配置镜像加速器 [DockerHub 国内加速镜像列表](https://github.com/dongyubin/DockerHub)
> 关于软件镜像站和镜像加速器的区别可以自行询问 AI
>
> 现在阿里云等不再提供完全公用的 DockerHub 镜像加速器，只有部分自家的产品可以使用

3. 如果需要在 Docker 内部使用 CUDA，需要安装 [NVIDIA Container Toolkit](#安装-nvidia-container-toolkit)





# 使用 mihomo 来完成网络代理
官方教程在这里
[Mihomo Wiki](https://wiki.metacubex.one/startup/service/)

官方教程挺详细，但是有一些步骤实际上不需要自己完成，apt install mihomo 就可以自动完成除了配置config.yaml外的操作

1. 在可以翻墙的电脑上下载对应版本的包，以ubuntu为例，“mihomo-linux-amd64-v1.19.4.deb"

2. 把这个文件和买的🪜的 "config.yaml" 上传到服务器，比如我直接传到 "~/Downloads" 下

3. 
```bash
cd ~/Downloads
```

4. 
```bash
sudo apt install ./mihomo-linux-amd64-v1.19.4.deb
```

5. 
```bash
sudo mkdir /etc/mihomo -p
```

6. 
```bash
sudo cp ./config.yaml /etc/mihomo
```

7. 
```bash
systemctl daemon-reload
systemctl enable mihomo
systemctl start mihomo
systemctl status mihomo
```

8. 开启临时代理
```bash
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:7891"
```

9. 测试是否能正常翻墙
```bash
curl www.google.com
```

**如果想配置永久代理，需要添加到启动配置文件**

1. 打开配置文件
```bash
cursor ~/.bashrc
```

2. 添加以下内容
```bash
export http_proxy="http://127.0.0.1:7890"
export https_proxy="http://127.0.0.1:7890"
export all_proxy="socks5://127.0.0.1:7891"
```

3. 重启终端



## 获取config.yaml
1. 首先需要买一个🪜，不多赘述

2. 假设已经有一个🪜了，而且在有图形界面的本地（也就是平时用的环境，比如windows, macOS）可以正常使用

3. 以clash verge rev为例，打开”订阅“那一栏，右键你的🪜子，选择”编辑文件“，就可以打开它的config.yaml了，也许不叫这个名字，但至少扩展名是yaml。

4. 另存为或复制为config.yaml，上传到服务器



## 使用校园网
如果需要在北大校内使用校园网访问校外网站，必须连接[网关](https://its.pku.edu.cn/download_ipgwclient.jsp)

在终端输入以下指令即可连接网关
> username 的参数替换为你的校园卡号，password 的参数替换为你的北大账号密码

```bash
curl -X POST  -d 'cmd=open&username=your_student_id&password=your_password&iprange=free' https://its4.pku.edu.cn/cas/ITSClient
```
> 如需断开链接，请将open改为disconnect





# 安全配置
一些用于提升安全性的配置



## 安全设置 API 密钥
> 我的一位朋友曾经不小心把自己的 Deepseek API 密钥上传到了 Github，很快就被用完了

在开发，尤其是 AI 和数据科学项目中，我们经常需要使用 API 密钥、数据库密码或其他敏感凭证。将这些信息直接写入代码或通用的配置文件（如 `.bashrc`）是一种危险的做法，因为它们很容易被意外提交到 Git 仓库中，从而导致密钥泄露。

本教程将指导你使用一种简单而安全的方法：**将密钥存储在本地独立的私密文件中，并让 Shell 自动加载它们**。

### 核心思想

1.  **分离**：将敏感信息（Secrets）存储在一个专门的文件中（例如 `~/.secrets`）。
2.  **保护**：设置该文件的权限，使其只有你本人可以读写。
3.  **忽略**：通过 `.gitignore` 规则，确保这个文件永远不会被 Git跟踪。
4.  **加载**：在你的 Shell 配置文件（如 `.bashrc` 或 `.zshrc`）中添加逻辑，在启动时自动加载这些密钥到环境变量中。

-----

### 操作步骤

#### 第一步：创建私密文件

首先，在你的用户主目录下创建一个用于存放密钥的文件。我们将其命名为 `.secrets`。

```bash
touch ~/.secrets
```

> **提示**：文件名以 `.` 开头，使其成为一个隐藏文件，在常规的 `ls` 命令下不会显示，可以减少误操作的风险。

#### 第二步：添加你的 API 密钥

使用你喜欢的文本编辑器打开这个文件，并以 `export` 语法添加你的密钥。

```bash
# 你可以使用 nano, vim, 或者 VS Code
cursor ~/.secrets
```

在文件中，按以下格式添加内容，一行一个密钥：

```bash
# ~/.secrets 文件内容示例

export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export HUGGING_FACE_TOKEN="hf_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

保存并关闭文件。

#### 第三步：设置文件权限（关键安全步骤）

为了防止系统上的其他用户读取你的密钥文件，我们需要修改其文件权限，设置为只有文件所有者（也就是你）可以读取和写入。

```bash
chmod 600 ~/.secrets
```

  * `chmod 600` 的意思是：
      * `6` (所有者权限): 读 (4) + 写 (2) = 6
      * `0` (用户组权限): 无权限
      * `0` (其他用户权限): 无权限

#### 第四步：配置全局 Git 忽略

为了确保你所有的 Git 项目都不会跟踪到 `.secrets` 文件，我们将其添加到 **Git 的全局忽略文件**中。这样，你就不需要在每个新项目的 `.gitignore` 中重复添加它。

1.  **设置全局忽略文件（如果尚未设置）**

    ```bash
    git config --global core.excludesfile '~/.gitignore_global'
    ```

2.  **将 `.secrets` 添加到全局忽略列表**

    ```bash
    echo ".secrets" >> ~/.gitignore_global
    ```

    这条命令会将 `.secrets` 这一行追加到你的全局 Git 忽略文件中。现在，你系统上任何位置的 Git 仓库都会自动忽略名为 `.secrets` 的文件。

#### 第五步：让 Shell 自动加载密钥

打开你的 Shell 配置文件。如果你使用 Bash，就是 `~/.bashrc`；如果你使用 Zsh（在较新的 macOS 上是默认的），就是 `~/.zshrc`。

```bash
# 编辑 Bash 配置文件
cursor ~/.bashrc

# 或者编辑 Zsh 配置文件
cursor ~/.zshrc
```

在文件的末尾，添加以下代码片段：

```bash
# Load secrets from the .secrets file if it exists
if [ -f ~/.secrets ]; then
    . ~/.secrets
fi
```

这段代码的含义是：

  * `if [ -f ~/.secrets ]`：检查 `~/.secrets` 文件是否存在并且是一个普通文件。
  * `. ~/.secrets`：如果文件存在，就执行（或 "source"）它，将其中的 `export` 命令在当前 Shell 中生效。

#### 第六步：应用更改并验证

最后，让你的更改立即生效，并验证密钥是否已成功加载到环境中。

1.  **重新加载配置文件**

    ```bash
    # 如果你用的是 Bash
    source ~/.bashrc

    # 如果你用的是 Zsh
    source ~/.zshrc
    ```

2.  **验证环境变量**
    尝试打印其中一个环境变量，看看是否能成功输出。

    ```bash
    echo $OPENAI_API_KEY
    ```

    如果终端成功打印出你的密钥（`sk-xxxxxxxx...`），那么恭喜你，配置成功了！你的程序现在可以通过读取环境变量来获取密钥，而你的密钥本身又安全地存放在本地，不会被泄露。

### 总结

通过以上六个步骤，你已经建立起一个既方便又安全的环境变量管理工作流。

  - ✅ **安全**：密钥与代码分离，受文件权限保护，且被 Git 全局忽略。
  - ✅ **方便**：一次设置，所有终端会话自动生效。
  - ✅ **整洁**：保持主配置文件 `.bashrc` 的干净，将敏感信息隔离存放。

对于更复杂的项目，你可能还会接触到 `direnv` 或 `python-dotenv` 这样的工具，它们可以实现基于项目目录的更细粒度的环境管理。但今天所学的这个全局方法，是每一位开发者都应该掌握的基础技能。



## 防火墙
Ubuntu 自带了一个非常易用的防火墙工具 `ufw` (Uncomplicated Firewall)

可以使用它来配置防火墙