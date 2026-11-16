// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_cmo_ccu.h for the primary calling header

#include "Vtb_cmo_ccu__pch.h"

void Vtb_cmo_ccu___024root___ctor_var_reset(Vtb_cmo_ccu___024root* vlSelf);

Vtb_cmo_ccu___024root::Vtb_cmo_ccu___024root(Vtb_cmo_ccu__Syms* symsp, const char* namep)
    : __VdlySched{*symsp->_vm_contextp__}
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vtb_cmo_ccu___024root___ctor_var_reset(this);
}

Vtb_cmo_ccu___024root::~Vtb_cmo_ccu___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
