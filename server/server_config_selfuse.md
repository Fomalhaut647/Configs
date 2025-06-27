## 前言
这是自用的服务器快速配置指南，用于临时租用的一次性的 Ubuntu 服务器





# 安装 `cursor` 程序
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



## 关闭密码登录
```bash
sudo cursor /etc/ssh/sshd_config
```

找到以下内容
```bash
# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no
```

改为
```bash
# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no
#PermitEmptyPasswords no
```

检验配置是否正确
```bash
sudo sshd -t
```

重启 SSH 服务
```bash
sudo systemctl restart ssh
```





# 配置 `zsh`
## 安装 `zsh`
```bash
sudo apt install zsh
chsh -s $(which zsh)
```

重启终端/服务器

检查默认 shell 是否是 zsh
```zsh
$SHELL --version
```



## 安装 `oh my zsh` 和 `plugins`
```zsh
git clone https://gitee.com/mirrors/oh-my-zsh.git ~/.oh-my-zsh
```

复制并覆盖 `.zshrc`

安装 `plugins`
```zsh
git clone https://github.com/zsh-users/zsh-completions.git \
  ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

安装 `Powerlevel10k`
```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

在本地执行
```zsh
scp ~/.p10k.zsh fomalhaut@desktop:~/.p10k.zsh
```





# 设置时区
```zsh
sudo timedatectl set-timezone Asia/Shanghai
```





# 配置 python 环境
## 下载并安装 mini-conda
```zsh
wget https://mirrors.pku.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh

chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
```

重启终端



## 配置 Pypi 镜像
```zsh
pip install pip -U -i https://mirrors.pku.edu.cn/pypi/web/simple
pip config set global.index-url https://mirrors.pku.edu.cn/pypi/web/simple
```



## 配置环境 & 安装依赖包
```zsh
conda create --name fomalhaut python=3.13
echo "conda activate fomalhaut" >> ~/.zshrc
```

重启终端

```zsh
pip install numpy matplotlib pandas seaborn scikit-learn transformers scipy jupyterlab
pip install torch torchvision torchaudio

# 注意 opencv 已经弃用，应该安装 opencv-python
pip install opencv-python 
pip install nltk
```

[Pytorch Installation](https://pytorch.org/get-started/locally/)



## 配置 Hugging-Face 镜像
```zsh
echo 'export HF_ENDPOINT="https://hf-mirror.com"' >> ~/.zshrc
echo 'export HF_HUB_DOWNLOAD_ENDPOINT="https://hf-mirror.com"' >> ~/.zshrc
```





# 配置 Github
## 配置 SSH
```zsh
ssh-keygen -t ed25519 -C "temp_project"
cat id_ed25519.pub
```

复制公钥，添加到 GitHub 帐户的 SSH Key 列表中（路径：Settings -> SSH and GPG keys）

检查与 Github 的 SSH 连接
```zsh
ssh -T git@github.com
```

在结束项目开发后，记得去 Github 设置里删除这个临时密钥



## 配置 .gitignore
### 配置 .gitignore_global
创建并打开 `.gitignore_global`
```zsh
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
```zsh
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
```zsh
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
```