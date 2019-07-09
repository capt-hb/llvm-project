//===-- MipsSubtarget.cpp - Mips Subtarget Information --------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the Mips specific subclass of TargetSubtargetInfo.
//
//===----------------------------------------------------------------------===//

#include "MipsSubtarget.h"
#include "Mips.h"
#include "MipsMachineFunction.h"
#include "MipsRegisterInfo.h"
#include "MipsTargetMachine.h"
#include "MipsCallLowering.h"
#include "MipsLegalizerInfo.h"
#include "MipsRegisterBankInfo.h"
#include "llvm/IR/Attributes.h"
#include "llvm/IR/Function.h"
#include "llvm/CodeGen/MachineScheduler.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "mips-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "MipsGenSubtargetInfo.inc"

// FIXME: Maybe this should be on by default when Mips16 is specified
//
static cl::opt<bool>
    Mixed16_32("mips-mixed-16-32", cl::init(false),
               cl::desc("Allow for a mixture of Mips16 "
                        "and Mips32 code in a single output file"),
               cl::Hidden);

static cl::opt<bool> Mips_Os16("mips-os16", cl::init(false),
                               cl::desc("Compile all functions that don't use "
                                        "floating point as Mips 16"),
                               cl::Hidden);

static cl::opt<bool> Mips16HardFloat("mips16-hard-float", cl::NotHidden,
                                     cl::desc("Enable mips16 hard float."),
                                     cl::init(false));

static cl::opt<bool>
    Mips16ConstantIslands("mips16-constant-islands", cl::NotHidden,
                          cl::desc("Enable mips16 constant islands."),
                          cl::init(true));

static cl::opt<bool>
    GPOpt("mgpopt", cl::Hidden,
          cl::desc("Enable gp-relative addressing of mips small data items"));

static cl::opt<bool> CheriExactEqualsOpt(
    "cheri-exact-equals",
    cl::desc("CHERI: Capability equality comparisons are exact."),
    cl::init(false));

bool MipsSubtarget::DspWarningPrinted = false;
bool MipsSubtarget::MSAWarningPrinted = false;
bool MipsSubtarget::VirtWarningPrinted = false;
bool MipsSubtarget::CRCWarningPrinted = false;
bool MipsSubtarget::GINVWarningPrinted = false;

void MipsSubtarget::anchor() {}

