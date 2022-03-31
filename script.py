import os
import sys


def show_usage():
    py_exe = os.path.basename(sys.executable)
    script = os.path.basename(__file__)
    print(f"Usage: {py_exe} {script} [pattern]")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        show_usage()
