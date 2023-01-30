project('xdp-tools', 'c', meson_version: '>=0.64.0', version: '1.2.2', default_options: ['c_std=gnu99'])

headers = include_directories('headers')

cc = meson.get_compiler('c')

#zlib = dependency('zlib')
#libelf = dependency('libelf')
libbpf = dependency('libbpf')
math = cc.find_library('m')
libpcap = dependency('libpcap', required: false)

message(libbpf.type_name())

features = []

libbpf_function_check= '''
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <bpf/btf.h>
int main(int argc, char **argv) {
    @0@@1@;
    return 0;
}
'''

bpf_feature_tests = [
    {'function': 'perf_buffer__consume',        'arguments': '(NULL)'},
    {'function': 'btf__load_from_kernel_by_id', 'arguments': '(0)'},
    {'function': 'btf__type_cnt',               'arguments': '(0)'},
    {'function': 'bpf_object__next_map',        'arguments': '(NULL, NULL)'},
    {'function': 'bpf_object__next_program',    'arguments': '(NULL, NULL)'},
    {'function': 'bpf_program__insn_cnt',       'arguments': '(NULL)'},
    {'function': 'bpf_map_create',              'arguments': '(0, NULL, 0, 0, 0, NULL)'},
    {'function': 'perf_buffer__new_raw',        'arguments': '(0, 0, NULL, NULL, NULL, NULL)'},
    {'function': 'bpf_xdp_attach',              'arguments': '(0, 0, 0, NULL)'},
    {'function': 'bpf_map__set_autocreate',     'arguments': '(NULL, false)'},
]

foreach t : bpf_feature_tests
    if cc.compiles(libbpf_function_check.format(t.get('function'), t.get('arguments') ), dependencies: libbpf, name: 'libbpf has: '+t.get('function'))
        features += 'HAVE_LIBBPF_'+t.get('function').to_upper()
    endif
endforeach

check_secure_env = '''
#define _GNU_SOURCE
#include <stdlib.h>
int main(int argc, char **argv) {
	secure_getenv("test");
    return 0;
}
'''
if cc.compiles(check_secure_env, name: 'checking if stdlib provides secure_getenv')
    features += 'HAVE_SECURE_GETENV'
endif

defines = []

bpf_object_path = get_option('BPF_OBJECT_DIR')

if bpf_object_path[0] != '/'
    bpf_object_path = join_paths(get_option('libdir'), bpf_object_path)
endif

defines += [
    '-DBPF_DIR_MNT="'+get_option('BPF_DIR_MNT')+'"',
    '-DBPF_OBJECT_PATH="'+join_paths(get_option('prefix'),bpf_object_path)+'"',
    '-DMAX_DISPATCHER_ACTIONS=@0@'.format((get_option('MAX_DISPATCHER_ACTIONS'))),
    '-DTOOLS_VERSION="'+meson.project_version()+'"',
    '-DLIBBPF_VERSION="'+libbpf.version()+'"',
    '-DRUNDIR="'+get_option('RUNDIR')+'"',
]

foreach f : features
    defines += '-D'+f
endforeach

clang = find_program('clang', version: '>= 11', required: true)
llc = find_program('llc', version: '>= 11', required: true)
m4 = find_program('m4', required: true)
ld = find_program('ld', required: true)
objcopy = find_program('objcopy', required: true)
bpftool = find_program('bpftool', required: true)
emacs = find_program('emacs', required: false)
add_project_arguments(defines, language: 'c')

bpf_target = get_option('BPF_TARGET')

bpf_cflags = []

bpf_cflags += defines

bpf_cflags += [
    '-I@0@/@1@'.format(meson.global_source_root(), 'headers'),
    '-D_LARGEFILE64_SOURCE',
    '-D_FILE_OFFSET_BITS=64',
]

clang_bpf_arg = [
    '-S', '-target', bpf_target,
        '-D', '__BPF_TRACING__',
        '-Wno-visibility',
        bpf_cflags,
        '-Wall',
        '-Wno-unused-value',
        '-Wno-pointer-sign',
        '-Wno-compare-distinct-pointer-types',
        '-Werror',
        '-O2', '-emit-llvm', '-c', '-g', '-o', '@OUTPUT@', '@INPUT@'
]

compile_bpf_clang = [clang, clang_bpf_arg]

llc_bpf_arg = [
    '-march='+bpf_target, '-filetype=obj', '-o', '@OUTPUT@', '@INPUT@'
]

compile_bpf_llc = [llc, llc_bpf_arg]

#This needs to be in 1 custom target because meson doesn't like it if we modify files in place
make_bpf_embeddable = [ld, '-r', '-b', 'binary', '-o', '@OUTPUT@', '-z', 'noexecstack', '--format=binary', '@INPUT@']
objcopy_embed_cmd = [ objcopy, '--rename-section', '.data=.rodata,alloc,load,readonly,data,content']


sed_script = files('man_sed_script.sh')

man_targets = []

fs = import('fs')

subdir('lib')
subdir('xdp-bench')
if libpcap.found()
    subdir('xdp-dump')
endif
subdir('xdp-filter')
subdir('xdp-loader')
subdir('xdp-monitor')

if emacs.found()
    foreach man : man_targets
        source = man.get('source-file')
        name = man.get('name')
        num = man.get('number')

        cp = fs.copyfile(source, name+fs.name(source))

        gen = custom_target(output: name+'.man', input: cp, command: [
            emacs,  '-Q', '--batch', '--find-file', '@INPUT@', '--eval', '(progn (require \'ox-man)(org-man-export-to-man))'
        ])
        readme_get_date = run_command('git', 'log', '-1', '--pretty="format:%cI"', '@0@/@1@'.format(meson.global_source_root(), source[0]), capture: true, check: false)
        if readme_get_date.returncode() ==  0
            readme_date = run_command('date', '+%B %_d, %Y', '-d', readme_get_date.stdout().replace('"', '').strip('format:'), capture: true, check: true).stdout().strip()
        else
            readme_date = run_command('date', '+%B %_d, %Y', capture: true, check: true).stdout().strip()
        endif
        custom_target(input: gen, output: name+'.'+num, command: 
            [
                sed_script, '@INPUT@', readme_date, libxdp_version
            ],
            capture: true, install: true, install_dir: join_paths(get_option('mandir'), 'man'+num))
    endforeach
endif