xdp_dump_bpf_programs = ['xdpdump_bpf.c', 'xdpdump_xdp.c']
foreach x : xdp_dump_bpf_programs
    basename = x.replace('.bpf.c', '').replace('.c', '')
    t = custom_target(output: '@BASENAME@.ll', input: x, command: [
        clang, clang_bpf_arg])
    t2 = custom_target(output: '@BASENAME@.o', input: t, command: [
        llc, llc_bpf_arg], install: true, install_dir: bpf_object_path)
endforeach

man_targets += {'source-file':files('README.org'), 'name': 'xdpdump', 'number': '8'}

executable('xdpdump', 'xdpdump.c', dependencies: [libxdp_dep, xdp_util_dep, libpcap], install: true, install_dir: 'sbin')