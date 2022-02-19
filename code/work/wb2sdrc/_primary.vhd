library verilog;
use verilog.vl_types.all;
entity wb2sdrc is
    generic(
        dw              : integer := 32;
        tw              : integer := 8;
        bl              : integer := 9;
        APP_AW          : integer := 26
    );
    port(
        wb_rst_i        : in     vl_logic;
        wb_clk_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        wb_addr_i       : in     vl_logic_vector;
        wb_we_i         : in     vl_logic;
        wb_dat_i        : in     vl_logic_vector;
        wb_sel_i        : in     vl_logic_vector;
        wb_dat_o        : out    vl_logic_vector;
        wb_cyc_i        : in     vl_logic;
        wb_cti_i        : in     vl_logic_vector(2 downto 0);
        sdram_clk       : in     vl_logic;
        sdram_resetn    : in     vl_logic;
        sdr_req         : out    vl_logic;
        sdr_req_addr    : out    vl_logic_vector;
        sdr_req_len     : out    vl_logic_vector;
        sdr_req_wr_n    : out    vl_logic;
        sdr_req_ack     : in     vl_logic;
        sdr_busy_n      : in     vl_logic;
        sdr_wr_en_n     : out    vl_logic_vector;
        sdr_wr_next     : in     vl_logic;
        sdr_rd_valid    : in     vl_logic;
        sdr_last_rd     : in     vl_logic;
        sdr_wr_data     : out    vl_logic_vector;
        sdr_rd_data     : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of dw : constant is 1;
    attribute mti_svvh_generic_type of tw : constant is 1;
    attribute mti_svvh_generic_type of bl : constant is 1;
    attribute mti_svvh_generic_type of APP_AW : constant is 1;
end wb2sdrc;
