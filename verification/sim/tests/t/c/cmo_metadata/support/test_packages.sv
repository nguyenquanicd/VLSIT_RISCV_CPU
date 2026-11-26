package config_pkg;
  typedef struct packed {
    int unsigned PLEN;
    int unsigned VLEN;
    int unsigned XLEN;
    int unsigned DCACHE_INDEX_WIDTH;
    int unsigned DCACHE_TAG_WIDTH;
  } cva6_cfg_t;

  localparam cva6_cfg_t cva6_cfg_empty = '{
    PLEN: 32, VLEN: 32, XLEN: 32, DCACHE_INDEX_WIDTH: 4, DCACHE_TAG_WIDTH: 4
  };
endpackage

package ariane_pkg;
  localparam logic [2:0] DEPTH_SPEC = 3'd4;
  localparam logic [2:0] DEPTH_COMMIT = 3'd4;
  typedef logic [7:0] cbo_t;
  localparam cbo_t CBO_CLEAN = 8'h01;
  localparam cbo_t CBO_FLUSH = 8'h02;
  localparam cbo_t CBO_INVAL = 8'h03;
  localparam cbo_t CBO_NONE = 8'h00;
endpackage
