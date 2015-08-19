import os
from distutils import sysconfig
flags = [
    '-Wall',
    '-Wextra',
    #'-Werror',
    '-Wno-long-long',
    '-Wno-variadic-macros',
    '-fexceptions',
    '-x', 'c++',
    '-std=c++11',
]
includes = []

b2dir = os.environ.get("BELLE2_LOCAL_DIR", None)
if not b2dir:
    print "Belle2 not set up correctly."
else:
    b2ext = os.environ["BELLE2_EXTERNALS_DIR"]
    subdir = os.environ.get('BELLE2_EXTERNALS_SUBDIR',
                            os.environ['BELLE2_SUBDIR'])
    # includes.append("%s/include" % b2ext)
    extinc = os.path.join(b2ext, "include")
    for dir, dirs, files in os.walk(extinc):
        for d in dirs:
            if d in ["Vc", "pqxx"]:
                continue
            includes.append(os.path.join(extinc, d))
        del dirs[:]
    includes.append(os.path.join(b2ext, "root", subdir, "include"))
    includes.append(sysconfig.get_python_inc())
    includes.append("/usr/include/libxml2")


def FlagsForFile(filename, **kwargs):
    global includes
    # Add all include directories in parent directories to the include path
    dirname = os.path.dirname(filename)
    local_includes = []
    while True:
        incdir = os.path.join(dirname, "include")
        if os.path.isdir(incdir):
            local_includes.insert(0, incdir)
        dirname = os.path.dirname(dirname)
        if not dirname.strip(os.path.sep):
            break

    all_includes = local_includes + includes

    return {"flags": flags + ["-I%s" % e for e in all_includes],
            "do_cache": True}
