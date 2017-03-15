import os
import subprocess
flags = [
    '-Weverything',
    '-Wno-c++98-compat',
    '-Wno-exit-time-destructors',
    '-Wno-long-long',
    '-Wno-variadic-macros',
    '-fexceptions',
    '-x', 'c++',
    '-std=c++11',
    '-nostdinc++',
]
includes = []

# adjust clang to find gcc c++ includes
gcc_search_path = subprocess.check_output(["g++", "-v", "-x", "c++", "--syntax-only", "/dev/null"],
                                          stderr=subprocess.STDOUT).decode()
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

b2dir = os.environ.get("BELLE2_LOCAL_DIR", None)
if not b2dir:
    print("Belle2 not set up correctly.")
else:
    b2ext = os.environ["BELLE2_EXTERNALS_DIR"]
    extinc = os.path.join(b2ext, "include")
    includes.append(extinc)
    for dir, dirs, files in os.walk(extinc):
        for d in dirs:
            if d in ["Vc", "pqxx"]:
                continue
            includes.append(os.path.join(extinc, d))
        del dirs[:]


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
