# 这是一个安装 Ubunut Server 的指南
前面一部分忘记记录了，从 Storage Configuration 开始吧（）

印象里前面除了选择镜像源的时候，可以使用北大镜像源 `https://mirrors.pku.edu.cn/ubuntu/` 其他的都保持默认即可
> 使用上下左右方向键移动，使用空格或回车选择或取消选择

## Storage Configuration
保持默认



## Profile Configuration
- **Your name**：昵称，不重要，可以和 `username` 相同

- **Server's name**：服务器本身的名字，比如我的服务器装在我的台式机上，所以命名为 `desktop`

- **Username**：用户名，不要用大写，我使用我的英文名 `fomalhaut`。登录服务器时需要以某个用户的身份登录，在服务器上执行命令时也是以某个用户的身份执行

- **Password**：随意，反正用 SSH 登录



## Upgrade to Ubuntu Pro
这是为企业用户提供的，跳过即可



## SSH Configuration
启用 `Install OpenSSH server`

选择从 Github 导入
> Launchpad 是资深 Ubuntu 开发者用的，不用管 \
> 如果从 Github 导入失败，先跳过，等安装完成之后使用 `ip addr show` 查看 IP 地址，然后手动 SSH 连接



## Featured Server Snaps
保持默认，跳过



## Installing System
安装系统。静静等待完成即可，完成后会自动进入下一步



## Updating System
更新系统。静静等待完成即可，完成后会自动进入下一步



## Installation Complete!
安装成功。选择 `Reboot` 以重启



## 进入系统
如果重启后一切正常，会进入一个命令行界面，屏幕上会显示一些基础信息
```bash
Ubuntu 24.04.2 LTS desktop tty1
...
desktop login:
...
cloud-init
...
SSH HOST KEY FINGERPRINTS
...
```

此时按下回车，会得到一个登录提示
```bash
desktop login:
```

输入之前设置的用户名并回车，然后会提示输入密码
```bash
Password:
```
> 输入密码的时候不会显示出来，所以在回车之前没反应是正常的

如果一切正常，应该会输出欢迎
```bash
Welcome to Ubuntu 24.04.2 LTS ...
```

以及命令提示符
```bash
your_username@desktop:~$ _
```



## 基础设置
参考服务器配置指南



## 使用校园网
如果需要在北大校内使用校园网访问校外网站，必须连接[网关](https://its.pku.edu.cn/download_ipgwclient.jsp)

在终端输入以下指令即可连接网关
> username 的参数替换为你的校园卡号，password 的参数替换为你的北大账号密码

```bash
curl -X POST  -d 'cmd=open&username=your_student_id&password=your_password&iprange=free' https://its4.pku.edu.cn/cas/ITSClient
```
> 如需断开链接，请将open改为disconnect