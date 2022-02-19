library verilog;
use verilog.vl_types.all;
entity sdrc_bank_ctl is
    generic(
        SDR_DW          : integer := 16;
        SDR_BW          : integer := 2
    );
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        a2b_req_depth   : in     vl_logic_vector(1 downto 0);
        r2b_req         : in     vl_logic;
        r2b_req_id      : in     vl_logic_vector(3 downto 0);
        r2b_start       : in     vl_logic;
        r2b_last        : in     vl_logic;
        r2b_wrap        : in     vl_logic;
        r2b_ba          : in     vl_logic_vector(1 downto 0);
        r2b_raddr       : in     vl_logic_vector(12 downto 0);
        r2b_caddr       : in     vl_logic_vector(12 downto 0);
        r2b_len         : in     vl_logic_vector(6 downto 0);
        r2b_write       : in     vl_logic;
        b2r_arb_ok      : out    vl_logic;
        b2r_ack         : out    vl_logic;
        b2x_idle        : out    vl_logic;
        b2x_req         : out    vl_logic;
        b2x_start       : out    vl_logic;
        b2x_last        : out    vl_logic;
        b2x_wrap        : out    vl_logic;
        b2x_id          : out    vl_logic_vector(3 downto 0);
        b2x_ba          : out    vl_logic_vector(1 downto 0);
        b2x_addr        : out    vl_logic_vector(12 downto 0);
        b2x_len         : out    vl_logic_vector(6 downto 0);
        b2x_cmd         : out    vl_logic_vector(1 downto 0);
        x2b_ack         : in     vl_logic;
        b2x_tras_ok     : out    vl_logic;
        x2b_refresh     : in     vl_logic;
        x2b_pre_ok      : in     vl_logic_vector(3 downto 0);
        x2b_act_ok      : in     vl_logic;
        x2b_rdok        : in     vl_logic;
        x2b_wrok        : in     vl_logic;
        xfr_bank_sel    : in     vl_logic_vector(1 downto 0);
        sdr_req_norm_dma_last: in     vl_logic;
        tras_delay      : in     vl_logic_vector(3 downto 0);
        trp_delay       : in     vl_logic_vector(3 downto 0);
        trcd_delay      : in     vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SDR_DW : constant is 1;
    attribute mti_svvh_generic_type of SDR_BW : constant is 1;
end sdrc_bank_ctl;
