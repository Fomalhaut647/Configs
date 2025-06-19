## 前言
这是自用的服务器快速配置指南，用于临时租用的一次性的 Ubuntu 服务器





# 安装 cursor
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
把 .gitignore 复制到项目目录下



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