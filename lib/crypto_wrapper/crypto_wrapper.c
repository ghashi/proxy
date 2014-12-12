#include "ruby.h"
#include "util.h"
#include "aes_128.h"
#include "mss.h"
#include "hmac.h"

static VALUE t_init(VALUE self){
  return self;
}

static VALUE t_verify_hmac(VALUE self, VALUE r_tag, VALUE r_msg, VALUE r_session_key){
  unsigned char *session_key;
  unsigned int  session_key_len;
  unsigned char *msg;
  unsigned int  msg_len;
  unsigned char *tag;
  unsigned int  tag_len;
  unsigned char res;
  char *decoded_session_key;
  int decoded_session_key_len;
  char *decoded_tag;
  int decoded_tag_len;
  VALUE str;

  // convert VALUE to string
  str = StringValue(r_session_key);
  session_key = RSTRING_PTR(str);
  session_key_len = RSTRING_LEN(str);
  str = StringValue(r_msg);
  msg = RSTRING_PTR(str);
  msg_len = RSTRING_LEN(str);
  str = StringValue(r_tag);
  tag = RSTRING_PTR(str);
  tag_len = RSTRING_LEN(str);

  decoded_session_key = malloc(session_key_len);
  decoded_session_key_len = session_key_len;
  decoded_tag = malloc(tag_len);
  decoded_tag_len = tag_len;

  base64decode(session_key, session_key_len, decoded_session_key, &decoded_session_key_len);
  base64decode(tag, tag_len, decoded_tag, &decoded_tag_len);

  res = verify_hmac( decoded_tag, msg, decoded_session_key);

  free(decoded_session_key);
  free(decoded_tag);

  if(res) return Qtrue;
  return Qfalse;
}

static VALUE t_get_hmac(VALUE self, VALUE r_session_key, VALUE r_msg){
  unsigned char *session_key;
  unsigned int  session_key_len;
  unsigned char *msg;
  unsigned int  msg_len;
  unsigned char tag[HMAC_TAG_SIZE];
  VALUE str;
  unsigned char *buffer;
  char *decoded_session_key;
  int decoded_session_key_len;

  // convert VALUE to string
  str = StringValue(r_session_key);
  session_key = RSTRING_PTR(str);
  session_key_len = RSTRING_LEN(str);
  str = StringValue(r_msg);
  msg = RSTRING_PTR(str);
  msg_len = RSTRING_LEN(str);

  decoded_session_key = malloc(session_key_len);
  decoded_session_key_len = session_key_len;

  base64decode(session_key, session_key_len, decoded_session_key, &decoded_session_key_len);

  get_hmac(msg, decoded_session_key, tag);

  buffer = malloc(2 * HMAC_TAG_SIZE);
  base64encode(tag, HMAC_TAG_SIZE, buffer, 2 * HMAC_TAG_SIZE);
  str = rb_str_new2(buffer);
  free(buffer);

  return str;
}

static VALUE t_symmetric_decrypt(VALUE self, VALUE r_session_key, VALUE msg ){
  printf("ENTROU ************************\n");
  unsigned char iv[AES_128_BLOCK_SIZE] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f};
  unsigned char *key;
  unsigned char *ciphertext;
  unsigned int  ciphertext_len;
  unsigned int  key_len;
  unsigned char *plaintext;
  unsigned int  plaintext_len;
  VALUE str;
  unsigned char *decoded_key;
  unsigned int  decoded_key_len;
  unsigned char *decoded_ciphertext;
  unsigned int  decoded_ciphertext_len;

  // convert VALUE to string
  str = StringValue(msg);
  ciphertext = RSTRING_PTR(str);
  ciphertext_len = RSTRING_LEN(str);
  str = StringValue(r_session_key);
  key = RSTRING_PTR(str);
  key_len = RSTRING_LEN(str);

  decoded_ciphertext = malloc(ciphertext_len);
  decoded_ciphertext_len = ciphertext_len;
  decoded_key        = malloc(key_len);
  decoded_key_len    = key_len;

  printf("antes decode _____________________\n");
  base64decode(ciphertext, ciphertext_len, decoded_ciphertext, &decoded_ciphertext_len);
  base64decode(key, key_len, decoded_key, &decoded_key_len);
  printf("depois decode _____________________\n");

  printf("antes decrypt _____________________\n");
  printf("decoded_key:  ");
  int i;
  printf("\n");

  plaintext_len = ciphertext_len;
  plaintext = malloc(plaintext_len);

  printf("plaintext_len: %d", plaintext_len);

  aes_128_cbc_decrypt(decoded_key, iv, decoded_ciphertext, decoded_ciphertext_len, plaintext);
  printf("depois decrypt_____________________\n");

  free(decoded_key);
  free(decoded_ciphertext);

  return rb_str_new2(plaintext);
}

static VALUE t_symmetric_encrypt(VALUE self, VALUE r_plaintext, VALUE r_session_key ){
  unsigned char iv[AES_128_BLOCK_SIZE] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f};
  char *plaintext;
  unsigned int  plaintext_len;
  unsigned char *key;
  unsigned int  key_len;
  unsigned char *ciphertext;
  unsigned int  ciphertext_len;
  unsigned char  *buffer;
  VALUE str;
  unsigned char *decoded_key;
  unsigned int   decoded_key_len;

  str = StringValue(r_plaintext);
  plaintext = RSTRING_PTR(str);
  plaintext_len = RSTRING_LEN(str);
  str = StringValue(r_session_key);
  key = RSTRING_PTR(str);
  key_len = RSTRING_LEN(str);

  ciphertext_len = plaintext_len + AES_128_BLOCK_SIZE;
  ciphertext = malloc(ciphertext_len);
  memset(ciphertext, 0, ciphertext_len);

  decoded_key = malloc(key_len);
  decoded_key_len = key_len;

  base64decode(key, key_len, decoded_key, &decoded_key_len);

  aes_128_cbc_encrypt(decoded_key, iv, plaintext, ciphertext, &ciphertext_len);

  free(decoded_key);
  buffer = malloc(2 * ciphertext_len);
  memset(buffer, 0, 2 * ciphertext_len);

  base64encode(ciphertext, ciphertext_len, buffer, 2 * ciphertext_len);

  str = rb_str_new2(buffer);

  free(buffer);

  return str;
}

VALUE cCryptoWrapper;

void Init_crypto_wrapper() {
  cCryptoWrapper = rb_define_class("CryptoWrapper", rb_cObject);
  rb_define_method(cCryptoWrapper, "initialize", t_init, 0);
  rb_define_singleton_method(cCryptoWrapper, "verify_hmac", t_verify_hmac, 3);
  rb_define_singleton_method(cCryptoWrapper, "get_hmac", t_get_hmac, 2);
  rb_define_singleton_method(cCryptoWrapper, "symmetric_encrypt", t_symmetric_encrypt, 2);
  rb_define_singleton_method(cCryptoWrapper, "symmetric_decrypt", t_symmetric_decrypt, 2);
}
