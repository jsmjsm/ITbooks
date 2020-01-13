#!/bin/bash

## 设置必要的全局变量
# 标题文件、曲目文件、临时文件
menu_choice=""
current_cd=""
title_file="title.cdb"
tracks_file="tracks.cdb"
temp_file=/tep/cdb.$$
# 设置 Ctrl+C 中断处理
trap 'rm -f $temp_file' EXIT

## 两个简单的工具型函数
# 获取返回
get_return(){
    echo -e "Press return \c"
    read x
    return 0
}
# 获取确定
get_confirm(){
    echo -e "Are you sure? \c"
    while true #循环
    do
        read x #获取输入
        # case 处理
        case "$x" in
            # 确定
            y | yes | Y | Yes | YES )
                # 确定，返回 0
                return 0;;
            # 取消
            n | no  | N | No  | NO )
                echo
                echo "Cancelled"
                # 取消，返回 1
                return 1;;
            # 无关回答
            *) echo "Please enter yes or no";;
        esac
    done
}

# 主菜单设计
set_menu_choice(){
    clear # 请空屏幕
    echo "Options :- "
    echo
    echo "  a) Add new CD"
    echo "  b) Find CD"
    echo "  c) Count the CDs and tracks in the catalog"
    if [ "$cdcatnum" != "" ]; then
        echo "  l) List tracks on $cdtitle"
        echo "  r) Remove $cdtitle"
        echo "  u) Update trck information for $cdtitle"
    fi
    echo "q) Quit"
    echo
    echo -e "Please enter choice then press return \c"
    read menu_choice
    return
}

# 向数据库插入内容 title 或 track。
## 插入title
insert_title(){
    echo $* >> $title_file
    return
}
## 插入track
insert_track(){
    echo $* >> $tracks_file
    return
}

## 添加album里面的tack
add_record_tracks(){
    echo "Enter track information for this CD"
    echo "When no more tracks enter q"
    # 初始化
    cdtrack=1
    cdtitle=""
    # 输入信息
    while [ "$cdtitle" != "q" ]
    do
        # 获取title
        echo -e "Track $cdtrack, track title? \c"
        read tmp
        cdtitle=${tmp%%,*} # cdtitle 是 tmp 去掉逗号之后的内容
        # 出现逗号的错误处理
        if [ "$tmp" != "$cdtitle" ]; then
            echo "Sorry, no commas allowed"
            continue
        fi
        # 插入内容
        if [ -n "$cdtitle" ]; then
            if [ "$cdtitle != q" ]; then
                insert_track $cdcatnum,$cdtrack,$cdtitle
            fi
        else
            # 数量
            cdtrack=$((cdtrack-1))
        fi
        cdtrack=$((cdtrack+1))
    done
}

# 添加新 CD
add_record(){
    #Prompt for the initial information
    echo -e "Enter catalog name \c"
    read tmp
    cdcatnum=${tmp%%,*}

    echo -e "Enter title \c"
    read tmp
    cdtitle=${tmp%%,*}

    echo -e "Enter type \c"
    read tmp
    cdtype=${tmp%%,*}


    echo -e "Enter artist/composer \c"
    read tmp
    cdac=${tmp%%,*}

    # Check that they want to enter the information
    echo About to add new entry
    echo "$cdcatnum $cdtitle $cdtype $cdac"

    # If confirmed then append it to the title file

    if get_confirm ; then
        insert_title $cdcatnu,$cdtitle,$cdtype,$cdac
        add_record_tracks
    else
        remove_records
    fi

    return
}

# 查找 cd
find_cd(){

    if [ "$1" = "n"]; then
        asklist=n
    else
        asklist=y
    fi
    cdcatnum=""
    ## 输入搜索关键字
    echo -e "Enter a string to search for in the CD titles \c"
    read searchstr
    if [ "$searchstr" = "" ]; then
        return 0
    fi

    ## 搜索，输出内容放进temp_file
    grep "searchstr" $title_file > $temp_file

    ## wc, the word count command
    ## 提取第一个参数，并赋值给linesfound
    set ${wc -l $temp_file}
    linesfound=$1

    case "$linesfound" in
        0)  echo "Sorry, nothing found"
            get_return
            return 0
            ;;
        1)  ;;
        2)  echo "Sorry, not unique"
            echo "Found the fllowing"
            cat $temp_file
            get_return
            return 0
    esac

    ## 修改 IFS,读取以逗号为分隔符的数据字段
    IFS=","
    read cdcatnum cdtitle cdtype cdac < $temp_file
    IFS=" "

    # 查找失败
    if [ -z "$cdcatnum"  ]; then
        echo "Sorry, could not extract catalog field from $temp_file"
        get_return
        return 0
    fi

    # 格式化输出
    echo
    echo Catalog number: $cdcatnum
    echo Title: $cdtitle
    echo Type: $cdtype
    echo Artist/Composer: $cdac
    echo
    get_return

    # 输出 track 列表
    if [ "$asklist" = "y" ]; then
        echo -e "View tracks for the CD? \c"
            read x
        if [ "$x" = "$y" ]; then
            echo
            list_tracks
            echo
        fi
    fi
    return 1
}

# 更新 cd 信息
update_cd(){
    ## 当值为空
    if [ -z "$cdcatnum" ]; then
        echo "You must select a CD first"
        find_cd n
    fi
    ## 当值不为空
    if [ -n "$cdcatnum" ]; then
        echo "Current tracks are: -"
        list_tracks
        echo
        echo "This will re-renter the tracks for $cdtitle"
        get_confirm && {
            grep -v "^${cdcatnum}," $tracks_file > $temp_file
            mv $temp_file $tracks_file
            echo
            add_record_tracks
        }
    fi
    return
}
























