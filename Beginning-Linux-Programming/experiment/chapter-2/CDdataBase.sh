#!/bin/bash

## 设置必要的全局变量
# 标题文件、曲目文件、临时文件
menu_choice=""
current_cd=""
title_file="title.cdb"
tracks_file="tracks.cdb"
temp_file=/tmp/cdb.$$
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
    echo "  f) Find CD"
    echo "  c) Count the CDs and tracks in the catalog"
    if [ "$cdcatnum" != "" ]; then
        echo "  l) List tracks on $cdtitle"
        echo "  r) Remove $cdtitle"
        echo "  u) Update trck information for $cdtitle"
    fi
    echo "  q) Quit"
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
            if [ "$cdtitle" != "q" ]; then
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
add_records(){
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
        insert_title $cdcatnum,$cdtitle,$cdtype,$cdac
        add_record_tracks
    else
        remove_records
    fi

    return
}

# 查找 cd
find_cd(){

    if [ "$1" = "n" ]; then
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
    grep "$searchstr" $title_file > $temp_file
    #echo "***********************************"
    ## wc, the word count command
    ## 提取第一个参数，并赋值给linesfound
    set $(wc -l $temp_file)
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
        echo "Current tracks are just showed"
        list_tracks
        echo
        echo "This will re-renter the tracks for $cdtitle"
        get_confirm && {
            grep -v “^${cdcatnum},” $tracks_file > $temp_file
            mv $temp_file $tracks_file
            echo
            add_record_tracks
        }
    fi
    return
}

# 统计内容
count_cds(){
    set $(wc -l $title_file)
    num_titles=$1
    set $(wc -l $tracks_file)
    num_tracks=$1
    echo found $num_titles CDs, with a total $num_tracks tracks
    get_return
    return
}

# 删除记录
remove_records(){
    if [ -z "cdcatnum" ]; then
        echo You must select a CD first
        find_cd
    fi
    if [ -n "$cdcatnum" ]; then
        echo "You are about to delete $cdtitle"
        get_confirm && {
            grep -v "^${cdcatnum}," $title_file > $temp_file
            mv $temp_file $title_file
            grep -v "^${cdcatnum}," $tracks_file > $temp_file
            mv $temp_file $tracks_file
            cdcatnum=""
            echo Entry removed
        }
        get_return
    fi
    return
}

# 显示tracks
list_tracks(){
    if [ "$cdcatnum" = "" ]; then
        echo no CD select yet
        return
    else
        grep "^${cdcatnum}," $tracks_file > $temp_file
        num_tracks=$(wc -l $temp_file) # 统计行数
        if [ "$num_tracks" = "0" ]; then
            echo no tracks found for $cdtitle
        else {
            echo
            echo "$cdtitle :-"
            echo
            cut -f 2- -d , $temp_file
            echo
        } | ${PAGER:-more} # 通过more来实现页面输出
        fi
    fi
    get_return
    return
}

# 主程序
rm -f $temp_file
if [ ! -f $title_file ]; then
     touch $title_file
fi
if [ ! -f $tracks_file ]; then
    touch $tracks_file
fi

## Now the application proper
clear
echo
echo
echo "Mini CD Magager"
sleep 1

quit=n
while [ "$quit" != "y" ];
do
    set_menu_choice
    case "$menu_choice" in
        a) add_records;;
        r) remove_records;;
        f) find_cd;;
        u) update_cd;;
        c) count_cds;;
        l) list_tracks;;
        b)
           echo
           more $title_file
           echo
           get_return;;
        q | Q ) quit=y;;
        *) echo "Sorry, choice not recognized"
    esac
done

## Tidy up and leave

rm -f $temp_file
echo "Finished"
exit 0
