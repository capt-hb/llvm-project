//===- MCXCOFFObjectStreamer.h - MCStreamer XCOFF Object File Interface ---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_MC_MCXCOFFSTREAMER_H
#define LLVM_MC_MCXCOFFSTREAMER_H

#include "llvm/MC/MCObjectStreamer.h"

namespace llvm {

class MCXCOFFStreamer : public MCObjectStreamer {
public:
  MCXCOFFStreamer(MCContext &Context, std::unique_ptr<MCAsmBackend> MAB,
                  std::unique_ptr<MCObjectWriter> OW,
                  std::unique_ptr<MCCodeEmitter> Emitter);

  bool EmitSymbolAttribute(MCSymbol *Symbol, MCSymbolAttr Attribute) override;
  void EmitCommonSymbol(MCSymbol *Symbol, uint64_t Size, unsigned ByteAlignment,
                        TailPaddingAmount TailPadding) override;
  void EmitZerofill(MCSection *Section, MCSymbol *Symbol, uint64_t Size,
                    unsigned ByteAlignment, TailPaddingAmount TailPadding,
                    SMLoc Loc = SMLoc()) override;
  void EmitInstToData(const MCInst &Inst, const MCSubtargetInfo &) override;
  void EmitXCOFFLocalCommonSymbol(MCSymbol *LabelSym, uint64_t Size,
                                  MCSymbol *CsectSym,
                                  unsigned ByteAlign) override;
};

} // end namespace llvm

#endif // LLVM_MC_MCXCOFFSTREAMER_H
