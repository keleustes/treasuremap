#!/usr/bin/python3

# Copyright 2018 AT&T Network Cloud Team
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import yaml
import requests
import sys
import json
import logging
import os
import argparse
import copy
import yaml
import glob
import csv
import re
from collections import OrderedDict


def __represent_multiline_yaml_str():
    """Compel ``yaml`` library to use block style literals for multi-line
    strings to prevent unwanted multiple newlines.

    """

    yaml.SafeDumper.org_represent_str = yaml.SafeDumper.represent_str

    def repr_str(dumper, data):
        if '\n' in data:
            return dumper.represent_scalar(
                'tag:yaml.org,2002:str', data, style='|')
        return dumper.org_represent_str(data)

    yaml.add_representer(str, repr_str, Dumper=yaml.SafeDumper)

def save_file(filename, docs):
    with open(filename, 'w') as stream:
        yaml.safe_dump_all(docs,
                           stream,
                           explicit_start=True,
                           explicit_end=False,
                           default_flow_style=False)


def add_to_structdict(structname, structdict):
    if (structname not in structdict):
        structdict[structname] = []


def generate_go_struct(structname, fields):
    print('type {} struct {}'.format(structname, '{'))
    for field in fields:
        print('    {}'.format(field))
    print('{}'.format('}'))
    print('')


# Simple script to generate set of go struct that could be
# used to refine the ArmadaChartValue field
def to_go(filepath):
    structdict = {}
    structname = "AV"
    add_to_structdict(structname, structdict)
    with open(filepath) as fp:
        line = fp.readline()
        cnt = 1
        while line:
            # Create a line as follow:
            # Upgrade *ArmadaUpgrade `json:"upgrade,omitempty"`
            fieldname = line.strip()
            camelcase = ''.join(x for x in fieldname.replace("_", " ").title() if not x.isspace())
            substructname = structname + camelcase
            structdict[structname].append('// {} contains tbd'.format(fieldname))
            structdict[structname].append('{} *{} `json:"{},omitempty"`'.format(camelcase, "map[string]ArmadaMapString", fieldname))
            add_to_structdict(substructname, structdict)
            line = fp.readline()
            cnt += 1
    for structname, fields in structdict.items():
        generate_go_struct(structname, fields)

    return structdict

def extract_fields(dirname, fieldnames, fullset):
    """
    TBD
    Args:
       tbd
    Returns:
       tbd
    """
    directory = os.fsencode(dirname)

    for file in os.listdir(directory):
        filename = os.fsdecode(file)
        with open(dirname + "/" + filename, 'r') as stream:
            try:
                docs = yaml.load_all(stream)
            except yaml.YAMLError as exc:
                print(exc)

            docs2 = list(docs)
            for doc in docs2:
                if (doc["kind"] == "ArmadaChart"):
                    if ("spec" in doc) and ("values" in doc["spec"]):
                      for fieldname in fieldnames:
                          if (fieldname in doc["spec"]["values"]):
                              fullset[fieldname].update(set(doc["spec"]["values"][fieldname].keys()))

    return fullset

def reformat(filename):
    """
    TBD
    Args:
       tbd
    Returns:
       tbd
    """
    docs2 = []
    vars = {}
    varrefs = {}
    with open(filename, 'r') as stream:
        try:
            docs = yaml.load_all(stream)
        except yaml.YAMLError as exc:
            print(exc)

        docs2 = list(docs)

    return docs2

if __name__ == "__main__":
    __represent_multiline_yaml_str()
    parser = argparse.ArgumentParser()

    parser.add_argument('-c', '--command',
                        help="Command to run",
                        type=str, choices=["togo","extract_fields", "extract_all_fields"],
                        default="togo")
    parser.add_argument('-f', '--filename',
                        help="filename",
                        type=str,
                        default="airship.yaml")
    parser.add_argument('-d', '--dirname',
                        help="dirname",
                        type=str,
                        default="./actual")

    args = parser.parse_args()

    if (args.command == "togo"):
        docs = to_go(args.filename)
    elif (args.command == "extract_fields"):
        fieldname = "conf"
        docs = extract_fields(args.dirname, fieldname)
    elif (args.command == "extract_all_fields"):
        fieldnames = ["bootstraping", "conf", "development", "network", "service"]
        fullset={}
        for fieldname in fieldnames:
           fullset[fieldname] =  set()

        for i in ["aiab", "aiab-tf", "airskiff-suse", "airskiff-ubuntu", "airsloop", "seaworthy", "seaworthy-virt"]:
            extract_fields(args.dirname + "/" + i, fieldnames, fullset)

        for fieldname in fieldnames:
            print(fieldname)
            print(fullset[fieldname])
            print("================")
    else:
        pass
