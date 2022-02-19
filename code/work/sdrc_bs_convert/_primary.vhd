library verilog;
use verilog.vl_types.all;
entity sdrc_bs_convert is
    generic(
        APP_AW          : integer := 30;
        APP_DW          : integer := 32;
        APP_BW          : integer := 4;
        SDR_DW          : integer := 16;
        SDR_BW          : integer := 2
    );
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        sdr_width       : in     vl_logic_vector(1 downto 0);
        x2a_rdstart     : in     vl_logic;
        x2a_wrstart     : in     vl_logic;
        x2a_rdlast      : in     vl_logic;
        x2a_wrlast      : in     vl_logic;
        x2a_rddt        : in     vl_logic_vector;
        x2a_rdok        : in     vl_logic;
        a2x_wrdt        : out    vl_logic_vector;
        a2x_wren_n      : out    vl_logic_vector;
        x2a_wrnext      : in     vl_logic;
        app_wr_data     : in     vl_logic_vector;
        app_wr_en_n     : in     vl_logic_vector;
        app_wr_next     : out    vl_logic;
        app_last_wr     : out    vl_logic;
        app_rd_data     : out    vl_logic_vector;
        app_rd_valid    : out    vl_logic;
        app_last_rd     : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of APP_AW : constant is 1;
    attribute mti_svvh_generic_type of APP_DW : constant is 1;
    attribute mti_svvh_generic_type of APP_BW : constant is 1;
    attribute mti_svvh_generic_type of SDR_DW : constant is 1;
    attribute mti_svvh_generic_type of SDR_BW : constant is 1;
end sdrc_bs_convert;
