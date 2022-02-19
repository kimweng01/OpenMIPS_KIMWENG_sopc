library verilog;
use verilog.vl_types.all;
entity sdrc_req_gen is
    generic(
        APP_AW          : integer := 26;
        APP_DW          : integer := 32;
        APP_BW          : integer := 4;
        APP_RW          : integer := 9;
        SDR_DW          : integer := 16;
        SDR_BW          : integer := 2
    );
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        cfg_colbits     : in     vl_logic_vector(1 downto 0);
        sdr_width       : in     vl_logic_vector(1 downto 0);
        req             : in     vl_logic;
        req_id          : in     vl_logic_vector(3 downto 0);
        req_addr        : in     vl_logic_vector;
        req_len         : in     vl_logic_vector;
        req_wrap        : in     vl_logic;
        req_wr_n        : in     vl_logic;
        req_ack         : out    vl_logic;
        r2x_idle        : out    vl_logic;
        r2b_req         : out    vl_logic;
        r2b_req_id      : out    vl_logic_vector(3 downto 0);
        r2b_start       : out    vl_logic;
        r2b_last        : out    vl_logic;
        r2b_wrap        : out    vl_logic;
        r2b_ba          : out    vl_logic_vector(1 downto 0);
        r2b_raddr       : out    vl_logic_vector(12 downto 0);
        r2b_caddr       : out    vl_logic_vector(12 downto 0);
        r2b_len         : out    vl_logic_vector(6 downto 0);
        r2b_write       : out    vl_logic;
        b2r_ack         : in     vl_logic;
        b2r_arb_ok      : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of APP_AW : constant is 1;
    attribute mti_svvh_generic_type of APP_DW : constant is 1;
    attribute mti_svvh_generic_type of APP_BW : constant is 1;
    attribute mti_svvh_generic_type of APP_RW : constant is 1;
    attribute mti_svvh_generic_type of SDR_DW : constant is 1;
    attribute mti_svvh_generic_type of SDR_BW : constant is 1;
end sdrc_req_gen;
