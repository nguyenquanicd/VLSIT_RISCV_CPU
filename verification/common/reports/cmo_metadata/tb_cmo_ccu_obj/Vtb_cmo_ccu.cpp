// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vtb_cmo_ccu__pch.h"

//============================================================
// Constructors

Vtb_cmo_ccu::Vtb_cmo_ccu(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vtb_cmo_ccu__Syms(contextp(), _vcname__, this)}
    , m_evalLoop{*this, /*convergeLimit:*/ 10000}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vtb_cmo_ccu::Vtb_cmo_ccu(const char* _vcname__)
    : Vtb_cmo_ccu(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vtb_cmo_ccu::~Vtb_cmo_ccu() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vtb_cmo_ccu___024root___eval_debug_assertions(Vtb_cmo_ccu___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void Vtb_cmo_ccu___024root___eval_static(Vtb_cmo_ccu___024root* vlSelf);
void Vtb_cmo_ccu___024root___eval_initial(Vtb_cmo_ccu___024root* vlSelf);
VL_ATTR_COLD bool Vtb_cmo_ccu___024root___eval_stl(Vtb_cmo_ccu___024root* vlSelf, CData/*0:0*/ firstIteration);
void Vtb_cmo_ccu___024root___eval_sample(Vtb_cmo_ccu___024root* vlSelf);
bool Vtb_cmo_ccu___024root___eval_ico(Vtb_cmo_ccu___024root* vlSelf, CData/*0:0*/ firstIteration);
bool Vtb_cmo_ccu___024root___eval_act(Vtb_cmo_ccu___024root* vlSelf);
bool Vtb_cmo_ccu___024root___eval_inact(Vtb_cmo_ccu___024root* vlSelf);
bool Vtb_cmo_ccu___024root___eval_nba(Vtb_cmo_ccu___024root* vlSelf);
bool Vtb_cmo_ccu___024root___eval_obs(Vtb_cmo_ccu___024root* vlSelf);
bool Vtb_cmo_ccu___024root___eval_react(Vtb_cmo_ccu___024root* vlSelf);
void Vtb_cmo_ccu___024root___eval_postponed(Vtb_cmo_ccu___024root* vlSelf);
VL_ATTR_COLD void Vtb_cmo_ccu___024root___eval_final(Vtb_cmo_ccu___024root* vlSelf);
VL_ATTR_COLD void Vtb_cmo_ccu___024root___eval_dump_triggers__stl(Vtb_cmo_ccu___024root* vlSelf);
VL_ATTR_COLD void Vtb_cmo_ccu___024root___eval_dump_triggers__ico(Vtb_cmo_ccu___024root* vlSelf);
VL_ATTR_COLD void Vtb_cmo_ccu___024root___eval_dump_triggers__act(Vtb_cmo_ccu___024root* vlSelf);
VL_ATTR_COLD void Vtb_cmo_ccu___024root___eval_dump_triggers__nba(Vtb_cmo_ccu___024root* vlSelf);
VL_ATTR_COLD void Vtb_cmo_ccu___024root___eval_dump_triggers__obs(Vtb_cmo_ccu___024root* vlSelf);
VL_ATTR_COLD void Vtb_cmo_ccu___024root___eval_dump_triggers__react(Vtb_cmo_ccu___024root* vlSelf);

void Vtb_cmo_ccu::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtb_cmo_ccu::eval_step\n"); );
    m_evalLoop.eval();
}

void Vtb_cmo_ccu::evalBegin() {
#ifdef VL_DEBUG
    // Debug assertions
    Vtb_cmo_ccu___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
}

void Vtb_cmo_ccu::evalEnd() {
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
    vlSymsp->TOP.__VdlySched.cleanupForevered();
}

void Vtb_cmo_ccu::evalStatic() {
    Vtb_cmo_ccu___024root___eval_static(&(vlSymsp->TOP));
}

void Vtb_cmo_ccu::evalInitial() {
    Vtb_cmo_ccu___024root___eval_initial(&(vlSymsp->TOP));
}

bool Vtb_cmo_ccu::evalStl(bool firstIteration) {
    return Vtb_cmo_ccu___024root___eval_stl(&(vlSymsp->TOP), firstIteration);
}

void Vtb_cmo_ccu::evalSample() {
    Vtb_cmo_ccu___024root___eval_sample(&(vlSymsp->TOP));
}

bool Vtb_cmo_ccu::evalIco(bool firstIteration) {
    return Vtb_cmo_ccu___024root___eval_ico(&(vlSymsp->TOP), firstIteration);
}

bool Vtb_cmo_ccu::evalAct() {
    return Vtb_cmo_ccu___024root___eval_act(&(vlSymsp->TOP));
}

bool Vtb_cmo_ccu::evalInact() {
    return Vtb_cmo_ccu___024root___eval_inact(&(vlSymsp->TOP));
}

bool Vtb_cmo_ccu::evalNba() {
    return Vtb_cmo_ccu___024root___eval_nba(&(vlSymsp->TOP));
}

bool Vtb_cmo_ccu::evalObs() {
    return Vtb_cmo_ccu___024root___eval_obs(&(vlSymsp->TOP));
}

bool Vtb_cmo_ccu::evalReact() {
    return Vtb_cmo_ccu___024root___eval_react(&(vlSymsp->TOP));
}

void Vtb_cmo_ccu::evalPostponed() {
    Vtb_cmo_ccu___024root___eval_postponed(&(vlSymsp->TOP));
}

void Vtb_cmo_ccu::evalFinal() {
    Vtb_cmo_ccu___024root___eval_final(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_cmo_ccu::dumpTriggersStl() {
    Vtb_cmo_ccu___024root___eval_dump_triggers__stl(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_cmo_ccu::dumpTriggersIco() {
    Vtb_cmo_ccu___024root___eval_dump_triggers__ico(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_cmo_ccu::dumpTriggersAct() {
    Vtb_cmo_ccu___024root___eval_dump_triggers__act(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_cmo_ccu::dumpTriggersNba() {
    Vtb_cmo_ccu___024root___eval_dump_triggers__nba(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_cmo_ccu::dumpTriggersObs() {
    Vtb_cmo_ccu___024root___eval_dump_triggers__obs(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_cmo_ccu::dumpTriggersReact() {
    Vtb_cmo_ccu___024root___eval_dump_triggers__react(&(vlSymsp->TOP));
}

//============================================================
// Events and timing
bool Vtb_cmo_ccu::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty() && !contextp()->gotFinish(); }

uint64_t Vtb_cmo_ccu::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vtb_cmo_ccu::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vtb_cmo_ccu::final() {
    contextp()->executingFinal(true);
    evalFinal();
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vtb_cmo_ccu::hierName() const { return vlSymsp->name(); }
const char* Vtb_cmo_ccu::modelName() const { return "Vtb_cmo_ccu"; }
unsigned Vtb_cmo_ccu::threads() const { return 1; }
void Vtb_cmo_ccu::prepareClone() const { contextp()->prepareClone(); }
void Vtb_cmo_ccu::atClone() const {
    contextp()->threadPoolpOnClone();
}
