// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_llc_pending.h for the primary calling header

#include "Vtb_llc_pending__pch.h"

void Vtb_llc_pending___024root___ctor_var_reset(Vtb_llc_pending___024root* vlSelf);

Vtb_llc_pending___024root::Vtb_llc_pending___024root(Vtb_llc_pending__Syms* symsp, const char* namep)
    : __VdlySched{*symsp->_vm_contextp__}
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vtb_llc_pending___024root___ctor_var_reset(this);
}

Vtb_llc_pending___024root::~Vtb_llc_pending___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
