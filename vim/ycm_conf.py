import os
import subprocess
flags = [
    '-Wall',
    '-Wextra',
#    '-Werror',
    '-Wno-long-long',
    '-Wno-variadic-macros',
    '-fexceptions',
    '-x', 'c++',
    '-std=c++11',
    '-nostdinc++',
]

# adjust clang to find gcc c++ includes
gcc_search_path = subprocess.check_output(["g++", "-v", "-x", "c++", "--syntax-only", "/dev/null"], stderr=subprocess.STDOUT)
is_search_path = False
for line in gcc_search_path.splitlines():
    if line.startswith("End of search list"):
        break
    # ok, here we process all lines in the g++ default include path. If they
    # have c++ in the name we take them
    if is_search_path and line.find("c++") >= 0:
        flags.append("-isystem%s" % line.strip())
    # search path starts after this line
    if line.startswith("#include <...> search starts here:"):
        is_search_path = True

try:
    rconf = subprocess.check_output(["root-config", "--cflags"])
    flags += rconf.strip().split()
except OSError:
    pass

belle_top_dir = os.environ.get("BELLE_TOP_DIR", "/belle/belle/b20090127_0910")
if os.path.exists(belle_top_dir):
    flags += ["-isystem", os.path.join(belle_top_dir, "include")]

#Path to boost installation if neccessary
for incpath in ["/remote/pcbelle03/ritter/local/include", "/usr/lib/openmpi/include", "/usr/lib/openmpi/include/openmpi"]:
    if os.path.exists(incpath):
        flags += ["-isystem", incpath]

scriptdir = os.path.abspath(os.path.dirname(__file__))


def FlagsForFile(filename, **kwargs):
    # Add all include directories in parent directories to the include path
    dirname = os.path.dirname(filename)
    while True:
        incdir = os.path.join(dirname, "include")
        if os.path.isdir(incdir):
            flags.append("-I" + incdir)
        dirname = os.path.dirname(dirname)
        print dirname
        if not dirname.strip(os.path.sep):
            break

    return {"flags": flags, "do_cache": True}