MipsSubtarget::MipsSubtarget(const Triple &TT, StringRef CPU, StringRef FS,
                             bool little, const MipsTargetMachine &TM,
                             unsigned StackAlignOverride)
    : MipsGenSubtargetInfo(TT, CPU, FS), MipsArchVersion(MipsDefault),
      IsLittle(little), IsSoftFloat(false), IsSingleFloat(false), IsFPXX(false),
      NoABICalls(false), Abs2008(false), IsFP64bit(false), UseOddSPReg(true),
      IsNaN2008bit(false), IsGP64bit(false), HasVFPU(false), HasCnMips(false),
      HasMips3_32(false), HasMips3_32r2(false), HasMips4_32(false),
      HasMips4_32r2(false), HasMips5_32r2(false), IsCheri64(false),
      IsCheri128(false), IsCheri256(false), IsCheri(false), IsBeri(false),
      UseCheriExactEquals(CheriExactEqualsOpt), InMips16Mode(false),
      InMips16HardFloat(Mips16HardFloat), InMicroMipsMode(false), HasDSP(false),
      HasDSPR2(false), HasDSPR3(false), AllowMixed16_32(Mixed16_32 | Mips_Os16),
      Os16(Mips_Os16), HasMSA(false), UseTCCInDIV(false), HasSym32(false),
      HasEVA(false), DisableMadd4(false), HasMT(false), HasCRC(false),
      HasVirt(false), HasGINV(false), UseIndirectJumpsHazard(false),
      StackAlignOverride(StackAlignOverride), TM(TM), TargetTriple(TT),
      TSInfo(), InstrInfo(MipsInstrInfo::create(
                    initializeSubtargetDependencies(CPU, FS, TM))),
      FrameLowering(MipsFrameLowering::create(*this)),
      TLInfo(MipsTargetLowering::create(TM, *this)) {

  if (MipsArchVersion == MipsDefault)
    MipsArchVersion = Mips32;

  // Don't even attempt to generate code for MIPS-I and MIPS-V. They have not
  // been tested and currently exist for the integrated assembler only.
  if (MipsArchVersion == Mips1)
    report_fatal_error("Code generation for MIPS-I is not implemented", false);
  if (MipsArchVersion == Mips5)
    report_fatal_error("Code generation for MIPS-V is not implemented", false);

  // Check if Architecture and ABI are compatible.
  assert(((!isGP64bit() && isABI_O32()) ||
          (isGP64bit() && (isABI_N32() || isABI_N64()))) &&
         "Invalid  Arch & ABI pair.");

  if (hasMSA() && !isFP64bit())
    report_fatal_error("MSA requires a 64-bit FPU register file (FR=1 mode). "
                       "See -mattr=+fp64.",
                       false);

  if (isFP64bit() && !hasMips64() && hasMips32() && !hasMips32r2())
    report_fatal_error(
        "FPU with 64-bit registers is not available on MIPS32 pre revision 2. "
        "Use -mcpu=mips32r2 or greater.");

  if (!isABI_O32() && !useOddSPReg())
    report_fatal_error("-mattr=+nooddspreg requires the O32 ABI.", false);

  if (IsFPXX && (isABI_N32() || isABI_N64()))
    report_fatal_error("FPXX is not permitted for the N32/N64 ABI's.", false);

  if (hasMips64r6() && InMicroMipsMode)
    report_fatal_error("microMIPS64R6 is not supported", false);

  if (!isABI_O32() && InMicroMipsMode)
    report_fatal_error("microMIPS64 is not supported.", false);

  if (UseIndirectJumpsHazard) {
    if (InMicroMipsMode)
      report_fatal_error(
          "cannot combine indirect jumps with hazard barriers and microMIPS");
    if (!hasMips32r2())
      report_fatal_error(
          "indirect jumps with hazard barriers requires MIPS32R2 or later");
  }
  if (inAbs2008Mode() && hasMips32() && !hasMips32r2()) {
    report_fatal_error("IEEE 754-2008 abs.fmt is not supported for the given "
                       "architecture.",
                       false);
  }

  if (hasMips32r6()) {
    StringRef ISA = hasMips64r6() ? "MIPS64r6" : "MIPS32r6";

    assert(isFP64bit());
    assert(isNaN2008());
    assert(inAbs2008Mode());
    if (hasDSP())
      report_fatal_error(ISA + " is not compatible with the DSP ASE", false);
  }

  if (NoABICalls && TM.isPositionIndependent())
    report_fatal_error("position-independent code requires '-mabicalls'");

  if (isABI_N64() && !TM.isPositionIndependent() && !hasSym32())
    NoABICalls = true;

  // Set UseSmallSection.
  UseSmallSection = GPOpt;
  if (!NoABICalls && GPOpt) {
    errs() << "warning: cannot use small-data accesses for '-mabicalls'"
           << "\n";
    UseSmallSection = false;
  }

  if (hasDSPR2() && !DspWarningPrinted) {
    if (hasMips64() && !hasMips64r2()) {
      errs() << "warning: the 'dspr2' ASE requires MIPS64 revision 2 or "
             << "greater\n";
      DspWarningPrinted = true;
    } else if (hasMips32() && !hasMips32r2()) {
      errs() << "warning: the 'dspr2' ASE requires MIPS32 revision 2 or "
             << "greater\n";
      DspWarningPrinted = true;
    }
  } else if (hasDSP() && !DspWarningPrinted) {
    if (hasMips64() && !hasMips64r2()) {
      errs() << "warning: the 'dsp' ASE requires MIPS64 revision 2 or "
             << "greater\n";
      DspWarningPrinted = true;
    } else if (hasMips32() && !hasMips32r2()) {
      errs() << "warning: the 'dsp' ASE requires MIPS32 revision 2 or "
             << "greater\n";
      DspWarningPrinted = true;
    }
  }

  StringRef ArchName = hasMips64() ? "MIPS64" : "MIPS32";

  if (!hasMips32r5() && hasMSA() && !MSAWarningPrinted) {
    errs() << "warning: the 'msa' ASE requires " << ArchName
           << " revision 5 or greater\n";
    MSAWarningPrinted = true;
  }
  if (!hasMips32r5() && hasVirt() && !VirtWarningPrinted) {
    errs() << "warning: the 'virt' ASE requires " << ArchName
           << " revision 5 or greater\n";
    VirtWarningPrinted = true;
  }
  if (!hasMips32r6() && hasCRC() && !CRCWarningPrinted) {
    errs() << "warning: the 'crc' ASE requires " << ArchName
           << " revision 6 or greater\n";
    CRCWarningPrinted = true;
  }
  if (!hasMips32r6() && hasGINV() && !GINVWarningPrinted) {
    errs() << "warning: the 'ginv' ASE requires " << ArchName
           << " revision 6 or greater\n";
    GINVWarningPrinted = true;
  }

  CallLoweringInfo.reset(new MipsCallLowering(*getTargetLowering()));
  Legalizer.reset(new MipsLegalizerInfo(*this));

  auto *RBI = new MipsRegisterBankInfo(*getRegisterInfo());
  RegBankInfo.reset(RBI);
  InstSelector.reset(createMipsInstructionSelector(
      *static_cast<const MipsTargetMachine *>(&TM), *this, *RBI));
}

