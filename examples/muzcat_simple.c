/* muzcat_simple.c -- decompression filter in simple, portable C
 * by pts@fazekas.hu at Tue Jun 16 16:50:24 CEST 2020
 *
 * This tool is a slow drop-in replacmeent of zcat (gzip -cd), without error
 * handling. It reads compressed data (can be gzip, flate or zip format) on
 * stdin, and it writes uncompressed data to stdout. There is no error
 * handling: if the input is invalid, the tool may do anything.
 *
 * The implementation was inspired by https://www.ioccc.org/1996/rcm.c
 *
 * Portability notes:
 *
 * * Source code is compatible with C89, C99 and newer. GCC, Clang and TinyCC
 *   do work. 16-bit C compilers should also work.
 * * Source code is compatible with dosmc (http://github.com/pts/dosmc).
 *   Currently only .com output (dosmc -bt=com) works. Why?
 * * Source code isn't compatible with MesCC in GNU Mes 0.22, because MesCC
 *   doesn't support global arrays (initialized or uninitialized). Apart from
 *   that, it would compile.
 * * Feel free to drop `#include <stdio.h>', and define getchar() and putchar()
 *   differently.
 * * Feel free to change `short' and `char' to int.
 * * It doesn't matter whether `char' is signed or unsigned.
 * * The code works with any sizeof(short) and sizeof(int).
 * * The code doesn't use multiplication or division.
 * * On Windows, setmode(0, O_BINARY); and setmode(1, O_BINARY) are needed,
 *   otherwise the CRT inserts \r (CR) characters, breaking the decompression.
 *
 * Similar code:
 *
 * * https://www.ioccc.org/1996/rcm.hint
 *   https://www.ioccc.org/1996/rcm.c
 * * https://gist.github.com/bwoods/a6a467430ed1c5f3fa35d01212146fe7
 */

#include <stdio.h>  /* getchar() and putchar() */

short constW[] = { 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14,
                   1, 15 };
short constU[] = { 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
                   35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258 };
short constP[] = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3,
                  3, 4, 4, 4, 4, 5, 5, 5, 5, 0 };
short constQ[] = { 1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193,
                   257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145,
                   8193, 12289, 16385, 24577 };
short constL[] = { 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7,
                   8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13 };
short D, C, T, J, Y;
short Z[320];
short B[17];
short G[17];
short N[1998];
char S[32768];  /* Dictionary == lookback buffer. */

