// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_store_buffer_cmo_metadata.h for the primary calling header

#include "Vtb_store_buffer_cmo_metadata__pch.h"

void Vtb_store_buffer_cmo_metadata___024root___ctor_var_reset(Vtb_store_buffer_cmo_metadata___024root* vlSelf);

Vtb_store_buffer_cmo_metadata___024root::Vtb_store_buffer_cmo_metadata___024root(Vtb_store_buffer_cmo_metadata__Syms* symsp, const char* namep)
    : __VdlySched{*symsp->_vm_contextp__}
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vtb_store_buffer_cmo_metadata___024root___ctor_var_reset(this);
}

Vtb_store_buffer_cmo_metadata___024root::~Vtb_store_buffer_cmo_metadata___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
