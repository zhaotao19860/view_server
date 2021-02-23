#!/usr/bin/python
# -*- coding: utf-8 -*-

#  Created by zhaotao on 02/20/2019

import sys
import os
import codecs
from netaddr import IPRange, IPNetwork, IPAddress, ZEROFILL
import logging
import traceback


def printUsage():
    logging.info("Usage: python ./match.py ip地址/view_name")
    sys.exit(1)


def get_view_dict_ip(view_map_file_name):
    view_dict = dict()
    try:
        with codecs.open(view_map_file_name, 'r', 'UTF-8') as fv:
            for line in fv:
                line = line.strip()
                # 跳过注释行和空行
                if not len(line) or line.startswith('#'):
                    continue
                tmp = line.split()
                # 视图名称  视图ID
                # tmp[0]    tmp[1]
                key = int(tmp[1])
                assert view_dict.get(key) == None
                view_dict[key] = tmp[0]
    except Exception:
        logging.error("traceback.format_exc():%s", traceback.format_exc())
        sys.exit(1)
    return view_dict


def get_view_dict_name(view_map_file_name):
    view_dict = dict()
    try:
        with codecs.open(view_map_file_name, 'r', 'UTF-8') as fv:
            for line in fv:
                line = line.strip()
                # 跳过注释行和空行
                if not len(line) or line.startswith('#'):
                    continue
                tmp = line.split()
                # 视图名称  视图ID
                # tmp[0]    tmp[1]
                key = tmp[0]
                assert view_dict.get(key) == None
                view_dict[key] = tmp[1]
    except Exception:
        logging.error("traceback.format_exc():%s", traceback.format_exc())
        sys.exit(1)
    return view_dict


def match_ipv4_ip(ip, view_dict, ipv4_file_name):
    try:
        with codecs.open(ipv4_file_name, 'r', 'UTF-8') as fr:
            id = 0
            for line in fr:
                line = line.strip()
                # 跳过注释行和空行
                if not len(line) or line.startswith('#'):
                    continue
                tmp = line.split()
                # ip-start ip-end     视图ID
                # tmp[0]   tmp[1]     tmp[2]
                if int(ip) >= int(tmp[0]) and int(ip) <= int(tmp[1]):
                    id = int(tmp[2])
                    break
        value = view_dict.get(id)
        if value == None:
            logging.info("match ip error.")
        else:
            logging.info("ip: %s, view_id: %s, view_name: %s\n",
                         str(ip), str(id), value)
    except Exception:
        logging.error("traceback.format_exc():%s", traceback.format_exc())
        sys.exit(1)


def match_ipv6_ip(ip, view_dict, ipv6_file_name):
    try:
        with codecs.open(ipv6_file_name, 'r', 'UTF-8') as fr:
            id = 0
            for line in fr:
                line = line.strip()
                # 跳过注释行和空行
                if not len(line) or line.startswith('#'):
                    continue
                tmp = line.split()
                # ip     视图ID
                # tmp[0] tmp[1]
                cidr = IPNetwork(tmp[0])
                if int(ip) >= cidr.first and int(ip) <= cidr.last:
                    id = int(tmp[1])
                    break
        value = view_dict.get(id)
        if value == None:
            logging.info("match ip error.")
        else:
            logging.info("ip: %s, view_id: %s, view_name: %s\n",
                         str(ip), str(id), value)
    except Exception:
        logging.error("traceback.format_exc():%s", traceback.format_exc())
        sys.exit(1)


def match_ipv4_name(view_id, ipv4_file_name):
    try:
        with codecs.open(ipv4_file_name, 'r', 'UTF-8') as fr:
            for line in fr:
                line = line.strip()
                # 跳过注释行和空行
                if not len(line) or line.startswith('#'):
                    continue
                tmp = line.split()
                # ip-start ip-end     视图ID
                # tmp[0]   tmp[1]     tmp[2]
                if view_id == tmp[2]:
                    ip = IPRange(tmp[0], tmp[1])
                    for cidr in ip.cidrs():
                        logging.info("ip-cidr [%s]\n", str(cidr))
                    ip_start = str(IPAddress(tmp[0], flags=ZEROFILL))
                    ip_end = str(IPAddress(tmp[1], flags=ZEROFILL))
                    logging.info("ip-start [%s], ip-end [%s]\n",
                                 ip_start, ip_end)
    except Exception:
        logging.error("traceback.format_exc():%s", traceback.format_exc())
        sys.exit(1)


def match_ipv6_name(view_id, ipv6_file_name):
    try:
        with codecs.open(ipv6_file_name, 'r', 'UTF-8') as fr:
            for line in fr:
                line = line.strip()
                # 跳过注释行和空行
                if not len(line) or line.startswith('#'):
                    continue
                tmp = line.split()
                # ip     视图ID
                # tmp[0] tmp[1]
                cidr = IPNetwork(tmp[0])
                if view_id == tmp[1]:
                    ip_start = str(IPAddress(cidr.first, flags=ZEROFILL))
                    ip_end = str(IPAddress(cidr.last, flags=ZEROFILL))
                    logging.info("ip-cidr [%s]\n", tmp[0])
                    logging.info("ip-start [%s], ip-end [%s]\n",
                                 ip_start, ip_end)
    except Exception:
        logging.error("traceback.format_exc():%s", traceback.format_exc())
        sys.exit(1)


def match_ip(ip, view_map_file_name, ipv4_file_name, ipv6_file_name):
    view_dict = get_view_dict_ip(view_map_file_name)
    if ip.version == 4:
        match_ipv4_ip(ip, view_dict, ipv4_file_name)
    else:
        match_ipv6_ip(ip, view_dict, ipv6_file_name)


def match_name(view_name, view_map_file_name, ipv4_file_name, ipv6_file_name):
    view_dict = get_view_dict_name(view_map_file_name)
    view_id = view_dict.get(view_name)
    logging.info("IPV4:\n")
    match_ipv4_name(view_id, ipv4_file_name)
    logging.info("IPV6:\n")
    match_ipv6_name(view_id, ipv6_file_name)


def main():

    logging.basicConfig(stream=sys.stdout, level=logging.DEBUG, format='')

    if len(sys.argv) != 2:
        printUsage()

    script_path = os.path.dirname(os.path.realpath(sys.argv[0]))
    view_name = ''
    try:
        ip = IPAddress(sys.argv[1], flags=ZEROFILL)
    except Exception:
        view_name = sys.argv[1]

    view_map_file_name = script_path + "/../data/view_data/view_name_id.map"
    ipv6_file_name = script_path + "/../data/view_data/ipv6_range.map"
    ipv4_file_name = script_path + "/../data/view_data/ip_range.map"

    if view_name == '':
        match_ip(ip, view_map_file_name,
                 ipv4_file_name, ipv6_file_name)
    else:
        match_name(view_name, view_map_file_name,
                   ipv4_file_name, ipv6_file_name)


if __name__ == '__main__':
    main()
