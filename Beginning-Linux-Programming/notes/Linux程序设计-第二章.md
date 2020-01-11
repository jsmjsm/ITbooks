# Linux程序设计-第二章.md

## 2.2 一点Unix的哲学
`ls -al | more`   
使用 ls 和 more 工具并通过管道实现文件列表的分屏显示

`   man bash | col -b | lpr`  
打印 bash使用手册的参考副本

想让工具执行得更快：现在 shell 中实现原型，再用更快的语言去实现它们。

## 2.3 什么是shell
``A shell is a program that acts as the interface between you and the Linux system, enabling you to enter commands for the operating system to execute.``  
shell 是一个作为用户和 Linux系统间的接口程序。它允许用户向操作系统输入需要执行得命令

`<>` 对输入和输出进行重新定向
` | ` 在同时执行的程序之间实现数据的管道传输
`$(...)` 获取子进程的输出

`/bin/bash --version` 查看bash的版本号

## 2.4 Pipe and Redirection | 管道和重新定向   
### 2.4.1 Redirecting output 重定向输出
文件描述符号： 0 - 标准输入；1 - 标准输出；2 - 标准错误输出

`$ ls -l > lsoutput.txt` 把 ls 命令的输出保存到 lsoutput.txt 这个文件里面
通过 `>` 把标准输出重新定向到一个文件（会覆盖原有内容）
`>>` 将输出内容附加到指定文件的尾部

#### 对标准错误输入进行重新定向：
把想要重新定向的文件描述符号加在`>`前面  
*例子：*  
    **想要丢弃错误信息并且阻止它在屏幕上显示**：用 `2>`  
    
    //假定我要kill一个进程  
    //IF 在我kill之前，进程已经结束了，那么执行kill的时候，kill命令将向 标准错误输出 写一条错误信息  
    //S.T. 可以阻止kill命令向屏幕写任何内容  
    $ kill -HUP 1234 > killout.txt 2>killerr.txt    //将标准输出和标准错误输出分别重新定向到两个不同的文件  
    $ kill -1 1234 >killouterr.txt 2>&1             //用 `>&` 将两组输出都重新定向到一个文件
    $ kill -1 1234 >/dev/null 2>&1                  //丢弃所有输出信息到回收站

### 2.4.2 Redirecting Input 重新定向输入  
*例子*: `more < killout.txt`  

### 2.4.3 Pipes 管道  
You can connect processes using the pipe operator `|`.  
你可以用管道操作符 `|` 来连接进程。  

In Linux, process connected by pipes can run simultaneously and are automatically resheculed as data flows between them.  
在Linux下通过管道连接的进程可以同时运行，并且随着数据流在他们之间的传递可以自动地进行协调。  

例子：
``` shell
    // 不使用管道:
    $ ps > psout.txt 
    $ sort psout.txt > pssort.out

    // 使用管道
    $ ps | sort > passort.out

    // 继续使用管道连接
    $ ps -xo comm | sort | uniq | grep -vsh | more
    // 1. 按字母排序 排序 ps命令的输出
    // 2. 用 uniq 命令去除名字相同的进程
    // 3. 用 grep -vsh 删除名为sh的进程
    // 4. 将结果分页显示在屏幕上
```

**绝对不要在命令流中重复使用相同的文件名**

## 2.5 The Shell as a Programming Language 作为程序设计语言的Shell
编写shell脚本有两种方式：
1. 输入一系列命令让交互的执行
2. 把命令保存到一个文件中，作为一个程序来调

### 2.5.1 Interactive Programs 交互式程序
*例子：从大量C语言源文件中查找包含字符串POSIX的文件*
```shell
$ for file in *
> do
> if grep -1 POSIX $file    \\grep 输出他找到的包含 POSIX 字符串的文件
> then                      
> more $file                \\more 命令将文件内容显示在屏幕上
> fi
> done                      \\返回shell提示符
```

shell支持通配符拓展：  
`* 匹配字符串`；`? 匹配单个字符`；`[set] 匹配方括号中任意一个单字符`；`[^set] 取反`；`{str1,str2}匹配字符串`

### 2.5.2 Creating a Script 创建脚本
 *脚本范例：*
 ```shell
#! /bin/sh

# first
# This file looks through all the files in the current
# directory for the string POSIX, and then prints the names of
# those files to the standard output.

for file in * 
do 
    if grep -q POSIX $file
    then
        echo $file
    fi
done

exit 0
 ```

