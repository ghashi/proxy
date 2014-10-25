require 'mkmf'

LIBDIR      = RbConfig::CONFIG['libdir']
INCLUDEDIR  = RbConfig::CONFIG['includedir']

HEADER_DIRS = [INCLUDEDIR, Dir.pwd]

LIB_DIRS = [LIBDIR, Dir.pwd]

dir_config('crypto_wrapper', HEADER_DIRS, LIB_DIRS)

unless find_header('mss.h')
  abort "mss.h is missing"
end

unless have_library('crypto', 'mss_verify')
  abort "libcrypto is missing"
end

create_makefile("crypto_wrapper")
