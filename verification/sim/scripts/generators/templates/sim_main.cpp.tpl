#include <memory>
#include <verilated.h>
#include <verilated_cov.h>
#include "Vtb_fence_i_end_to_end.h"

int main(int argc, char** argv) {
    const std::unique_ptr<VerilatedContext> context{new VerilatedContext};
    context->commandArgs(argc, argv);
    const std::unique_ptr<Vtb_fence_i_end_to_end> model{
        new Vtb_fence_i_end_to_end{context.get(), "TOP"}};
    while (!context->gotFinish()) {
        model->eval();
        if (context->gotFinish()) break;
        if (model->eventsPending()) {
            context->time(model->nextTimeSlot());
        } else {
            context->timeInc(1);
        }
    }
    model->final();
#if VM_COVERAGE
    context->coveragep()->write();
#endif
    return context->gotError() ? 1 : 0;
}