short mc_bitread(short arg) {
  short oo, f;
  if (arg) {
    if (Y+7<arg) {
      J+=((((getchar())&255))<<(Y));
      Y+=8;
    }
    if (Y<arg) {
      f=((getchar())&255);
      if (arg==16) {
        oo=J+((((f)&((1<<(16-Y))-1)))<<(Y));
        J=((f)>>(16-Y));
      } else {
        oo=((J+((f)<<(Y)))&((1<<(arg))-1));
        J=((f)>>(arg-Y));
      }
      Y+=8-arg;
    } else {
      oo=((J)&((1<<(arg))-1));
      Y-=arg;
      J=((((J)>>(arg)))&((1<<(Y))-1));
    }
  } else {
    oo=0;
  }
  return oo;
}
short mc_nalloc(void) {
  short o;
  o=D;
  D=N[o];
  N[o]=0;
  return o;
}
void mc_free(short arg) {
  if (arg!=0) {
    mc_free(N[arg]);
    mc_free(N[arg+1]);
    N[arg+1]=0;
    N[arg+2]=0;
    N[arg]=D;
    D=arg;
  }
}
short mc_descend(short arg) {
  while (N[arg]!=0) {
    if (mc_bitread(1)) {
      arg=N[arg+1];
    } else {
      arg=N[arg];
    }
  }
  return N[arg+2];
}
short mc_mktree(short arg) {
  short oo, q, o, f;
  B[0]=0; B[1]=0; B[2]=0; B[3]=0; B[4]=0; B[5]=0; B[6]=0; B[7]=0; B[8]=0;
  B[9]=0; B[10]=0; B[11]=0; B[12]=0; B[13]=0; B[14]=0; B[15]=0; B[16]=0;
  oo=0;
  while (oo<arg) { ((B[Z[oo]])++); oo++; }
  B[0]=0;
  G[0]=0;
  G[1]=((G[0]+B[0])<<1); G[2]=((G[1]+B[1])<<1);
  G[3]=((G[2]+B[2])<<1); G[4]=((G[3]+B[3])<<1);
  G[5]=((G[4]+B[4])<<1); G[6]=((G[5]+B[5])<<1);
  G[7]=((G[6]+B[6])<<1); G[8]=((G[7]+B[7])<<1);
  G[9]=((G[8]+B[8])<<1); G[10]=((G[9]+B[9])<<1);
  G[11]=((G[10]+B[10])<<1); G[12]=((G[11]+B[11])<<1);
  G[13]=((G[12]+B[12])<<1); G[14]=((G[13]+B[13])<<1);
  G[15]=((G[14]+B[14])<<1); G[16]=((G[15]+B[15])<<1);
  N[3]=0;
  oo=0;
  while (oo<arg) {
    if (Z[oo]) {
      q=G[Z[oo]];
      ((G[Z[oo]])++);
      f=3;
      o=Z[oo];
      while (o) {
        o--;
        if (N[f]==0) {
          N[f]=mc_nalloc();
        }
        if ((0!=((q)&(((1)<<(o)))))) {
          f=N[f]+1;
        } else {
          f=N[f]+0;
        }
      }
      N[f]=mc_nalloc();
      N[N[f]+2]=oo;
    }
    oo++;
  }
  return N[3];
}
void mc_write(short arg) {
  S[T]=arg;
  T++; T&=32767;
  if (T==C) {
    putchar(S[C]);
    C++; C&=32767;
  }
}
int main(int argc, char **argv) {
  short o, q, ty, oo, ooo, oooo, f, p, x, v, h, g;
  argc=argc+0; argv=argv+0;
  ty=3;
  while (ty!=4) {
    oo=0; ooo=0;
    J=0; Y=0; C=0; T=0;
    v=0; h=0;
    N[0]=0; N[1]=0; N[2]=0;
    N[3]=0; N[4]=0; N[5]=0;
    D=6;
    o=D;
    while (o<1998) {
      N[o]=o+3; o++;
      N[o]=0; o++;
      N[o]=0; o++;
    }
    ty=getchar();
    if ((0!=((512+ty)&(256)))) {
      ty=4;
    } else if (ty==120) {
      mc_bitread(8);
    } else if (ty==80) {
      mc_bitread(8);
      o=mc_bitread(8);
      ty=3;
      if (o==3) {
        mc_bitread(8);
        mc_bitread(16);
        mc_bitread(16);
        ty=mc_bitread(8);
        mc_bitread(8);
        mc_bitread(16); mc_bitread(16);
        mc_bitread(16); mc_bitread(16);
        oo=mc_bitread(8); oo+=((mc_bitread(8))<<(8));
        ooo=mc_bitread(8); ooo+=((mc_bitread(8))<<(8));
        mc_bitread(16); mc_bitread(16);
        f=mc_bitread(8); f+=((mc_bitread(8))<<(8));
        q=mc_bitread(8); q+=((mc_bitread(8))<<(8));
        while (f) { mc_bitread(8); f--; }
        while (q) { mc_bitread(8); q--; }
      } else if (o==7) {
        o=0; while (o<13) { mc_bitread(8); o++; }
      } else if (o==5) {
        o=0; while (o<17) { mc_bitread(8); o++; }
        o=mc_bitread(8); o+=((mc_bitread(8))<<(8));
        while (o) { mc_bitread(8); o--; }
      } else if (o==1) {
        oo=0; while (oo<25) { mc_bitread(8); oo++; }
        f=mc_bitread(8); f+=((mc_bitread(8))<<(8));
        o=mc_bitread(8); o+=((mc_bitread(8))<<(8));
        q=mc_bitread(8); q+=((mc_bitread(8))<<(8));
        oo=0; while (oo<12) { mc_bitread(8); oo++; }
        while (f) { mc_bitread(8); f--; }
        while (o) { mc_bitread(8); o--; }
        while (q) { mc_bitread(8); q--; }
      }
    } else if (ty==31) {
      mc_bitread(16);
      o=mc_bitread(8);
      mc_bitread(16); mc_bitread(16); mc_bitread(16);
      if ((0!=((o)&(2)))) {
        mc_bitread(16);
      }
      if ((0!=((o)&(4)))) {
        q=mc_bitread(16);
        while (q) { mc_bitread(8); q--; }
      }
      if ((0!=((o)&(8)))) {
        while (mc_bitread(8)) {}
      }
      if ((0!=((o)&(16)))) {
        while (mc_bitread(8)) {}
      }
      if ((0!=((o)&(32)))) {
        f=0; while (f<12) { mc_bitread(8); f++; }
      }
    }
    if (ty==0) {
      while (oo) { g=getchar(); putchar(g); oo--; }
      while (ooo) {
        g=getchar(); putchar(g);
        g=getchar(); putchar(g);
        oo=32767;
        while (oo) {
          g=getchar(); putchar(g);
          g=getchar(); putchar(g);
          oo--;
        }
        ooo--;
      }
    } else if (ty==4) {
    } else if (ty!=3) {
      o=0;
      while (o==0) {
        o=mc_bitread(1);
        q=mc_bitread(2);
        if (q) {
          if (q==1) {
            oo=288;
            while (oo) {
              oo--;
                if (oo<144) {
                  Z[oo]=8;
                } else if (oo<256) {
                  Z[oo]=9;
                } else if (oo<280) {
                  Z[oo]=7;
                } else {
                  Z[oo]=8;
                }
            }
            v=mc_mktree(288);
            Z[0]=5; Z[1]=5; Z[2]=5; Z[3]=5; Z[4]=5; Z[5]=5; Z[6]=5; Z[7]=5;
            Z[8]=5; Z[9]=5; Z[10]=5; Z[11]=5; Z[12]=5; Z[13]=5; Z[14]=5; Z[15]=5;
            Z[16]=5; Z[17]=5; Z[18]=5; Z[19]=5; Z[20]=5; Z[21]=5; Z[22]=5; Z[23]=5;
            Z[24]=5; Z[25]=5; Z[26]=5; Z[27]=5; Z[28]=5; Z[29]=5; Z[30]=5; Z[31]=5;
            h=mc_mktree(32);
          } else {
            p=mc_bitread(5)+257;
            x=mc_bitread(5)+1;
            v=mc_bitread(4)+4;
            oo=0;
            while (oo<v) { Z[constW[oo]]=mc_bitread(3); oo++; }
            while (oo<19) { Z[constW[oo]]=0; oo++; }
            v=mc_mktree(19);
            ooo=0;
            oo=0;
            while (oo<p+x) {
              oooo=mc_descend(v);
              if (oooo==16) {
                oooo=ooo; f=3+mc_bitread(2);
              } else if (oooo==17) {
                oooo=0; f=3+mc_bitread(3);
              } else if (oooo==18) {
                oooo=0; f=11+mc_bitread(7);
              } else {
                ooo=oooo; f=1;
              }
              q=f;
              while (q) { Z[oo]=oooo; oo++; q--; }
            }
            mc_free(v);
            v=mc_mktree(p);
            oo=x;
            while (oo) { oo--; Z[oo]=Z[oo+p]; }
            h=mc_mktree(x);
          }
          oo=mc_descend(v);
          while (oo!=256) {
            if (oo<257) {
              mc_write(oo);
            } else {
              oo-=257;
              f=constU[oo]+mc_bitread(constP[oo]);
              oo=mc_descend(h);
              oo=constQ[oo]+mc_bitread(constL[oo]);
              if (T<oo) {
                oo=32768-oo+T;
              } else {
                oo=T-oo;
              }
              while (f) {
                mc_write(S[oo]);
                oo++; oo&=32767;
                f--;
              }
            }
            oo=mc_descend(v);
          }
          mc_free(v);
          mc_free(h);
        } else {
          mc_bitread((Y&7));
          oo=mc_bitread(16);
          mc_bitread(16);
          while (oo) { mc_write(mc_bitread(8)); oo--; }
        }
      }
      while (C!=T) {
        putchar(S[C]);
        C++; C&=32767;
      }
    }
    mc_bitread(((Y)&7));
    if (ty==31) {
      mc_bitread(16); mc_bitread(16); mc_bitread(16); mc_bitread(16);
    } else if (ty==120) {
      mc_bitread(16); mc_bitread(16);
    }
  }
  return 0;
}
