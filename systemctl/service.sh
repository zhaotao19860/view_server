#!/bin/bash
# Created by tom on 2020/1/6

init(){
    SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
}

mk_service(){
    \cp -f ${SHELL_FOLDER}/view_server.service /etc/systemd/system/
    \cp -f ${SHELL_FOLDER}/view_server_service.conf /etc/rsyslog.d/
    touch /var/log/view_server.log
    chown root:adm /var/log/view_server.log
    systemctl daemon-reload
    systemctl restart rsyslog
}

main(){
    init
    mk_service
}

main $@