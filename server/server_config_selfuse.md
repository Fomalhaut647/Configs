## 前言
这是自用的服务器快速配置指南，用于临时租用的一次性的 Ubuntu 服务器





# 设置默认的文本编辑器为 Cursor
1. `Cmd/Crtl + Shift + P` 打开命令面板

2. 键入 `shell`

3. 选择 `Shell Command: Install 'cursor' command`





# 配置 apt 镜像 & 更新
[PKU 镜像](https://mirrors.pku.edu.cn/Help/Ubuntu)



## Ubuntu 22.04
```bash
sudo sed -ri.bak -e 's/\/\/.*?(archive.ubuntu.com|mirrors.*?)\/ubuntu/\/\/mirrors.pku.edu.cn\/ubuntu/g' -e '/security.ubuntu.com\/ubuntu/d' /etc/apt/sources.list
```



## Ubuntu 24.04
```bash
cursor /etc/apt/sources.list.d/ubuntu.sources
```

手动替换文件内容为：
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



## 更新
```bash
sudo apt update
sudo apt upgrade
```





# 创建非 root 用户 & 配置 SSH 密钥登录
## 创建用户
```bash
sudo adduser fomalhaut

usermod -aG sudo fomalhaut
```



## 安装并配置 sudo
```bash
sudo apt install sudo -y

sudo visudo
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



## 重新登录
在本地执行
```zsh
ssh-copy-id fomalhaut@server_ip
```

```bash
sudo passwd -l fomalhaut
sudo passwd -l root
```





# 配置别名
打开 `~/.bashrc`
```bash
cursor ~/.bashrc
```

复制进去
```bash
# ===================================================================
# 1. 文件与目录操作
# ===================================================================

# 用 'ls' 命令显示更人性化的信息
alias l='ls -CF --color=auto' # 自动着色
alias ll='ls -alFh --color=auto'        # 详细列表，包含隐藏文件，文件大小人性化显示

# 快速向上层目录跳转
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# 防止误操作 (非常重要!)
alias rm='rm -i'      # 删除前提示确认
alias cp='cp -i'      # 复制覆盖前提示确认
alias mv='mv -i'      # 移动覆盖前提示确认

# 使用 grep 时高亮匹配项
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'

# 创建目录时，同时创建父目录
alias mkdir='mkdir -p'



# ===================================================================
# 2. Git 操作
# ===================================================================

alias g='git'

# 分支
alias gb='git branch'
alias gsw='git switch'
alias gm='git merge'
alias gbd='git branch -d'

# 进行更改
alias gl='git log --oneline --graph --decorate' # 漂亮的单行 log
alias gd='git diff'
alias gsh='git show'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit -a -m'    # 添加所有已跟踪文件的改动并提交
alias gs='git status -sb'       # 更简洁的状态输出

# 重做提交
alias gr='git reset'
alias grh='git reset --hard'

# 同步更改
alias gf='git fetch'
alias gp='git push'
alias gpl='git pull'



# ===================================================================
# 3. 系统管理与信息 (Ubuntu)
# ===================================================================

# 人性化显示磁盘和内存使用情况
alias free='free -ht'
alias df='df -h'
alias du='du -hd 1' # 快速查看当前目录总大小

# 进程查看
alias psgrep='ps aux | grep -v grep | grep -i' # 从进程中搜索
alias top='htop' # 如果你安装了 htop，用它替代 top



# ===================================================================
# 4. 其他便利别名
# ===================================================================

alias c='clear'
alias e='exit'

alias python='python3'
alias pip='pip3'



# ===================================================================
# 万能解压函数 ex()
#
# 用法: ex <file>
# ===================================================================
ex() {
  # 检查是否提供了文件名
  if [ -z "$1" ]; then
    echo "用法: ex <file>"
    return 1
  fi

  # 检查文件是否存在
  if ! [ -f "$1" ]; then
    echo "错误: '$1' 不是一个有效的文件或不存在。"
    return 1
  fi

  # 根据文件后缀名选择解压命令
  case "$1" in
    *.tar.bz2|*.tbz2) tar -xvjf "$1"    ;;
    *.tar.gz|*.tgz)   tar -xvzf "$1"    ;;
    *.tar.xz|*.txz)   tar -xvJf "$1"    ;;
    *.tar)            tar -xvf "$1"     ;;
    *.zip|*.jar)      unzip "$1"       ;;
    *.rar)            unrar x "$1"     ;;
    *.7z)             7z x "$1"        ;;
    *.gz)             gunzip "$1"      ;;
    *.bz2)            bunzip2 "$1"     ;;
    *)
      echo "错误: 无法识别 '$1' 的压缩格式。"
      return 1
      ;;
  esac
}



