library verilog;
use verilog.vl_types.all;
entity gpio_top is
    generic(
        dw              : integer := 32;
        aw              : integer := 8;
        gw              : integer := 32
    );
    port(
        wb_clk_i        : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector;
        wb_dat_i        : in     vl_logic_vector;
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_we_i         : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_dat_o        : out    vl_logic_vector;
        wb_ack_o        : out    vl_logic;
        wb_err_o        : out    vl_logic;
        wb_inta_o       : out    vl_logic;
        ext_pad_i       : in     vl_logic_vector;
        ext_pad_o       : out    vl_logic_vector;
        ext_padoe_o     : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of dw : constant is 1;
    attribute mti_svvh_generic_type of aw : constant is 1;
    attribute mti_svvh_generic_type of gw : constant is 1;
end gpio_top;
