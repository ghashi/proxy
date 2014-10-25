#ifndef _UTIL_H_
#define _UTIL_H_

/*#include "mss.h"

typedef unsigned char rand_dig_f_type(void);

unsigned char rand_dig_f(void);

void Display(const char *tag, const unsigned char *u, unsigned short n);
short Rand(unsigned char *x, short bits, rand_dig_f_type rand_dig_f);
short Comp(const unsigned char *u, short ud, const unsigned char *v, short vd);
void start_seed(unsigned char seed[], short len);
void print_retain(const struct state_mt *state);*/

#ifdef DEBUG

char dbg_seed_initialized = 0;
unsigned char dbg_seed[LEN_BYTES(MSS_SEC_LVL)];

unsigned char _node_valid_index(unsigned char height, short pos);
unsigned char _node_valid(const struct mss_node *node);
unsigned char _node_equal(const struct mss_node *node1, const struct mss_node *node2);
unsigned char _is_left_node(const struct mss_node *node);
unsigned char _is_right_node(const struct mss_node *node);
unsigned char _node_brothers(const struct mss_node *left_node, const struct mss_node *right_node);
void print_auth(const struct state_mt *state);
void print_treehash(const struct state_mt *state);
void get_auth_index(unsigned short s, unsigned short auth_index[MSS_HEIGHT]); // Return the index of the authentication path for s-th leaf
void print_auth_index(unsigned short auth_index[MSS_HEIGHT - 1]);

/*void print_retain(const struct state_mt *state);*/

#endif

int base64encode(const void* data_buf, int data_size, char* result, int result_size);
int base64decode (char *in, int in_len, unsigned char *out, int *out_len);

#endif // _UTIL_H_
