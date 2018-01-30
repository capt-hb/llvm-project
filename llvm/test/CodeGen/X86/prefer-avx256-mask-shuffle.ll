; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512vl,+prefer-256-bit | FileCheck %s --check-prefix=CHECK --check-prefix=AVX256 --check-prefix=AVX256VL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512vl,-prefer-256-bit | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512 --check-prefix=AVX512NOBW --check-prefix=AVX512VL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl,+prefer-256-bit | FileCheck %s --check-prefix=CHECK --check-prefix=AVX256 --check-prefix=AVX256VLBW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl,-prefer-256-bit | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512 --check-prefix=AVX512VLBW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+prefer-256-bit | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512 --check-prefix=AVX512NOBW --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,-prefer-256-bit | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512 --check-prefix=AVX512NOBW --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+prefer-256-bit | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512 --check-prefix=AVX512BW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,-prefer-256-bit | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512 --check-prefix=AVX512BW

define <16 x i1> @shuf16i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0(<8 x i32>* %a, <8 x i32>* %b) {
; AVX256VL-LABEL: shuf16i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX256VL:       # %bb.0:
; AVX256VL-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; AVX256VL-NEXT:    vpcmpeqd (%rdi), %ymm0, %k1
; AVX256VL-NEXT:    vpcmpeqd (%rsi), %ymm0, %k2
; AVX256VL-NEXT:    vpcmpeqd %ymm0, %ymm0, %ymm0
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm1 {%k2} {z}
; AVX256VL-NEXT:    vpmovdw %ymm1, %xmm1
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm2 {%k1} {z}
; AVX256VL-NEXT:    vpmovdw %ymm2, %xmm2
; AVX256VL-NEXT:    vpblendw {{.*#+}} xmm3 = xmm2[0,1],xmm1[2],xmm2[3],xmm1[4],xmm2[5,6,7]
; AVX256VL-NEXT:    vpshufb {{.*#+}} xmm3 = xmm3[6,7,12,13,4,5,8,9,6,7,14,15,14,15,0,1]
; AVX256VL-NEXT:    vpmovsxwd %xmm3, %ymm3
; AVX256VL-NEXT:    vpslld $31, %ymm3, %ymm3
; AVX256VL-NEXT:    vptestmd %ymm3, %ymm3, %k1
; AVX256VL-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[0,2,1,3]
; AVX256VL-NEXT:    vpshufb {{.*#+}} xmm2 = xmm2[6,7,12,13,2,3,14,15,6,7,6,7,14,15,0,1]
; AVX256VL-NEXT:    vpblendw {{.*#+}} xmm1 = xmm2[0,1,2],xmm1[3],xmm2[4],xmm1[5],xmm2[6,7]
; AVX256VL-NEXT:    vpmovsxwd %xmm1, %ymm1
; AVX256VL-NEXT:    vpslld $31, %ymm1, %ymm1
; AVX256VL-NEXT:    vptestmd %ymm1, %ymm1, %k0
; AVX256VL-NEXT:    kunpckbw %k1, %k0, %k0
; AVX256VL-NEXT:    kshiftrw $8, %k0, %k2
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm1 {%k2} {z}
; AVX256VL-NEXT:    vpmovdw %ymm1, %xmm1
; AVX256VL-NEXT:    vpacksswb %xmm0, %xmm1, %xmm1
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm0 {%k1} {z}
; AVX256VL-NEXT:    vpmovdw %ymm0, %xmm0
; AVX256VL-NEXT:    vpacksswb %xmm0, %xmm0, %xmm0
; AVX256VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX256VL-NEXT:    vzeroupper
; AVX256VL-NEXT:    retq
;
; AVX512VL-LABEL: shuf16i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; AVX512VL-NEXT:    vpcmpeqd (%rdi), %ymm0, %k1
; AVX512VL-NEXT:    vpcmpeqd (%rsi), %ymm0, %k2
; AVX512VL-NEXT:    vpternlogd $255, %zmm0, %zmm0, %zmm0 {%k2} {z}
; AVX512VL-NEXT:    vpternlogd $255, %zmm1, %zmm1, %zmm1 {%k1} {z}
; AVX512VL-NEXT:    vmovdqa64 {{.*#+}} zmm2 = [3,6,18,20,3,7,7,0,3,6,1,21,3,19,7,0]
; AVX512VL-NEXT:    vpermi2d %zmm0, %zmm1, %zmm2
; AVX512VL-NEXT:    vptestmd %zmm2, %zmm2, %k1
; AVX512VL-NEXT:    vpternlogd $255, %zmm0, %zmm0, %zmm0 {%k1} {z}
; AVX512VL-NEXT:    vpmovdb %zmm0, %xmm0
; AVX512VL-NEXT:    vzeroupper
; AVX512VL-NEXT:    retq
;
; AVX256VLBW-LABEL: shuf16i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX256VLBW:       # %bb.0:
; AVX256VLBW-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; AVX256VLBW-NEXT:    vpcmpeqd (%rdi), %ymm0, %k0
; AVX256VLBW-NEXT:    vpcmpeqd (%rsi), %ymm0, %k1
; AVX256VLBW-NEXT:    vpmovm2w %k1, %ymm0
; AVX256VLBW-NEXT:    vpmovm2w %k0, %ymm1
; AVX256VLBW-NEXT:    vmovdqa {{.*#+}} ymm2 = [3,6,18,20,3,7,7,0,3,6,1,21,3,19,7,0]
; AVX256VLBW-NEXT:    vpermi2w %ymm0, %ymm1, %ymm2
; AVX256VLBW-NEXT:    vpmovw2m %ymm2, %k0
; AVX256VLBW-NEXT:    vpmovm2b %k0, %xmm0
; AVX256VLBW-NEXT:    vzeroupper
; AVX256VLBW-NEXT:    retq
;
; AVX512VLBW-LABEL: shuf16i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX512VLBW:       # %bb.0:
; AVX512VLBW-NEXT:    vpxor %xmm0, %xmm0, %xmm0
; AVX512VLBW-NEXT:    vpcmpeqd (%rdi), %ymm0, %k1
; AVX512VLBW-NEXT:    vpcmpeqd (%rsi), %ymm0, %k2
; AVX512VLBW-NEXT:    vpternlogd $255, %zmm0, %zmm0, %zmm0 {%k2} {z}
; AVX512VLBW-NEXT:    vpternlogd $255, %zmm1, %zmm1, %zmm1 {%k1} {z}
; AVX512VLBW-NEXT:    vmovdqa64 {{.*#+}} zmm2 = [3,6,18,20,3,7,7,0,3,6,1,21,3,19,7,0]
; AVX512VLBW-NEXT:    vpermi2d %zmm0, %zmm1, %zmm2
; AVX512VLBW-NEXT:    vptestmd %zmm2, %zmm2, %k0
; AVX512VLBW-NEXT:    vpmovm2b %k0, %xmm0
; AVX512VLBW-NEXT:    vzeroupper
; AVX512VLBW-NEXT:    retq
;
; AVX512F-LABEL: shuf16i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512F-NEXT:    vmovdqa (%rsi), %ymm1
; AVX512F-NEXT:    vptestnmd %zmm0, %zmm0, %k1
; AVX512F-NEXT:    vptestnmd %zmm1, %zmm1, %k2
; AVX512F-NEXT:    vpternlogd $255, %zmm0, %zmm0, %zmm0 {%k2} {z}
; AVX512F-NEXT:    vpternlogd $255, %zmm1, %zmm1, %zmm1 {%k1} {z}
; AVX512F-NEXT:    vmovdqa64 {{.*#+}} zmm2 = [3,6,18,20,3,7,7,0,3,6,1,21,3,19,7,0]
; AVX512F-NEXT:    vpermi2d %zmm0, %zmm1, %zmm2
; AVX512F-NEXT:    vptestmd %zmm2, %zmm2, %k1
; AVX512F-NEXT:    vpternlogd $255, %zmm0, %zmm0, %zmm0 {%k1} {z}
; AVX512F-NEXT:    vpmovdb %zmm0, %xmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: shuf16i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    vmovdqa (%rdi), %ymm0
; AVX512BW-NEXT:    vmovdqa (%rsi), %ymm1
; AVX512BW-NEXT:    vptestnmd %zmm0, %zmm0, %k1
; AVX512BW-NEXT:    vptestnmd %zmm1, %zmm1, %k2
; AVX512BW-NEXT:    vpternlogd $255, %zmm0, %zmm0, %zmm0 {%k2} {z}
; AVX512BW-NEXT:    vpternlogd $255, %zmm1, %zmm1, %zmm1 {%k1} {z}
; AVX512BW-NEXT:    vmovdqa64 {{.*#+}} zmm2 = [3,6,18,20,3,7,7,0,3,6,1,21,3,19,7,0]
; AVX512BW-NEXT:    vpermi2d %zmm0, %zmm1, %zmm2
; AVX512BW-NEXT:    vptestmd %zmm2, %zmm2, %k0
; AVX512BW-NEXT:    vpmovm2b %k0, %zmm0
; AVX512BW-NEXT:    # kill: def %xmm0 killed %xmm0 killed %zmm0
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq

  %a1 = load <8 x i32>, <8 x i32>* %a
  %b1 = load <8 x i32>, <8 x i32>* %b
  %a2 = icmp eq <8 x i32> %a1, zeroinitializer
  %b2 = icmp eq <8 x i32> %b1, zeroinitializer
  %c = shufflevector <8 x i1> %a2, <8 x i1> %b2, <16 x i32> <i32 3, i32 6, i32 10, i32 12, i32 3, i32 7, i32 7, i32 0, i32 3, i32 6, i32 1, i32 13, i32 3, i32 11, i32 7, i32 0>
  ret <16 x i1> %c
}

define <32 x i1> @shuf32i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0(<32 x i8> %a) {
; AVX256VL-LABEL: shuf32i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX256VL:       # %bb.0:
; AVX256VL-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX256VL-NEXT:    vpcmpeqb %ymm1, %ymm0, %ymm0
; AVX256VL-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX256VL-NEXT:    vpmovsxbw %xmm1, %ymm1
; AVX256VL-NEXT:    vpmovsxwd %xmm1, %ymm1
; AVX256VL-NEXT:    vptestmd %ymm1, %ymm1, %k1
; AVX256VL-NEXT:    vpmovsxbw %xmm0, %ymm0
; AVX256VL-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX256VL-NEXT:    vpmovsxwd %xmm1, %ymm1
; AVX256VL-NEXT:    vptestmd %ymm1, %ymm1, %k2
; AVX256VL-NEXT:    vpmovsxwd %xmm0, %ymm0
; AVX256VL-NEXT:    vptestmd %ymm0, %ymm0, %k3
; AVX256VL-NEXT:    vpcmpeqd %ymm0, %ymm0, %ymm0
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm1 {%k3} {z}
; AVX256VL-NEXT:    vpmovdw %ymm1, %xmm1
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm2 {%k2} {z}
; AVX256VL-NEXT:    vpmovdw %ymm2, %xmm2
; AVX256VL-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; AVX256VL-NEXT:    vpermq {{.*#+}} ymm2 = ymm1[2,3,0,1]
; AVX256VL-NEXT:    vpblendd {{.*#+}} ymm1 = ymm1[0,1],ymm2[2],ymm1[3],ymm2[4,5],ymm1[6],ymm2[7]
; AVX256VL-NEXT:    vpshufb {{.*#+}} ymm1 = ymm1[6,7,12,13,u,u,8,9,6,7,14,15,14,15,0,1,22,23,28,29,18,19,26,27,22,23,u,u,30,31,16,17]
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm2 {%k1} {z}
; AVX256VL-NEXT:    vpmovdw %ymm2, %xmm2
; AVX256VL-NEXT:    kshiftrw $8, %k1, %k1
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm3 {%k1} {z}
; AVX256VL-NEXT:    vpmovdw %ymm3, %xmm3
; AVX256VL-NEXT:    vinserti128 $1, %xmm3, %ymm2, %ymm2
; AVX256VL-NEXT:    vpermq {{.*#+}} ymm2 = ymm2[1,1,2,1]
; AVX256VL-NEXT:    vmovdqa {{.*#+}} ymm3 = [255,255,255,255,0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0,255,255,255,255]
; AVX256VL-NEXT:    vpblendvb %ymm3, %ymm1, %ymm2, %ymm1
; AVX256VL-NEXT:    vpmovsxwd %xmm1, %ymm2
; AVX256VL-NEXT:    vpslld $31, %ymm2, %ymm2
; AVX256VL-NEXT:    vptestmd %ymm2, %ymm2, %k1
; AVX256VL-NEXT:    vextracti128 $1, %ymm1, %xmm1
; AVX256VL-NEXT:    vpmovsxwd %xmm1, %ymm1
; AVX256VL-NEXT:    vpslld $31, %ymm1, %ymm1
; AVX256VL-NEXT:    vptestmd %ymm1, %ymm1, %k0
; AVX256VL-NEXT:    kunpckbw %k1, %k0, %k0
; AVX256VL-NEXT:    kshiftrw $8, %k0, %k2
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm1 {%k2} {z}
; AVX256VL-NEXT:    vpmovdw %ymm1, %xmm1
; AVX256VL-NEXT:    vpacksswb %xmm0, %xmm1, %xmm1
; AVX256VL-NEXT:    vmovdqa32 %ymm0, %ymm0 {%k1} {z}
; AVX256VL-NEXT:    vpmovdw %ymm0, %xmm0
; AVX256VL-NEXT:    vpacksswb %xmm0, %xmm0, %xmm0
; AVX256VL-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; AVX256VL-NEXT:    vinserti128 $1, %xmm0, %ymm0, %ymm0
; AVX256VL-NEXT:    retq
;
; AVX512NOBW-LABEL: shuf32i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX512NOBW:       # %bb.0:
; AVX512NOBW-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512NOBW-NEXT:    vpcmpeqb %ymm1, %ymm0, %ymm0
; AVX512NOBW-NEXT:    vpmovsxbd %xmm0, %zmm1
; AVX512NOBW-NEXT:    vptestmd %zmm1, %zmm1, %k1
; AVX512NOBW-NEXT:    vextracti128 $1, %ymm0, %xmm0
; AVX512NOBW-NEXT:    vpmovsxbd %xmm0, %zmm0
; AVX512NOBW-NEXT:    vptestmd %zmm0, %zmm0, %k2
; AVX512NOBW-NEXT:    vpternlogd $255, %zmm0, %zmm0, %zmm0 {%k2} {z}
; AVX512NOBW-NEXT:    vpternlogd $255, %zmm1, %zmm1, %zmm1 {%k1} {z}
; AVX512NOBW-NEXT:    vmovdqa64 {{.*#+}} zmm2 = [3,6,22,12,3,7,7,0,3,6,1,13,3,21,7,0]
; AVX512NOBW-NEXT:    vpermi2d %zmm0, %zmm1, %zmm2
; AVX512NOBW-NEXT:    vptestmd %zmm2, %zmm2, %k1
; AVX512NOBW-NEXT:    vpternlogd $255, %zmm0, %zmm0, %zmm0 {%k1} {z}
; AVX512NOBW-NEXT:    vpmovdb %zmm0, %xmm0
; AVX512NOBW-NEXT:    vinserti128 $1, %xmm0, %ymm0, %ymm0
; AVX512NOBW-NEXT:    retq
;
; AVX256VLBW-LABEL: shuf32i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX256VLBW:       # %bb.0:
; AVX256VLBW-NEXT:    vptestnmb %ymm0, %ymm0, %k0
; AVX256VLBW-NEXT:    vpmovm2b %k0, %ymm0
; AVX256VLBW-NEXT:    vpermq {{.*#+}} ymm1 = ymm0[2,3,0,1]
; AVX256VLBW-NEXT:    vpshufb {{.*#+}} ymm0 = ymm0[3,6,u,12,3,7,7,0,3,6,1,13,3,u,7,0,u,u,22,u,u,u,u,u,u,u,u,u,u,21,u,u]
; AVX256VLBW-NEXT:    movl $-537190396, %eax # imm = 0xDFFB2004
; AVX256VLBW-NEXT:    kmovd %eax, %k1
; AVX256VLBW-NEXT:    vpshufb {{.*#+}} ymm0 {%k1} = ymm1[u,u,6,u,u,u,u,u,u,u,u,u,u,5,u,u,19,22,u,28,19,23,23,16,19,22,17,29,19,u,23,16]
; AVX256VLBW-NEXT:    vpmovb2m %ymm0, %k0
; AVX256VLBW-NEXT:    vpmovm2b %k0, %ymm0
; AVX256VLBW-NEXT:    retq
;
; AVX512VLBW-LABEL: shuf32i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX512VLBW:       # %bb.0:
; AVX512VLBW-NEXT:    vptestnmb %ymm0, %ymm0, %k0
; AVX512VLBW-NEXT:    vpmovm2w %k0, %zmm0
; AVX512VLBW-NEXT:    vmovdqa64 {{.*#+}} zmm1 = [3,6,22,12,3,7,7,0,3,6,1,13,3,21,7,0,3,6,22,12,3,7,7,0,3,6,1,13,3,21,7,0]
; AVX512VLBW-NEXT:    vpermw %zmm0, %zmm1, %zmm0
; AVX512VLBW-NEXT:    vpmovw2m %zmm0, %k0
; AVX512VLBW-NEXT:    vpmovm2b %k0, %ymm0
; AVX512VLBW-NEXT:    retq
;
; AVX512BW-LABEL: shuf32i1_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0_3_6_22_12_3_7_7_0_3_6_1_13_3_21_7_0:
; AVX512BW:       # %bb.0:
; AVX512BW-NEXT:    # kill: def %ymm0 killed %ymm0 def %zmm0
; AVX512BW-NEXT:    vptestnmb %zmm0, %zmm0, %k0
; AVX512BW-NEXT:    vpmovm2w %k0, %zmm0
; AVX512BW-NEXT:    vmovdqa64 {{.*#+}} zmm1 = [3,6,22,12,3,7,7,0,3,6,1,13,3,21,7,0,3,6,22,12,3,7,7,0,3,6,1,13,3,21,7,0]
; AVX512BW-NEXT:    vpermw %zmm0, %zmm1, %zmm0
; AVX512BW-NEXT:    vpmovw2m %zmm0, %k0
; AVX512BW-NEXT:    vpmovm2b %k0, %zmm0
; AVX512BW-NEXT:    # kill: def %ymm0 killed %ymm0 killed %zmm0
; AVX512BW-NEXT:    retq
  %cmp = icmp eq <32 x i8> %a, zeroinitializer
  %b = shufflevector <32 x i1> %cmp, <32 x i1> undef, <32 x i32> <i32 3, i32 6, i32 22, i32 12, i32 3, i32 7, i32 7, i32 0, i32 3, i32 6, i32 1, i32 13, i32 3, i32 21, i32 7, i32 0, i32 3, i32 6, i32 22, i32 12, i32 3, i32 7, i32 7, i32 0, i32 3, i32 6, i32 1, i32 13, i32 3, i32 21, i32 7, i32 0>
  ret <32 x i1> %b
}

