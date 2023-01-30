
version_script = files('libxdp.map')
libxdp_version_cmd = run_command(
    'sed', '-ne', '/LIBXDP_[0-9\.]\+ {/ {s/LIBXDP_\([0-9\.]\+\) {/\\1/;p}', '@0@/@1@'.format(meson.global_source_root(), version_script[0]),
    capture: true,
    check: true,
)

libxdp_version = libxdp_version_cmd.stdout().strip().split('\n')[-1]
libxdp_version_major = libxdp_version.split('.')[0]
message('LibXDP Version: '+libxdp_version)

xdp_programs = [ 'xsk_def_xdp_prog.c', 'xsk_def_xdp_prog_5.3.c']

xdp_programs += custom_target('xdp-dispatcher.c', 
        output: 'xdp-dispatcher.c', input: 'xdp-dispatcher.c.in',
        command: [m4, defines, '@INPUT@'], capture: true)

man_targets += {'source-file':files('README.org'), 'name': 'libxdp', 'number': '3'}

extra_obj = []

suffixes = ['_start', '_end', '_size']

foreach x : xdp_programs
    t = custom_target(output: '@BASENAME@.ll', input: x, command: compile_bpf_clang)
    t2 = custom_target(output: '@BASENAME@.o', input: t, command: compile_bpf_llc, install: true, install_dir: bpf_object_path)

    #This trickery is needed because we're building out of tree, so the path to the file isn't what is expected
    #this way we dymanically change back the object name in the generated .o file to what we expect..
    file_rel_path = t2.full_path().replace(meson.project_build_root()+'/', '')
    file_name = t2.full_path().replace(meson.current_build_dir()+'/', '')
    sym_replace_src = '_binary_'+file_rel_path.replace('/', '_').replace('.', '_').replace('-', '_')
    sym_replace_tgt = '_binary_'+file_name.replace('/', '_').replace('.', '_').replace('-', '_')
    rename_sym = []
    foreach s : suffixes
        rename_sym += '--redefine-sym'
        rename_sym += sym_replace_src+s+'='+sym_replace_tgt+s
    endforeach
    t3 = custom_target(output: '@BASENAME@.embed.o', input: t2, command: [make_bpf_embeddable])
    extra_obj += custom_target(output: file_name.replace('.o', '')+'.objcopy.o', input: t3, command: [objcopy_embed_cmd, rename_sym, '@INPUT@', '@OUTPUT@'])

endforeach

libxdp_shared = shared_library(
    'xdp',
    'libxdp.c',
    'xsk.c', 
    include_directories: headers,
    dependencies: libbpf,
    soversion: libxdp_version_major,
    version: libxdp_version,
    link_args: '-Wl,--version-script,@0@/@1@'.format(meson.global_source_root(), version_script[0])
)

libxdp_static = static_library(
    'xdp',
    'libxdp.c',
    'xsk.c',
    extra_obj,
    c_args: '-DLIBXDP_STATIC=1',
    include_directories: headers,
    dependencies: libbpf,
)
libxdp_dep = false

if get_option('default_library') == 'shared'
    libxdp_dep = declare_dependency(link_with: libxdp_shared, dependencies: libbpf, include_directories: headers)
else
    libxdp_dep = declare_dependency(link_with: libxdp_static, dependencies: libbpf, include_directories: headers)
endif