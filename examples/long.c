/*
 * examples/long.c: example for multiplication, division and modulo of long (32-bit) integers
 * by pts@fazekas.hu at Fri May 27 14:44:31 CEST 2022
 *
 * First compile libc: dosmc dosmclib
 * Then compile try: dosmc -nq -cldl examples/long.c
 */

long longdiv(long a, long b) {
  return a / b;
}

long longdivint(long a, int b) {
  return a / b;
}

unsigned long ulongdiv(unsigned long a, unsigned long b) {
  return a / b;
}

unsigned long ulongdivint(unsigned long a, unsigned b) {
  return a / b;
}

long longmod(long a, long b) {
  return a % b;
}

long longmodint(long a, int b) {
  return a % b;
}

unsigned long ulongmod(unsigned long a, unsigned long b) {
  return a % b;
}

unsigned long ulongmodint(unsigned long a, unsigned b) {
  return a % b;
}

long longmul(long a, long b) {
  return a * b;
}

unsigned long ulongmul(unsigned long a, unsigned long b) {
  return a * b;
}


