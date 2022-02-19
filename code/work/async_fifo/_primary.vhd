library verilog;
use verilog.vl_types.all;
entity async_fifo is
    generic(
        W               : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0);
        DP              : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        WR_FAST         : vl_logic := Hi1;
        RD_FAST         : vl_logic := Hi1;
        FULL_DP         : vl_notype;
        EMPTY_DP        : vl_logic := Hi0;
        AW              : vl_notype
    );
    port(
        wr_clk          : in     vl_logic;
        wr_reset_n      : in     vl_logic;
        wr_en           : in     vl_logic;
        wr_data         : in     vl_logic_vector;
        full            : out    vl_logic;
        afull           : out    vl_logic;
        rd_clk          : in     vl_logic;
        rd_reset_n      : in     vl_logic;
        rd_en           : in     vl_logic;
        empty           : out    vl_logic;
        aempty          : out    vl_logic;
        rd_data         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of W : constant is 1;
    attribute mti_svvh_generic_type of DP : constant is 1;
    attribute mti_svvh_generic_type of WR_FAST : constant is 1;
    attribute mti_svvh_generic_type of RD_FAST : constant is 1;
    attribute mti_svvh_generic_type of FULL_DP : constant is 3;
    attribute mti_svvh_generic_type of EMPTY_DP : constant is 1;
    attribute mti_svvh_generic_type of AW : constant is 3;
end async_fifo;
