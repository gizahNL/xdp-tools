xdp_filter_bpf_programs = [
    'xdpfilt_dny_udp.c', 'xdpfilt_dny_tcp.c', 'xdpfilt_dny_ip.c', 'xdpfilt_dny_eth.c', 'xdpfilt_dny_all.c', 
    'xdpfilt_alw_udp.c', 'xdpfilt_alw_tcp.c', 'xdpfilt_alw_ip.c', 'xdpfilt_alw_eth.c', 'xdpfilt_alw_all.c'
]

xdp_filter_bpf_obj = []
foreach x : xdp_filter_bpf_programs
    basename = x.replace('.bpf.c', '')
    t = custom_target(output: '@BASENAME@.ll', input: x, command: [
        clang, clang_bpf_arg])
    xdp_filter_bpf_obj += custom_target(output: '@BASENAME@.o', input: t, command: [
        llc, llc_bpf_arg], install: true, install_dir: bpf_object_path)
endforeach

man_targets += {'source-file':files('README.org'), 'name': 'xdp-filter', 'number': '8'}

prog_features_h = custom_target(output: 'prog_features.h', input: xdp_filter_bpf_obj, command: ['sh', files('extract_features.sh')[0], '@INPUT@'], capture: true)

executable('xdp-filter', 'xdp-filter.c', prog_features_h, dependencies: [libxdp_dep, xdp_util_dep], install: true, install_dir: 'sbin')