`#!/bin/sh` 是一种特殊形式的注释：`#!`告诉系统，后面跟着的参数`/bin/sh`是用来执行文件的程序。
注释中用的是绝对路径。

因为脚本程序本质上可以被看作是shell的标准输入，所以它可以包含任何通过你的PATH环境变量引用到Linux的命令。

退出码：0表示成功

脚本文件没有任何的拓展名或者后缀，用`.sh`也可以

### 2.5.3 Making a Script Executable 把脚本设为可执行
#### 调用脚本的两种方法
1. 调用shell，并把脚本文件名作为一个参数：  
例子：
`$ bin/sh first`  
In this way,只要输入脚本的名字就可以调用了
如果运行是报错，需要把当前目录设置成Shell的PATH环境变量要查找执行命令的对象

2. （推荐）在保存脚本的目录输入`./first`：
把脚本程序的完整相对路径告诉shell  
**能够保证shell不会意外之行系统中的同名程序！**

---
完成后的脚本要移动到哪里？  
- 自己用：在自己的home目录创建一个bin目录，并且将这个目录添加到PATH变量
- 让他人也能用：`/usr/local/bin`或者其他合适的位置

防止其他用户修改脚本程序：  
*去掉脚本程序的写权限:*
```shell
# cp first /usr/local/bin 
# chown root /usr/local/bin/first 
# chgrp root /usr/local/bin/first 
# chmod 755 /usr/local/bin/first
```

执行脚本时提示权限不足：  
`chmod 777 ./first`
## 2.6 Shell Syntax Shell的语法  
本部分内容：  
- Variables: strings, numbers, environments, and parameters
- Conditions: shell Booleans
- Program control: if, elif, for, while, until, case
- Lists 命令列表
- Functions
- Commands built into the shell ｜ shell内置命令
- Getting the result of a command ｜ 获取命令执行的结果
- Here documents

### 2.6.1 Variables 变量
- 使用变量之前不需要声明。
- 变量类型默认是字符串string。
- shell和一些工具在需要时会自动转换。  
- 访问变量的内容： 在变量前加 `$`  
- 为变量赋值时，只需要使用变量名。
- 输出变量内容：`echo $variable`

⚠️：字符串里面有空格，就需要用`" "`  
⚠️：`=`两边不能有空格

用户输入内容： `read varbianle`
*例子：*
```shell
$ read mood     \\变量名为mood，等待用户输入
depressed       \\用户输入
$ echo $mood    \\eaco + $ + 变量名。输入变量内容
depressed       \\输出变量值
```

#### 1 - Quoting 使用引号
一般情况下，脚本文件的参数用空白字符分割  
在一个参数中包含一个或多个空白字符，就要用`" "`
字符串放在`" "`中  

The behavior of variables such as `$foo` inside quotes depends on the type of quotes you use.  
If you enclose a $ variable expression in double quotes`" "`, then it’s replaced with its value when the line is executed.  
If you enclose it in single quotes`' '`, then no substitution takes place.  
You can also remove the special meaning of the $ symbol by prefacing it with a `\`.  
像 `$foo`这样的变量在引号中的行为取决于引号的类型  
`" "`: 会把变量替换为 `$foo` 的值  
`' '`: 不发生替换  
`\`： 反义符号，取消`$`的特殊含义  

*实例：*
[源代码](https://raw.githubusercontent.com/jsmjsm/ITbooks/master/Beginning-Linux-Programming/practise/chapter-2/tryVariables)  
```shell
#!/bin/sh

myvar=”Hi there”

echo $myvar
echo “$myvar”
echo ‘$myvar’
echo \$myvar

echo Enter some text
read myvar

echo ‘$myvar’ now equals $myvar

exit 0
```

输出内容： 
```shell
$ ./variable 
Hi there 
Hi there 
$myvar 
$myvar
Enter some text 
Hello World 
$myvar now equals Hello World
```

#### 2 - 环境变量
When a shell script starts, some variables are initialized from values in the environment.
当一个shell脚本程序开始执行时，一些变量会根据环境设置中的值进行初始化。

环境变量通常大写。  

*主要的环境变量：*
```
Environment Variable ｜ Description  
-------------------- ｜ -----------  
$HOME | The home directory of the current user  
$PATH | A colon-separated list of directories to search for commands
$PS1  | A command prompt, frequently $, but in bash you can use some more complex values; 
        for example, the string [\u@\h \W]$ is a popular default that tells you the user, machine name, and current directory, as well as providing a $ prompt.
