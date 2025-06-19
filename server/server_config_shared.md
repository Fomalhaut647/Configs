## 前言
这是自用的服务器快速配置指南，用于临时租用的一次性的 Ubuntu 服务器





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





# 创建非 root 用户 & 配置 SSH 密钥登录
获取本地公钥，复制屏幕上显示的 `ssh-ed25519 AAA...` 整行内容
```zsh
cat ~/.ssh/id_ed25519.pub
```

然后在服务器上执行以下操作
```bash
# 1. 创建一个禁用了密码的用户 (将 username 替换为你想要的用户名)
adduser --disabled-password username

# 2. 切换到新用户的身份，创建 .ssh 目录并设置正确权限 (700)
# 使用 su -c "..." 可以在不离开 root shell 的情况下以其他用户身份执行命令
# 这样做可以确保新创建的目录和文件的所有者是正确的 (username:username)
su - username -c "mkdir ~/.ssh && chmod 700 ~/.ssh"

# 3. 切换到新用户身份，将你的公钥写入 authorized_keys 文件，并设置正确权限 (600)
# 将 'ssh-ed25519 AAA...' 替换成你第一步复制的真实公钥
su - username -c "echo 'ssh-ed25519 AAA...' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# 4. 为新用户添加 sudo 权限
usermod -aG sudo username
```
创建用户时，可能会提示输入 `Full name` 等信息，一路回车即可

然后断开连接并重连服务器

```bash
ssh username@server_ip
```

## 如果嫌麻烦，可以采用一种安全性更低但更简单的方法
创建带密码的用户，然后断开连接（部分服务器禁止创建空密码）
```bash
sudo adduser username

usermod -aG sudo username    # 别忘了为新用户添加 sudo 权限
```

在本地使用 `ssh-copy-id` 指令登录，这个指令会自动配置密钥信息
```zsh
ssh-copy-id username@server_ip
```
> 这个指令必须使用密码，所以如果一开始就禁用密码，则无法使用该指令

锁定该账户的密码，使其恢复到无法通过密码登录的安全状态
```bash
sudo passwd -l username
```

同时锁定 `root` 的密码登录
```bash
sudo passwd -l root
```

这个方法会在短时间内暴露一个可用的密码，如果操作不熟练或者忘记最后禁用密码，会留下安全隐患

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
```
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
使用这个[网站](https://www.toptal.com/developers/gitignore)，根据操作系统、IDE、语言来自动生成 `.gitignore` 文件

以 Linux + MacOS + Python + VS Code 为例

```
# Created by https://www.toptal.com/developers/gitignore/api/linux,macos,python,visualstudiocode
# Edit at https://www.toptal.com/developers/gitignore?templates=linux,macos,python,visualstudiocode

### Linux ###
*~

# temporary files which can be created if a process still has a handle open of a deleted file
.fuse_hidden*

# KDE directory preferences
.directory

# Linux trash folder which might appear on any partition or disk
.Trash-*

# .nfs files are created when an open file is removed but is still being accessed
.nfs*

### macOS ###
# General
.DS_Store
.AppleDouble
.LSOverride

# Icon must end with two \r
Icon


# Thumbnails
._*

# Files that might appear in the root of a volume
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Directories potentially created on remote AFP share
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

### macOS Patch ###
# iCloud generated files
*.icloud

### Python ###
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
#   For a library or package, you might want to ignore these files since the code is
#   intended to run in multiple environments; otherwise, check them in:
# .python-version

# pipenv
#   According to pypa/pipenv#598, it is recommended to include Pipfile.lock in version control.
#   However, in case of collaboration, if having platform-specific dependencies or dependencies
#   having no cross-platform support, pipenv may install dependencies that don't work, or not
#   install all needed dependencies.
#Pipfile.lock

# poetry
#   Similar to Pipfile.lock, it is generally recommended to include poetry.lock in version control.
#   This is especially recommended for binary packages to ensure reproducibility, and is more
#   commonly ignored for libraries.
#   https://python-poetry.org/docs/basic-usage/#commit-your-poetrylock-file-to-version-control
#poetry.lock

# pdm
#   Similar to Pipfile.lock, it is generally recommended to include pdm.lock in version control.
#pdm.lock
#   pdm stores project-wide configurations in .pdm.toml, but it is recommended to not include it
#   in version control.
#   https://pdm.fming.dev/#use-with-ide
.pdm.toml

# PEP 582; used by e.g. github.com/David-OConnor/pyflow and github.com/pdm-project/pdm
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/

# PyCharm
#  JetBrains specific template is maintained in a separate JetBrains.gitignore that can
#  be found at https://github.com/github/gitignore/blob/main/Global/JetBrains.gitignore
#  and can be added to the global gitignore or merged into this file.  For a more nuclear
#  option (not recommended) you can uncomment the following to ignore the entire idea folder.
#.idea/

### Python Patch ###
# Poetry local configuration file - https://python-poetry.org/docs/configuration/#local-configuration
poetry.toml

# ruff
.ruff_cache/

# LSP config files
pyrightconfig.json

### VisualStudioCode ###
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
!.vscode/*.code-snippets

# Local History for Visual Studio Code
.history/

# Built Visual Studio Code Extensions
*.vsix

### VisualStudioCode Patch ###
# Ignore all local history of files
.history
.ionide

# End of https://www.toptal.com/developers/gitignore/api/linux,macos,python,visualstudiocode
```

然后加上个性化配置
```
### Custom ###
test.py # 示例
```





# Cursor (VS Code) 配置
## 安装 cursor (code) 命令
安装之后，可以在终端中使用 `cursor file` 或用 `code file` 来用 Cursor (VS Code) 打开文件

1. 在 Cursor 中使用 `Cmd/Crtl + Shift + P` 打开命令面板

2. 键入 `shell`

3. 选择 `Shell Command: Install 'cursor' command` 来安装 cursor

4. 现在就可以使用 `cursor file` 来用 Cursor 打开文件了

> 如果选择 `Shell Command: Install 'code' command`，则可以使用 `code` 来打开文件

> VS Code 可以进行类似的配置，选择 `Shell Command: Install 'code' command in PATH`，然后就可以使用 `code file` 来用 VS Code 打开文件了





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





# 使用mihomo来完成网络代理
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

### 获取config.yaml
1. 首先需要买一个🪜，不多赘述

2. 假设已经有一个🪜了，而且在有图形界面的本地（也就是平时用的环境，比如windows, macOS）可以正常使用

3. 以clash verge rev为例，打开”订阅“那一栏，右键你的🪜子，选择”编辑文件“，就可以打开它的config.yaml了，也许不叫这个名字，但至少扩展名是yaml。

4. 另存为或复制为config.yaml，上传到服务器
