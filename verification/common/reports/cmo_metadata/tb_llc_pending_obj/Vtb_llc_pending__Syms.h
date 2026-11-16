// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VTB_LLC_PENDING__SYMS_H_
#define VERILATED_VTB_LLC_PENDING__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vtb_llc_pending.h"

// INCLUDE MODULE CLASSES
#include "Vtb_llc_pending___024root.h"

// DPI TYPES for DPI Export callbacks (Internal use)

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vtb_llc_pending__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vtb_llc_pending* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool& __Vm_didInit;

    // MODULE INSTANCE STATE
    Vtb_llc_pending___024root      TOP;

    // SCOPE NAMES
    VerilatedScope* __Vscopep_tb_llc_pending;
    VerilatedScope* __Vscopep_tb_llc_pending__receive;
    VerilatedScope* __Vscopep_tb_llc_pending__unnamedblk2;
    VerilatedScope* __Vscopep_tb_llc_pending__unnamedblk2__unnamedblk1_2;

    // CONSTRUCTORS
    Vtb_llc_pending__Syms(VerilatedContext* contextp, const char* namep, Vtb_llc_pending* modelp);
    ~Vtb_llc_pending__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
