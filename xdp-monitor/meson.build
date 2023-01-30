xdp_monitor_bpf_programs = ['xdp_monitor.bpf.c']
xdp_monitor_headers = []
foreach x : xdp_monitor_bpf_programs
    basename = x.replace('.bpf.c', '')
    t = custom_target(output: '@BASENAME@.ll', input: x, command: [
        clang, clang_bpf_arg])
    t2 = custom_target(output: '@BASENAME@.o', input: t, command: [
        llc, llc_bpf_arg])
    xdp_monitor_headers += custom_target(output: basename + '.skel.h', input: t2, command: 
        [ bpftool, 'gen', 'skeleton', '@INPUT@', 'name', basename ], capture: true)
endforeach

man_targets += {'source-file':files('README.org'), 'name': 'xdp-monitor', 'number': '8'}

executable('xdp-monitor', 'xdp-monitor.c', xdp_monitor_headers, dependencies: [libxdp_dep, xdp_util_dep], install: true, install_dir: 'sbin')