xdp_bench_bpf_programs = ['xdp_basic.bpf.c', 'xdp_redirect_basic.bpf.c', 'xdp_redirect_cpumap.bpf.c', 'xdp_redirect_devmap_multi.bpf.c', 'xdp_redirect_devmap.bpf.c']
xdp_bench_headers = []
foreach x : xdp_bench_bpf_programs
    basename = x.replace('.bpf.c', '')
    t = custom_target(output: '@BASENAME@.ll', input: x, command: [
        clang, clang_bpf_arg])
    t2 = custom_target(output: '@BASENAME@.o', input: t, command: [
        llc, llc_bpf_arg])
    xdp_bench_headers += custom_target(output: basename + '.skel.h', input: t2, command: 
        [ bpftool, 'gen', 'skeleton', '@INPUT@', 'name', basename ], capture: true)
endforeach

man_targets += {'source-file':files('README.org'), 'name': 'xdp-bench', 'number': '8'}

xdp_bench = executable(
    'xdp-bench',
    'xdp_basic.c',
    'xdp_redirect_basic.c',
    'xdp_redirect_cpumap.c',
    'xdp_redirect_devmap_multi.c',
    'xdp_redirect_devmap.c',
    'xdp-bench.c',
    xdp_bench_headers,
    dependencies: [libxdp_dep, xdp_util_dep],
    install: true,
    install_dir: 'sbin'
)