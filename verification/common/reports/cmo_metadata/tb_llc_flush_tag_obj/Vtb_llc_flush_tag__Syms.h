// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VTB_LLC_FLUSH_TAG__SYMS_H_
#define VERILATED_VTB_LLC_FLUSH_TAG__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vtb_llc_flush_tag.h"

// INCLUDE MODULE CLASSES
#include "Vtb_llc_flush_tag___024root.h"

// DPI TYPES for DPI Export callbacks (Internal use)

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vtb_llc_flush_tag__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vtb_llc_flush_tag* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool& __Vm_didInit;

    // MODULE INSTANCE STATE
    Vtb_llc_flush_tag___024root    TOP;

    // SCOPE NAMES
    VerilatedScope* __Vscopep_tb_llc_flush_tag;
    VerilatedScope* __Vscopep_tb_llc_flush_tag__receive;
    VerilatedScope* __Vscopep_tb_llc_flush_tag__unnamedblk1_2;
    VerilatedScope* __Vscopep_tb_llc_flush_tag__unnamedblk1_3;
    VerilatedScope* __Vscopep_tb_llc_flush_tag__unnamedblk1_4;
    VerilatedScope* __Vscopep_tb_llc_flush_tag__unnamedblk1_5;
    VerilatedScope* __Vscopep_tb_llc_flush_tag__writer__i_r_data_fifo;
    VerilatedScope* __Vscopep_tb_llc_flush_tag__writer__i_r_data_fifo__full_write;

    // CONSTRUCTORS
    Vtb_llc_flush_tag__Syms(VerilatedContext* contextp, const char* namep, Vtb_llc_flush_tag* modelp);
    ~Vtb_llc_flush_tag__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
