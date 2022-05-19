void __cdecl    myfun_c(void) {}  /* wcc -ecc */
void __stdcall  myfun_d(void) {}  /* wcc -ecd */
void __fastcall myfun_f(void) {}  /* wcc -ecf */
void __pascal   myfun_p(void) {}  /* wcc -ecp */
void __fortran  myfun_r(void) {}  /* wcc -ecr */
void __syscall  myfun_s(void) {}  /* wcc -ecs */
void __watcall  myfun_w(void) {}  /* wcc -ecw, default. */
