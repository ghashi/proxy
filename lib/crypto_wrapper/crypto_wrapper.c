#include "ruby.h"
#include "util.h"
#include "aes_128.h"
#include "mss.h"

static VALUE t_init(VALUE self){
  return self;
}

static VALUE t_verify_hmac(){
}

static VALUE t_symmetric_decrypt(VALUE self, VALUE session_key, VALUE msg ){
  unsigned char iv[AES_128_BLOCK_SIZE] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f};
  unsigned char *key;
  unsigned char *ciphertext;
  unsigned int  ciphertext_len;
  unsigned int  key_len;
  unsigned int  buffer[300];
  VALUE str;
  int i;

  // convert VALUE to string
  str = StringValue(msg);
  ciphertext = RSTRING_PTR(str);
  ciphertext_len = RSTRING_LEN(str);
  str = StringValue(session_key);
  key = RSTRING_PTR(str);
  key_len = RSTRING_LEN(str);

  // converter BASE64 para BYTE
  base64decode(ciphertext, ciphertext_len, ciphertext, &ciphertext_len);
  base64decode(key, key_len, key, &key_len);

  aes_128_cbc_decrypt(key, iv, ciphertext, ciphertext_len, buffer);

  return rb_str_new2(buffer);
}

static VALUE t_symmetric_encrypt(VALUE self, VALUE nonce, VALUE session_key ){
  return Qtrue;
  const unsigned char key[AES_128_KEY_SIZE];
  const unsigned char iv[AES_128_BLOCK_SIZE];
  const char *plaintext;
  unsigned char *ciphertext;
  unsigned int *ciphertext_len;
  aes_128_cbc_encrypt(
      key,
      iv,
      &plaintext,
      &ciphertext,
      &ciphertext_len);
  // converter BYTE para BASE64
  return ciphertext;
}

VALUE cCryptoWrapper;

void Init_crypto_wrapper() {
  cCryptoWrapper = rb_define_class("CryptoWrapper", rb_cObject);
  rb_define_method(cCryptoWrapper, "initialize", t_init, 0);
  rb_define_singleton_method(cCryptoWrapper, "verify_hmac", t_verify_hmac, 0);
  rb_define_singleton_method(cCryptoWrapper, "symmetric_encrypt", t_symmetric_encrypt, 2);
  rb_define_singleton_method(cCryptoWrapper, "symmetric_decrypt", t_symmetric_decrypt, 2);
}
