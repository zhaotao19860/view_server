#!/bin/bash
# Created by tom on 2020/1/2

init(){
    SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
    VIEW_REPO="git@xxx/view_data.git"
    GIT_DIR=${SHELL_FOLDER}/view_data
    GIT_DATA_DIR=${GIT_DIR}
    TMP_DIR=${SHELL_FOLDER}/tmp
    MD5_FILE=${TMP_DIR}/md5
    VIEW_NAME_LIST_FILE=${TMP_DIR}/view_name_list
    VIEW_NAME_AUTOCOMPLETE_FILE=${TMP_DIR}/autocompleter.data.js
    MATCH_FILE=${SHELL_FOLDER}/../cgi-bin/match.py
}

get_dir_md5(){
    new_md5=`find $1 -type f -exec md5sum {} \; | sort -k 2 | md5sum|awk '{print $1}'`
    echo ${new_md5}
}
# useage: [is_dir_changed old_md5 new_md5]
is_dir_changed(){
    if [ $1 != $2 ]
    then
        return 1
    else
        return 0
    fi
}

update_git(){
    if [ -d "${GIT_DIR}" ] 
    then
        cd ${GIT_DIR}
        git pull
    else
        git clone ${VIEW_REPO} ${GIT_DIR}
    fi
}

get_view_name_list(){
    cat ${GIT_DATA_DIR}/view_name_id.map | awk '{print $3}' | sort -n > ${TMP_DIR}/father_view
    cat ${GIT_DATA_DIR}/view_name_id.map | awk '{print $1}' | sort -n > ${TMP_DIR}/all_view
    comm -2 -3 ${TMP_DIR}/all_view ${TMP_DIR}/father_view > ${VIEW_NAME_LIST_FILE}
    #将view_default替换为view_world
    sed -i -e "s/view_default/view_world/g" ${VIEW_NAME_LIST_FILE}
    #生成autocompleter.data.js用于智能提示
    echo "data = \`[" > ${VIEW_NAME_AUTOCOMPLETE_FILE}
    cat ${VIEW_NAME_LIST_FILE} | awk '{print "{ \"value\": \""$0"\", \"label\": \""$0"\" },"}' >> ${VIEW_NAME_AUTOCOMPLETE_FILE}
    sed -i -e '$s/,$//' ${VIEW_NAME_AUTOCOMPLETE_FILE}
    echo "]\`;" >> ${VIEW_NAME_AUTOCOMPLETE_FILE}
    \rm -rf ${TMP_DIR}/father_view ${TMP_DIR}/all_view
}

get_view_ipseg(){
    while IFS= read -r line
    do
        #trim leading and trailing space
        view_name=`echo ${line} | awk '{$1=$1;print}'`
        if [ ${view_name}x != "x" ]
        then
            python ${MATCH_FILE} ${view_name} >> ${TMP_DIR}/${view_name}
        fi
    done < ${VIEW_NAME_LIST_FILE}
}

reset_tmp(){
    \rm -rf ${TMP_DIR}
    mkdir -p ${TMP_DIR}
    new_md5=`get_dir_md5 ${GIT_DATA_DIR}`
    echo ${new_md5} > ${MD5_FILE}
    get_view_name_list
    get_view_ipseg
    #将所有者改为nobody，因为server需要读写此目录
    chown -R nobody:nobody ${TMP_DIR}/
}

update_tmp(){
    if [ -f "${MD5_FILE}" ] 
    then
        new_md5=`get_dir_md5 ${GIT_DATA_DIR}`
        old_md5=`cat ${MD5_FILE}`
        if is_dir_changed ${new_md5} ${old_md5}
        then
            return 0
        else
            reset_tmp
        fi
    else
        reset_tmp
    fi
}

main(){
    init
    update_git
    update_tmp
}

main $@