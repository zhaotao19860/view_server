#!/bin/bash
# Created by zhaotao on 2020/1/6

init(){
    SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
    chmod a+x ${SHELL_FOLDER}/cgi-bin/*
    #数据更新脚本，没有源数据可以不更新；
    #sh ${SHELL_FOLDER}/data/update.sh
    #将所有者改为nobody，因为server需要读写此目录
    chown -R nobody:nobody ${SHELL_FOLDER}/data/tmp
    sh ${SHELL_FOLDER}/systemctl/service.sh
}

start(){
    systemctl start view_server
    systemctl status view_server
}

main(){
    init
    start
}

main $@