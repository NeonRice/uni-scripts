#!/usr/bin/env python3
import os
import sys
import fnmatch
from datetime import datetime as dt
from stat import S_ISDIR
from typing import List


class Logger(object):
    def __init__(self, log_filename):
        self.terminal = sys.stdout
        self.log = open(log_filename, "a")

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message)

    def flush(self):
        pass


def find(pattern: str, path: str):
    dir_matches: List[str] = []
    file_matches: List[str] = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if fnmatch.fnmatch(file, pattern):
                file_matches.append(os.path.join(root, file))
        for dir in dirs:
            if fnmatch.fnmatch(dir, pattern):
                dir_matches.append(os.path.join(root, dir))
    return dir_matches, file_matches


class ccode:
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


def str_color(str, code):
    return code + str + ccode.ENDC


def print_path_info(path: str):
    pstat = os.stat(path)
    date_format = "%Y-%m-%d %H:%M:%S"
    formatted_access = dt.fromtimestamp(pstat.st_atime).strftime(date_format)
    formatted_mod = dt.fromtimestamp(pstat.st_mtime).strftime(date_format)

    print(f"Name: {os.path.basename(path)}\nPath: {path}")
    print(f"Last access: {formatted_access}\nLast modified: {formatted_mod}")
    print(f"Size: {pstat.st_size/float(1<<20):,.3f} MB")
    if S_ISDIR(pstat.st_mode):
        print("Entries:")
        for entry in os.listdir(path):
            print(f"  - {entry}")


def show_usage():
    py_exe = os.path.basename(sys.executable)
    script = os.path.basename(__file__)
    print(
        str_color(f"Usage: {py_exe} {script} [pattern]", ccode.WARNING + ccode.BOLD))
    print(str_color(f"Example: {py_exe} {script} \"*.py\"", ccode.OKGREEN))
    print(str_color("Notice the quotation marks surrounding" +
          " the pattern, used to disable shell glob expansion", ccode.WARNING))
    exit(-1)


def print_paths(path: List[str], separator='-' * 10):
    for entry in path:
        print_path_info(entry)
        print(separator)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        show_usage()
    run_time = dt.now()
    # stdout redirected to file and out
    sys.stdout = Logger(f"{int(run_time.timestamp())}-file-search.log")
    dirs, files = find(sys.argv[1], '.')

    sep_length = max([len(max(dirs, default='', key=len)), len(
        max(files, default='', key=len))], default=0)
    sep = '-' * (sep_length + 6)
    sep_header = '-' * int(sep_length / 2)

    run_dt = run_time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"Script ran: {run_dt}\nPattern used: {sys.argv[1]}\n")
    if len(files) > 0:
        print(f"{sep_header} FILES {sep_header}")
        print_paths(files, sep)
    if len(dirs) > 0:
        print(f"{sep_header} DIRECTORIES {sep_header}")
        print_paths(dirs, sep)
