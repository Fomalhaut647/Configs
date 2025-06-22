# 揭秘 Linux Shell 脚本执行：`source` 与 `sh` 的终极对决

你好，Linux 探索者！

你是否曾好奇，为什么有些脚本需要用 `source` 来执行，而另一些则用 `sh` 或 `./`？为什么脚本里 `cd` 命令有时“管用”，有时又“失灵”？

这篇教程将为你彻底揭开这些谜团。理解这些核心概念，将让你的 Linux 命令行技能提升一个档次！

## 基础概念：分清“终端”与“Shell”

在开始之前，我们先要理清两个最基本的概念：

- **终端 (Terminal)**：你看到的那个黑色（或白色）的**窗口**程序。它是一个图形软件，为你提供一个与 Shell 交互的界面。
- **Shell (外壳)**：真正**解释和执行**你命令的程序，它运行在终端窗口之中。最常见的 Shell 就是 `Bash` (`/bin/bash`)。

**简单比喻：** 终端是“对话框”，而 Shell 是坐在对话框另一头的“命令翻译官”。

## 核心机制：父 Shell 与子 Shell 的故事

这是理解一切的关键！

当你打开一个终端时，你就启动了一个 **父 Shell (Parent Shell)** 进程。

当你以“直接执行”的方式运行一个脚本时（例如 `sh my_script.sh` 或 `./my_script.sh`），Linux 会为你创建一个全新的、临时的 Shell 进程，我们称之为 **子 Shell (Subshell)**。

- **子 Shell** 是一个独立的世界，它从父 Shell 那里“出生”。
- 脚本里的所有命令都在这个独立的子 Shell 世界里运行。
- **脚本运行结束后，这个子 Shell 世界就会立刻消失。**

现在，让我们看看两种不同的执行方式如何与这个机制互动。

---

## 方法一：直接执行 (`sh script.sh` 或 `./script.sh`)

这种方式会为脚本创建一个隔离的 **子 Shell** 环境。

- **工作方式**：父 Shell 创建一个子 Shell -> 子 Shell 执行脚本中的所有命令 -> 子 Shell 消失 -> 控制权交还给父 Shell。
- **关键特性**：**隔离性**。子 Shell 中发生的任何环境变化（如切换目录、定义变量），都不会影响到它的父 Shell。

### 示例 1：无法改变父 Shell 的目录

1.  创建一个名为 `test_cd.sh` 的脚本：

    ```bash
    #!/bin/bash
    echo "--- 我是子 Shell ---"
    echo "脚本开始时，我在: $(pwd)"
    cd /tmp
    echo "我切换到了: $(pwd)"
    echo "--- 子 Shell 结束 ---"
    ```

2.  给它执行权限：`chmod +x test_cd.sh`

3.  在你的主目录（或任意位置）执行它：

    ```bash
    # 1. 查看当前终端（父 Shell）的目录
    $ pwd
    /home/user

    # 2. 直接执行脚本
    $ ./test_cd.sh
    --- 我是子 Shell ---
    脚本开始时，我在: /home/user
    我切换到了: /tmp
    --- 子 Shell 结束 ---

    # 3. 再次查看当前终端（父 Shell）的目录
    $ pwd
    /home/user  # <-- 看到没？父 Shell 的位置完全没变！
    ```

**结论：** 子 Shell 的 `cd` 操作，随着子 Shell 的消失而失效，无法影响父 Shell。

---

## 方法二：`source` 执行 (`source script.sh` 或 `. script.sh`)

`source` (或者它的简写形式一个点 `.`) 命令则完全不同。

- **工作方式**：**不创建新的子 Shell**。它会逐行读取脚本里的命令，并直接在**当前的 Shell** 中执行。
- **关键特性**：**融合性**。所有在脚本中执行的命令，都如同你亲手在当前终端里敲入一样，会直接改变当前 Shell 的环境。

### 示例 2：用 `source` 改变当前 Shell 的目录

我们还是用上面的 `test_cd.sh` 脚本。

```bash
# 1. 查看当前终端（父 Shell）的目录
$ pwd
/home/user

# 2. 使用 source 执行脚本
$ source ./test_cd.sh
--- 我是子 Shell ---
脚本开始时，我在: /home/user
我切换到了: /tmp
--- 子 Shell 结束 ---

# 3. 再次查看当前终端（父 Shell）的目录
$ pwd
/tmp  # <-- 注意！父 Shell 的目录被成功改变了！
````

**结论：** `source` 让脚本和当前 Shell “合体”，脚本对环境的修改会永久保留下来（直到你关闭终端）。

**常见应用：**

  - 激活 Python/Node.js 等虚拟环境的 `activate` 脚本。
  - 加载配置文件，如 `source ~/.bashrc`。
  - 设置临时的环境变量，让它们在当前终端中生效。

-----

## `export` 的秘密：变量的“通行证”

现在你可能会问，既然子 Shell 是隔离的，那父 Shell 如何向子 Shell 传递信息呢？答案就是 `export`。

  - **局部变量 (Local Variable)**：默认创建的变量，只在当前 Shell 内有效。它像是你的“私有笔记”，不会给子 Shell看。
    ```bash
    my_local_var="私有笔记"
    ```
  - **环境变量 (Environment Variable)**：使用 `export` 创建的变量。它会被所有从当前 Shell “出生”的子 Shell 所继承。它像是“家规”，所有孩子都要遵守。
    ```bash
    export my_exported_var="传给孩子的家规"
    ```

### 示例 3：变量的传递

1.  创建脚本 `test_vars.sh`：
    ```bash
    #!/bin/bash
    echo "在子 Shell 中："
    echo "接收到的私有笔记: $my_local_var"
    echo "接收到的家规: $my_exported_var"
    ```
2.  在父 Shell 中定义变量并执行脚本：
    ```bash
    $ my_local_var="这是父 Shell 的秘密"
    $ export my_exported_var="请遵守这条规则"

    $ sh test_vars.sh
    在子 Shell 中：
    接收到的私有笔记:          # <-- 空的！子 Shell 没收到
    接收到的家规: 请遵守这条规则 # <-- 成功收到！
    ```

-----

## 总结：一张图看懂所有

| 特性             | 直接执行 (`./script.sh`)      | `source` 执行 (`source script.sh`) |
| ---------------- | ------------------------------ | --------------------------------- |
| **执行环境** | 创建一个临时的**子 Shell** | 在**当前 Shell** 中执行           |
| **对当前Shell影响** | **无影响**，环境被隔离       | **有影响**，会改变当前环境        |
| **变量传递** | 只继承 `export` 过的环境变量 | 共享所有变量（因为是同一个Shell） |
| **核心比喻** | 派一个“克隆人”去执行任务     | “亲自动手”完成任务清单            |
| **常用场景** | 运行独立的、自包含的程序     | 加载配置、激活环境、设置变量      |

希望这篇教程能帮你理清思路！下次再遇到 Shell 脚本时，你就能自信地判断出应该使用哪种方式来执行它了。