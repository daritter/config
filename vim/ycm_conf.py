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
]

rconf = subprocess.Popen(["root-config", "--cflags"], stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
rout = rconf.communicate()[0]
if rconf.wait() == 0:
    flags += rout.strip().split()

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
