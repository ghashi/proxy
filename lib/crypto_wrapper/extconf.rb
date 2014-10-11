require 'mkmf'

abort "change rb_teste.h, rb_teste, verify"

LIBDIR      = RbConfig::CONFIG['libdir']
INCLUDEDIR  = RbConfig::CONFIG['includedir']

HEADER_DIRS = [INCLUDEDIR, Dir.pwd]

LIB_DIRS = [LIBDIR, Dir.pwd]

dir_config('crypto_wrapper', HEADER_DIRS, LIB_DIRS)

unless find_header('rb_teste.h')
  abort "rb_teste.h is missing"
end

unless have_library('rb_teste', 'verify')
  abort "librb_teste is missing"
end

create_makefile("crypto_wrapper")
