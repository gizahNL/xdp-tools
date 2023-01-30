util_bpf_programs = ['xdp_sample.bpf.c']
util_gen_headers = []
foreach x : util_bpf_programs
    basename = x.strip('bpf.c')
    t = custom_target(output: '@BASENAME@.ll', input: x, command: [
        clang, clang_bpf_arg])
    t2 = custom_target(output: '@BASENAME@.o', input: t, command: [
        llc, llc_bpf_arg])
    util_gen_headers += custom_target(output: basename + '.skel.h', input: t2, command: 
        [ bpftool, 'gen', 'skeleton', '@INPUT@', 'name', basename ], capture: true)
endforeach

extra_sources = []
if libpcap.found()
    extra_sources += 'xpcapng.c'
endif

xdp_util_dep = declare_dependency(
    link_with: static_library('util', 'params.c', 'logging.c', 'util.c', 'stats.c', 'xdp_sample.c', extra_sources, util_gen_headers, include_directories: headers, dependencies: math),
    include_directories: include_directories('.')
)