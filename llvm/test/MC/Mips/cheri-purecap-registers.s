# RUN: %cheri_purecap_llvm-mc -show-encoding %s | FileCheck %s
# CHECK: cld	$1, $zero, 0($c0)
cld $1, $zero, 0($ddc)
# CHECK: cld	$1, $zero, 0($c11)
cld $1, $zero, 0($csp)
# CHECK: cld	$1, $zero, 0($c25)
cld $1, $zero, 0($cbp)
# CHECK: cld	$1, $zero, 0($c24)
cld $1, $zero, 0($cfp)
# CHECK: cld	$1, $zero, 0($c26)
cld $1, $zero, 0($cgp)
