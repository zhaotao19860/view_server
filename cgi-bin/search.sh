#!/bin/bash
# Created by zhaotao on 2020/1/2

#This code for getting code from post data is from http://oinkzwurgl.org/bash_cgi and
#was written by Phillippe Kehi <phkehi@gmx.net> and flipflip industries

# (internal) routine to store POST data
function cgi_get_POST_vars()
{
    # check content type
    #echo "CONTENT_TYPE: ${CONTENT_TYPE}" 1>&2
    # FIXME: not sure if we could handle uploads with this..
    [[ "${CONTENT_TYPE}" != *"application/x-www-form-urlencoded"* ]] && \
	echo "Warning: you should probably use MIME type "\
	     "application/x-www-form-urlencoded!" 1>&2
    # save POST variables (only first time this is called)
    [ -z "$POST_STRING" \
      -a "$REQUEST_METHOD" = "POST" -a ! -z "$CONTENT_LENGTH" ] && \
	read -n $CONTENT_LENGTH POST_STRING
    return
}

# (internal) routine to decode urlencoded strings
function cgi_decodevar()
{
    [ $# -ne 1 ] && return
    local v t h
    # replace all + with whitespace and append %%
    t="${1//+/ }%%"
    while [ ${#t} -gt 0 -a "${t}" != "%" ]; do
	v="${v}${t%%\%*}" # digest up to the first %
	t="${t#*%}"       # remove digested part
	# decode if there is anything to decode and if not at end of string
	if [ ${#t} -gt 0 -a "${t}" != "%" ]; then
	    h=${t:0:2} # save first two chars
	    t="${t:2}" # remove these
	    v="${v}"`echo -e \\\\x${h}` # convert hex to special char
	fi
    done
    # return decoded string
    echo "${v}"
    return
}

# routine to get variables from http requests
# usage: cgi_getvars method varname1 [.. varnameN]
# method is either GET or POST or BOTH
# the magic varible name ALL gets everything
function cgi_getvars()
{
    [ $# -lt 2 ] && return
    local q p k v s
    # get query
    case $1 in
	GET)
	    [ ! -z "${QUERY_STRING}" ] && q="${QUERY_STRING}&"
	    ;;
	POST)
	    cgi_get_POST_vars
	    [ ! -z "${POST_STRING}" ] && q="${POST_STRING}&"
	    ;;
	BOTH)
	    [ ! -z "${QUERY_STRING}" ] && q="${QUERY_STRING}&"
	    cgi_get_POST_vars
	    [ ! -z "${POST_STRING}" ] && q="${q}${POST_STRING}&"
	    ;;
    esac
    shift
    s=" $* "
    # parse the query data
    while [ ! -z "$q" ]; do
	p="${q%%&*}"  # get first part of query string
	k="${p%%=*}"  # get the key (variable name) from it
	v="${p#*=}"   # get the value from it
	q="${q#$p&*}" # strip first part from query string
	# decode and evaluate var if requested
	[ "$1" = "ALL" -o "${s/ $k /}" != "$s" ] && \
	    eval "$k=\"`cgi_decodevar \"$v\"`\""
    done
    return
}

init(){
    SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
    TMP_DIR=${SHELL_FOLDER}/../data/tmp/
    #when great than 50k, gzip it 
    MAX_FILE_SIZE=51200
}

mk_tmp_file(){
    if [ ! -f ${TMP_DIR}/${1} ]
    then
        python ${SHELL_FOLDER}/match.py $1 > ${TMP_DIR}/$1
    fi

    file_size=`stat -c %s ${TMP_DIR}/${1}`
    if [ ${file_size} -ge ${MAX_FILE_SIZE} ]
    then
        if [ ! -f ${TMP_DIR}/${1}.gz ]
        then
            grep -v "ip-cidr" ${TMP_DIR}/${1} | sed '/^$/d' | sed ":a;N;s/\\n/<br \/>/g;ta" > ${TMP_DIR}/${1}.html
            gzip -c -9  ${TMP_DIR}/${1}.html > ${TMP_DIR}/${1}.gz
            \rm -rf ${TMP_DIR}/${1}.html
        fi
    fi
}

mk_resp(){
    echo "Content-Type: text/html"
    if [ ${1}x == "x" ] 
    then
        echo ""
        echo "search string is null.<br />" 
    elif [ -f ${TMP_DIR}/${1}.gz ]
    then   
        echo "Content-Encoding: gzip"
        echo "Content-Length: `stat -c %s ${TMP_DIR}/${1}.gz`"
        echo ""
        cat ${TMP_DIR}/${1}.gz
    elif [ -f ${TMP_DIR}/${1} ]
    then
        result=`cat ${TMP_DIR}/${1}`
        echo ""
        echo "${result//$'\n'/<br />}" 
    else
        echo ""
        echo "file not found.<br />" 
    fi
}

main(){
    cgi_getvars POST ip_or_view
    if [ ${ip_or_view}x == "x" ]
    then
        echo "ip_or_view is null" 1>&2
        exit 0
    else
        echo "ip_or_view:${ip_or_view}" 1>&2
    fi
    init
    mk_tmp_file ${ip_or_view}
    mk_resp ${ip_or_view}
}

main $@