$PS2  | A secondary prompt, used when prompting for additional input; usually >.
$IFS  | An input field separator. This is a list of characters that are used to separate words when the shell is reading input, usually space, tab, and newline characters. 
$0    | The name of the shell script
$#    | The number of parameters passed
$$   | The process ID of the shell script, often used inside a script for generating unique temporary filenames; for example /tmp/tmpfile_$$
```

#### 3 - 参数变量
If your script is invoked with parameters, some additional variables are created.  
如果脚本程序在调用的时候带有参数，一些额外的变量就会被创建。  
```
Parameter Variable｜Description
------------------｜-----------  
$1, $2, … ｜The parameters given to the script
$*        ｜If your script is invoked with parameters, some additional variables are created. 
            A list of all the parameters, in a single variable, separated by the first character in the environment variable IFS.
            If IFS is modified, then the way $* separates the command line into parameters will change.

$@        ｜A subtle variation on $*; it doesn’t use the IFS environment variable, so parameters are not run together even if IFS is empty.

```

访问脚本程序的参数 用`@$`

### 2.6.2 Conditions 条件
所有程序设计语言的基础是对条件进行测试判断，并根据测试结果采取不同的行动能力。 
一个 shell 脚本能够对任何可以从 commandline 上调用的命令的退出码进行测试。

#### test 或 [ 命令
布尔判断值命令  
`if test -f fred.c`  
`if [ -f fred.c `  
两者是等价的。  

可以使用的条件类型：string, 算术比较，文件相关  

### 2.6.3 Control Structure 控制结构   
#### 1 - if
```shell
if ...
then ...
else ...
```
#### 2 - elif
类似else if
```shell
if ...
then ...
elif ...
then...
else
```
#### 4 - for
```shell
for ... in ...；
do ...
done
```
#### 5 - while 
```shell
while ...; do ...
done
```

example: a rather poor password-checking program: 
```shell
#！/bin/sh

echo "Enter Password"
read trythis

while ["$trythis != "secret"]; do
    echo "Sorry, try again."
    read trythis
done 
exit 0
```
#### 6 - until 
```shell
until...
do ...
done ...
```
#### 7 - case
case construct enables you to match the contents of a variable asaginst patterns in quite sophisticated way and allows execution of diffrent statements, depending on which pattern was matched.  
case 结构允许你通过一种比较复杂的方式将变量和模式进行匹配，然后根据匹配的模式去执行代码。  
```
case variable in 
 pattern [ | pattern] ...) statements;;
 pattern [ | pattern] ...) statements;;
esac
```
⚠️：每个模式后面都用`；；`结尾。
#### 8 - list 
Sometimes,you want to connect cmmmands in a series. For instance, you want serval diffrent conditions to be met before you excuute a statement.
用list来解决多个if的问题。  
有AND list 和 OR list  
AND: `&&`
OR `||`
#### 9 - Statement Blicks
`{...}`

### 2.6.4 Functions 函数
就是函数啦
语法： 
```shell
    function_name (){
        statements
    }
```
Note that you can declare local variables within shell functions by using the `local ` keyword.
可以用 `local` 关键字创建局部变量
OTHERWISE the function can access the other shell variables that are essentially global in scope 
否则函数就可以访问其他全局变量 
local variable can overlay the global variable (same name)
局部变量可以覆盖同名全局变量

### 2.6.5 Commands 命令
linux 命令分为外部命令和内部命令两类，内部命令执行效率更高  
#### 1 - break
可以跳出一层循环
#### 2 - :
冒号 `:` 命令是一个空命令
偶尔用于简化条件逻辑 
比true快
`while : ` <=> `while true`
#### 3 - continue
跟c里面的continue类似，跳到下一次循环继续进行
#### 4 - .
点 `.` 命令用于在当前shell中执行命令
通常，一个脚本在执行一条外部命令或脚本程序的时候，他会创建一个子 shell ，命令在子 shell 中执行，执行完毕后，子 shell 被丢弃，退出码返回给父shell
可以和c的 `#include` 类比
#### 5 - echo 
echo 命令输出结尾带有换行符的字符串

去掉换行符的方法
`echo -n "xxxxx"`
或者
`echo -e "xxxxx\c"`
\c -> 换行符；
\t -> 制表符
\n -> 回车

