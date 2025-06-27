export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="jonathan"

DISABLE_MAGIC_FUNCTIONS="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(sudo
         z
         history
         copyfile
         copypath
         git
         docker
         docker-compose
         python
         zsh-completions
         zsh-autosuggestions
         zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh



alias cls='clear'



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