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




