# ===================================================================
# 历史记录 (history) 增强
# ===================================================================

# 增加历史记录的保存数量
export HISTSIZE=10000
export HISTFILESIZE=20000

# 忽略重复的命令，以空格开头的命令和简单命令
export HISTCONTROL=ignoreboth
export HISTIGNORE="ls:cd:pwd:exit:history"

# 添加时间戳
export HISTTIMEFORMAT="%F %T "

# 每次执行命令后立即写入历史记录，方便多终端同步
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# 追加历史记录，而不是覆盖
shopt -s histappend
```





# 配置 python 环境
## 下载并安装 mini-conda
```bash
wget https://mirrors.pku.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh

chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
```

重启终端



## 配置 Pypi 镜像
```bash
pip install pip -U -i https://mirrors.pku.edu.cn/pypi/web/simple
pip config set global.index-url https://mirrors.pku.edu.cn/pypi/web/simple
```



## 配置环境 & 安装依赖包
```bash
conda create --name fomalhaut python=3.13
echo "conda activate fomalhaut" >> ~/.bashrc
```

重启终端

```bash
pip install numpy matplotlib pandas seaborn scikit-learn transformers scipy jupyterlab
pip install torch torchvision torchaudio

# 注意 opencv 已经弃用，应该安装 opencv-python
pip install opencv-python 
pip install nltk
```

[Pytorch Installation](https://pytorch.org/get-started/locally/)



## 配置 Hugging-Face 镜像
```bash
echo 'export HF_ENDPOINT="https://hf-mirror.com"' >> ~/.bashrc
echo 'export HF_HUB_DOWNLOAD_ENDPOINT="https://hf-mirror.com"' >> ~/.bashrc
```





# 配置 Github
## 配置 SSH
```bash
ssh-keygen -t ed25519 -C "temp_project"
cat id_ed25519.pub
```

复制公钥，添加到 GitHub 帐户的 SSH Key 列表中（路径：Settings -> SSH and GPG keys）

检查与 Github 的 SSH 连接
```bash
ssh -T git@github.com
```

在结束项目开发后，记得去 Github 设置里删除这个临时密钥



## 配置 .gitignore
### 配置 .gitignore_global
创建并打开 `.gitignore_global`
```bash
touch ~/.gitignore_global
cursor ~/.gitignore_global
```

复制进去
```gitignore
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
```

### 配置 .gitignore
以 `Python` 为例
```bash
cursor .gitignore
```

复制进去
```gitignore
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

### Custom ###
test.py
```



## 配置 .gitconfig
```bash
touch ~/.gitconfig
cursor ~/.gitconfig
```

复制进去
```
[user]
    name = fomalhaut
    email = fomalhaut@stu.pku.edu.cn

[core]
    editor = cursor --wait
    autocrlf = input
	excludesfile = /home/fomalhaut/.gitignore_global

[init]
    defaultBranch = main

[pull]
    rebase = true

[color]
    ui = auto

[alias]
    a = add .
    s = status -s
    c = checkout
    b = branch
    cm = commit -m
    p = push
    pl = pull

    unstage = reset HEAD --
    last = log -1 HEAD
    ca = commit -a -m

    l = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all
```