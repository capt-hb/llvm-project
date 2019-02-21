# Check that capability relocations in .rodata sections cause errors (since they
# will trap when being processed at runtime). This is true both for static as well
# as dynamic binaries. Currently the kernel just gives us a read-write mapping to
# work around this but we really should just make this an error

# RUN: %cheri_purecap_llvm-mc %s -filetype=obj -o %t.o
# RUNNOT: llvm-readobj -r %t.o
# RUN: not ld.lld -shared %t.o -o %t.so 2>&1 | FileCheck %s
# RUN: ld.lld -shared %t.o -o %t.so -z notext
# RUN: llvm-readobj --cap-relocs %t.so | FileCheck %s -check-prefix SHLIB
# RUN: not ld.lld -static %t.o -o %t.exe 2>&1 | FileCheck %s
# RUN: ld.lld -static %t.o -o %t.exe -z notext
# RUN: llvm-readobj --cap-relocs %t.exe | FileCheck %s -check-prefix EXE

.text
.global __start
.protected __start
.ent __start
__start:
  nop
  nop
  nop
  nop
.end __start

.rodata
.space 16

.type	foo,@object
.global foo
.p2align 5
foo:
  .chericap __start + 0x4
# CHECK: error: attempting to add a capability relocation against symbol __start in a read-only section; pass -Wl,-z,notext if you really want to do this
# CHECK-NEXT: >>> referenced by object foo
# CHECK-NEXT: >>> defined in  ({{.+}}capability-in-rodata.s.tmp.o:(.rodata+0x20))

# EXE: CHERI __cap_relocs [
# EXE-NEXT: 0x{{[0-9a-f]+}} (foo)           Base: 0x120010000 (__start+4) Length: 16 Perms: Function
# EXE-NEXT: ]

# SHLIB: CHERI __cap_relocs [
# SHLIB-NEXT: 0x{{[0-9a-f]+}} (foo)           Base: 0x10000 (__start+4) Length: 16 Perms: Function
# SHLIB-NEXT: ]