bool MipsSubtarget::isPositionIndependent() const {
  return TM.isPositionIndependent();
}

/// This overrides the PostRAScheduler bit in the SchedModel for any CPU.
bool MipsSubtarget::enablePostRAScheduler() const { return true; }

void MipsSubtarget::getCriticalPathRCs(RegClassVector &CriticalPathRCs) const {
  CriticalPathRCs.clear();
  CriticalPathRCs.push_back(isGP64bit() ? &Mips::GPR64RegClass
                                        : &Mips::GPR32RegClass);
  if (IsCheri)
    CriticalPathRCs.push_back(&Mips::CheriGPROrCNullRegClass);
}

CodeGenOpt::Level MipsSubtarget::getOptLevelToEnablePostRAScheduler() const {
  return CodeGenOpt::Aggressive;
}

MipsSubtarget &
MipsSubtarget::initializeSubtargetDependencies(StringRef CPU, StringRef FS,
                                               const TargetMachine &TM) {
  std::string CPUName = MIPS_MC::selectMipsCPU(TM.getTargetTriple(), CPU);
  std::string CheriFeatures;
  // enable capabilties for all cheri-*-* triples even if CPUName != cheri
  if (TM.getTargetTriple().getArch() == llvm::Triple::cheri) {
    if (FS.empty())
      FS = "+chericap,+cheri128";
    else {
      CheriFeatures = FS;
      CheriFeatures += ",+chericap";
      if (!FS.contains("+cheri128") && !FS.contains("+cheri64"))
        CheriFeatures += ",+cheri256";
      FS = CheriFeatures;
    }
  }

  // Parse features string.
  ParseSubtargetFeatures(CPUName, FS);
  // Initialize scheduling itinerary for the specified CPU.
  InstrItins = getInstrItineraryForCPU(CPUName);

  if (InMips16Mode && !IsSoftFloat)
    InMips16HardFloat = true;

  if (StackAlignOverride)
    stackAlignment = StackAlignOverride;
  else if (isCheri()) {
    if (isCheri128())
      stackAlignment = 16;
    else
      stackAlignment = 32;
  } else if (isABI_N32() || isABI_N64())
    stackAlignment = 16;
  else {
    assert(isABI_O32() && "Unknown ABI for stack alignment!");
    stackAlignment = 8;
  }

  return *this;
}

bool MipsSubtarget::useConstantIslands() {
  LLVM_DEBUG(dbgs() << "use constant islands " << Mips16ConstantIslands
                    << "\n");
  return Mips16ConstantIslands;
}

Reloc::Model MipsSubtarget::getRelocationModel() const {
  return TM.getRelocationModel();
}

bool MipsSubtarget::isABI_N64() const { return getABI().IsN64(); }
bool MipsSubtarget::isABI_N32() const { return getABI().IsN32(); }
bool MipsSubtarget::isABI_O32() const { return getABI().IsO32(); }
bool MipsSubtarget::isABI_CheriPureCap() const {
  return getABI().IsCheriPureCap();
}
const MipsABIInfo &MipsSubtarget::getABI() const { return TM.getABI(); }

const CallLowering *MipsSubtarget::getCallLowering() const {
  return CallLoweringInfo.get();
}

const LegalizerInfo *MipsSubtarget::getLegalizerInfo() const {
  return Legalizer.get();
}

const RegisterBankInfo *MipsSubtarget::getRegBankInfo() const {
  return RegBankInfo.get();
}

void MipsSubtarget::overrideSchedPolicy(MachineSchedPolicy &Policy,
                                        unsigned NumRegionInstrs) const {
  // copied from AMDGPU:
#if 0

  // Track register pressure so the scheduler can try to decrease
  // pressure once register usage is above the threshold defined by
  // SIRegisterInfo::getRegPressureSetLimit()
  Policy.ShouldTrackPressure = true;
  // Enabling both top down and bottom up scheduling seems to give us less
  // register spills than just using one of these approaches on its own.
  Policy.OnlyTopDown = false;
  Policy.OnlyBottomUp = true;

  Policy.ShouldTrackLaneMasks = false;
  Policy.DisableLatencyHeuristic = true;
#endif
}

const InstructionSelector *MipsSubtarget::getInstructionSelector() const {
  return InstSelector.get();
}
