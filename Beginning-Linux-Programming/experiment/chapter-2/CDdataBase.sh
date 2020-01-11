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
