# CD数据库
## 需求
- 保存每张CD的基本资料
- 保存CD的曲目信息
- 对资料库进行输入、更新、删除

## 设计
1. 使用文本文件存储数据
2. 把标题信息和曲目信息分开，用不同的文件保存它们
3. CD 和 曲目，通过目录编号进行关联
4. 利用逗号分离数据项

```
 -> CD唱片保存的信息 <-
 CD 的目录编号
 标题
 曲目类型
 作者
 
 --> 曲目保存的信息 <--
 曲目编号
 曲名
```

## 需要的函数
```shell
get_return()
get_confirm()

set_menu_choice()

insert_title() 
insert_track()

add_record_tracks()
add_records()

find_cd() # 查找cd
update_cd() # 更新cd

count_cds() # 统计cd数目
remove_records() # 移除cd
list_tracks()
```

### 查找cd
#### 利用 grep 
`grep` 会输出关键字所在的行
将grep的输出，存储到一个临时文件，每一次匹配占有一行，然后统计行数。
#### 利用 wc
`${wc -l $temp_file}` 用 wc 统计行数，并且去指向第一个搜索结果

#### 利用 IFS
IFS (Internal Field Separator) 
更改 IFS，成为一个`,`去分割

### 更新cd信息
搜索的行是以 $cdcatnum 开头的（用标志 ^），并且后面跟着一个逗号