用外部命令tr也可以删除换行符，只不过比较慢
Unix系统用`prinitf` 比较好

#### 6 - eval
eval 允许你对参数进行求值 
#### 7 - exec
有两种用法：
1. 将当前shell 替换为一个不同的程序。exec命令后面的代码都不会执行了
2. 修改当前文件描述符

#### 8 - exit n
以退出码 n 退出程序
0 表示成功退出
1～125 都是脚本程序可以用的错误代码。
这些是保留含义的错误代码：
- 127 The file was not executable
- 128 A command was not found
- 128 and above A signal occurred

#### 9 - export 
The export command makes the variable named as its parameter available in subshells. 
export 命令将作为他的参数的变量导出到 子shell 中，并使他在 子shell 中有效。

By default, variables created in a shell are not available in further (sub)shells invoked from that shell.
默认状态下，一个 shell 中被创建的变量在他的 子shell 中是不可用的。

export是被导出的变量变成 子shell 的环境变量

💡`set -a` 或 `set -allexport`  命令将导出它声明之后的所有变量

#### 10 - expr
The expr command evaluates its arguments as an expression. 
expr 命令将他的参数当作一个表达式来求值  
它可以完成许多表达式的求职运算 

#### 11 - printf 
语法
`printf "format string" parameter1 parameter2 `

#### 12 - return 
就是 return

#### 13 - set
The set command sets the parameter variables for the shell.  
用 `set` 来设置参数变量  
`set -x` 让脚本程序跟踪显示它当前执行的命令  

#### 14 - shift
把所有参数变量左移一个位置。
`$1` 被丢弃，但是`$0` 被保留
可以`shift 指定数值距离`

可以借助 `shift` 来扫描所有位置参数
```shell
while [ "$1" != "" ]; do
    echo "$1"
    shift
done
```

#### 15 - trap 
The trap command is used to specify the actions to take on receipt of signals
trap 用于指定收到特定信号后的动作。  
格式：`trap command signal`

trap 常用于脚本程序被中断时完成的清理工作。


- to reset a trap condition to the defaul:
重置处理方式：  `trap - signal`
- to ignore a signal:
忽略掉某个信号 `trap '' signal`

#### 16 - unset 
从环境变量中删除变量或函数

#### 17 - find 
语法: `find [path] [options] [filename] [actions]`
例子：
`find . -newer TESE -type f -print`  
`find . \( -newer TEST -or -name "_*" \) -type f -ls`

#### 18 - grep
正则匹配
General Regular Expression Parser = grep
语法：`grep [options] PATTERN [FILES]`

用 find 搜索文件； 用 grep 搜索文件中的字符串
💡 常用用法： 在使用 `find` 时, 通过 `-exec`传递结果给 `grep` 

例子：
`grep bin in TEST` 
`gerp -c bin TEST1 TEST2`  
`gerp -c -v bin TEST1 TEST2` 

正则表达式在此不赘述。

### 2.6.6 Command Execution 命令的执行
执行一条命令，并且把命令的输出放在一个变量里。  
通过 `set` 命令中的 `$(command)`可以实现。  
例子：  
`echo The current users are $(who)`  
`echo The current directory is $PWD`  
  
赋值： `variableName = $(command)`  

#### 1 - Arithmetic Expansion 算术拓展
`expr` 命令比较慢
更好的处理办法：利用 `$((...))` 进行算术拓展（算术替换）  
例子：`x=$(($x+1))`  

#### 2 - Parameter Expansion 参数拓展
在变量后面附加额外的字符会遇到错误。  
例如 `$i_tmp`  
解决方法 `$(i)_tmp` 把参数的值替换了一个字符
**常用参数拓展**

| 命令                | 作用                       |
|-------------------|--------------------------|
| `${param:-default}` | 如果param为空，则把它设置为default值 |
| `${#param}`         | param的长度                 |
| `${param%word}`     | 从头开始，删除最短匹配word          |
| `${param%%word}`    | 从头开始，删除最长匹配word          |
| `${param#word}`     | 从尾开始，删除最短匹配word          |
| `${param##word}`    | 从尾开始，删除最长匹配word          |

实例：利用 cjpeg 将文件夹下的gif转换成jpg
```shell
for image in  *.gif
do 
    # 利用 cjpeg，并且修改输出文件的后缀为jpg
    cjpeg $image > ${image%%gif}jpg
done
```
### 2.6.7 Here Document Here 文档
