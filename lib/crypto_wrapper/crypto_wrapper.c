#include "ruby.h"

static VALUE t_init(VALUE self){
  return self;
}


static VALUE t_verify_hmac(){
}

VALUE cCryptoWrapper;

void Init_crypto_wrapper() {
  cCryptoWrapper = rb_define_class("CryptoWrapper", rb_cObject);
  rb_define_method(cCryptoWrapper, "initialize", t_init, 0);
  rb_define_singleton_method(cCryptoWrapper, "verify_hmac", t_verify_hmac, 0);
  rb_define_singleton_method(cCryptoWrapper, "encrypt_base64", t_verify_hmac, 0);
  rb_define_singleton_method(cCryptoWrapper, "decrypt_base64", t_verify_hmac, 0);
}


