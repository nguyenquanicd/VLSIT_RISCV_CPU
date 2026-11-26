/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-08
 * Description  : Selects defined per-hart, aggregate, and cluster PMU events by ID and scope.
 */
`timescale 1ns/1ps

// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// Size hart-active indexing to the selected two- or four-hart profile.
module m_vlsit_pmu_event_select #(
  // Parameter Description: number of active harts supported by this PMU instance.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: number of configurable PMU counters.
  // Parameter values: 1 through 32; default is 16.
  // Parameter unit: counters
  parameter logic [31:0] PARA_PMU_CNT_NUM = 32'd16,
  localparam logic [31:0] LPARA_HART_EVT_NUM       = 32'd38,
  localparam logic [31:0] LPARA_CLUSTER_EVT_NUM   = 32'd40,
  localparam logic [31:0] LPARA_SCOPE_HART_0      = 32'd0,
  localparam logic [31:0] LPARA_SCOPE_HART_1      = 32'd1,
  localparam logic [31:0] LPARA_SCOPE_HART_2      = 32'd2,
  localparam logic [31:0] LPARA_SCOPE_HART_3      = 32'd3,
  localparam logic [31:0] LPARA_SCOPE_AGGREGATE   = 32'd4,
  localparam logic [31:0] LPARA_SCOPE_CLUSTER     = 32'd5,
  localparam logic [31:0] LPARA_EVT_GRP_CVA6      = 32'h00,
  localparam logic [31:0] LPARA_EVT_GRP_HPD       = 32'h01,
  localparam logic [31:0] LPARA_EVT_GRP_LLC      = 32'h02,
  localparam logic [31:0] LPARA_EVT_GRP_CCU      = 32'h03,
  localparam logic [31:0] LPARA_EVT_CVA6_FIRST    = 32'h01,
  localparam logic [31:0] LPARA_EVT_CVA6_LAST     = 32'h16,
  localparam logic [31:0] LPARA_EVT_HPD_LAST      = 32'h0F,
  localparam logic [31:0] LPARA_EVT_LLC_LAST      = 32'h17,
  localparam logic [31:0] LPARA_EVT_LLC_EXT_FIRST = 32'h40,
  localparam logic [31:0] LPARA_EVT_LLC_EXT_LAST  = 32'h43,
  localparam logic [31:0] LPARA_EVT_CCU_LAST      = 32'h0B,
  localparam logic [31:0] LPARA_CVA6_EVT_NUM      = 32'd22,
  localparam logic [31:0] LPARA_LLC_EVT_NUM       = 32'd28,
  localparam logic [31:0] LPARA_LLC_MAIN_NUM      = 32'd24
) (
  // Per-hart activity and events
  input  wire  [PARA_CPU_NUM-1:0]                         i_hart_active,
  input  wire  [PARA_CPU_NUM-1:0][LPARA_HART_EVT_NUM-1:0] i_hart_evt,
  input  wire  [LPARA_HART_EVT_NUM-1:0][2:0]              i_hart_agg_evt_count,

  // Cluster LLC and CCU events
  input  wire  [LPARA_CLUSTER_EVT_NUM-1:0][2:0]           i_cluster_evt_count,

  // Software-selected event IDs and scope
  input  wire  [PARA_PMU_CNT_NUM-1:0][15:0]               i_pmu_evt_id,
  input  wire  [PARA_PMU_CNT_NUM-1:0][2:0]                i_pmu_evt_scope,

  // Selected per-counter occurrence counts; reserved or unavailable choices return zero
  output logic [PARA_PMU_CNT_NUM-1:0][2:0]                o_pmu_evt_count
);

  // A zero default makes unknown IDs and unsupported source/scope pairs inert.
  always_comb begin : p_com_pmu_evt_sel
    o_pmu_evt_count = '0;
    for (int cnt_idx = 0; cnt_idx < PARA_PMU_CNT_NUM; cnt_idx++) begin
      case (32'(i_pmu_evt_scope[cnt_idx]))
        LPARA_SCOPE_HART_0,
        LPARA_SCOPE_HART_1,
        LPARA_SCOPE_HART_2,
        LPARA_SCOPE_HART_3: begin
          if ((32'(i_pmu_evt_scope[cnt_idx]) < PARA_CPU_NUM) &&
              i_hart_active[$clog2(PARA_CPU_NUM)'(i_pmu_evt_scope[cnt_idx])]) begin
            case (32'(i_pmu_evt_id[cnt_idx][15:8]))
              LPARA_EVT_GRP_CVA6: begin
                if ((32'(i_pmu_evt_id[cnt_idx][7:0]) >= LPARA_EVT_CVA6_FIRST) &&
                    (32'(i_pmu_evt_id[cnt_idx][7:0]) <= LPARA_EVT_CVA6_LAST))
                  o_pmu_evt_count[cnt_idx] =
                    {2'b00, i_hart_evt[2'(i_pmu_evt_scope[cnt_idx])]
                    [6'(i_pmu_evt_id[cnt_idx][5:0] - 6'(LPARA_EVT_CVA6_FIRST))]};
              end
              LPARA_EVT_GRP_HPD: begin
                if (32'(i_pmu_evt_id[cnt_idx][7:0]) <= LPARA_EVT_HPD_LAST)
                  o_pmu_evt_count[cnt_idx] =
                    {2'b00, i_hart_evt[2'(i_pmu_evt_scope[cnt_idx])]
                    [6'(LPARA_CVA6_EVT_NUM + 32'(i_pmu_evt_id[cnt_idx][3:0]))]};
              end
              default: begin
                o_pmu_evt_count[cnt_idx] = '0;
              end
            endcase
          end
        end
        LPARA_SCOPE_AGGREGATE: begin
          case (32'(i_pmu_evt_id[cnt_idx][15:8]))
            LPARA_EVT_GRP_CVA6: begin
              if ((32'(i_pmu_evt_id[cnt_idx][7:0]) >= LPARA_EVT_CVA6_FIRST) &&
                  (32'(i_pmu_evt_id[cnt_idx][7:0]) <= LPARA_EVT_CVA6_LAST))
                o_pmu_evt_count[cnt_idx] = i_hart_agg_evt_count[
                  6'(i_pmu_evt_id[cnt_idx][5:0] - 6'(LPARA_EVT_CVA6_FIRST))
                ];
            end
            LPARA_EVT_GRP_HPD: begin
              if (32'(i_pmu_evt_id[cnt_idx][7:0]) <= LPARA_EVT_HPD_LAST)
                o_pmu_evt_count[cnt_idx] = i_hart_agg_evt_count[
                  6'(LPARA_CVA6_EVT_NUM + 32'(i_pmu_evt_id[cnt_idx][3:0]))
                ];
            end
            default: begin
              o_pmu_evt_count[cnt_idx] = '0;
            end
          endcase
        end
        LPARA_SCOPE_CLUSTER: begin
          case (32'(i_pmu_evt_id[cnt_idx][15:8]))
            LPARA_EVT_GRP_LLC: begin
              if (32'(i_pmu_evt_id[cnt_idx][7:0]) <= LPARA_EVT_LLC_LAST)
                o_pmu_evt_count[cnt_idx] = i_cluster_evt_count[6'(i_pmu_evt_id[cnt_idx][4:0])];
            end
            LPARA_EVT_GRP_CCU: begin
              if (32'(i_pmu_evt_id[cnt_idx][7:0]) <= LPARA_EVT_CCU_LAST)
                o_pmu_evt_count[cnt_idx] = i_cluster_evt_count[
                  6'(LPARA_LLC_EVT_NUM + 32'(i_pmu_evt_id[cnt_idx][3:0]))
                ];
            end
            default: begin
              o_pmu_evt_count[cnt_idx] = '0;
            end
          endcase
          if ((32'(i_pmu_evt_id[cnt_idx][15:8]) == LPARA_EVT_GRP_LLC) &&
              (32'(i_pmu_evt_id[cnt_idx][7:0]) >= LPARA_EVT_LLC_EXT_FIRST) &&
              (32'(i_pmu_evt_id[cnt_idx][7:0]) <= LPARA_EVT_LLC_EXT_LAST))
            o_pmu_evt_count[cnt_idx] = i_cluster_evt_count[
              6'(LPARA_LLC_MAIN_NUM + 32'(i_pmu_evt_id[cnt_idx][1:0]))
            ];
        end
        default: begin
          o_pmu_evt_count[cnt_idx] = '0;
        end
      endcase
    end
  end

endmodule
