
man_targets += {'source-file':files('README.org'), 'name': 'xdp-loader', 'number': '8'}

executable('xdp-loader', 'xdp-loader.c', dependencies: [libxdp_dep, xdp_util_dep], install: true, install_dir: 'sbin')