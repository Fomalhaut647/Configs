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
```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

重启终端，配置 `Powerlevel10k`



## 设置本地字体
可以根据需要设置本地字体（建议完成）
[MesloLGS NF](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#meslo-nerd-font-patched-for-powerlevel10k)
> 由于字体渲染在本地进行，所以字体配置应该在本地而不是服务器进行