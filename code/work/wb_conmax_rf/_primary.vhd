library verilog;
use verilog.vl_types.all;
entity wb_conmax_rf is
    generic(
        rf_addr         : vl_logic_vector(3 downto 0) := (Hi1, Hi1, Hi1, Hi1);
        dw              : integer := 32;
        aw              : integer := 32;
        sw              : vl_notype
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        i_wb_data_i     : in     vl_logic_vector;
        i_wb_data_o     : out    vl_logic_vector;
        i_wb_addr_i     : in     vl_logic_vector;
        i_wb_sel_i      : in     vl_logic_vector;
        i_wb_we_i       : in     vl_logic;
        i_wb_cyc_i      : in     vl_logic;
        i_wb_stb_i      : in     vl_logic;
        i_wb_ack_o      : out    vl_logic;
        i_wb_err_o      : out    vl_logic;
        i_wb_rty_o      : out    vl_logic;
        e_wb_data_i     : in     vl_logic_vector;
        e_wb_data_o     : out    vl_logic_vector;
        e_wb_addr_o     : out    vl_logic_vector;
        e_wb_sel_o      : out    vl_logic_vector;
        e_wb_we_o       : out    vl_logic;
        e_wb_cyc_o      : out    vl_logic;
        e_wb_stb_o      : out    vl_logic;
        e_wb_ack_i      : in     vl_logic;
        e_wb_err_i      : in     vl_logic;
        e_wb_rty_i      : in     vl_logic;
        conf0           : out    vl_logic_vector(15 downto 0);
        conf1           : out    vl_logic_vector(15 downto 0);
        conf2           : out    vl_logic_vector(15 downto 0);
        conf3           : out    vl_logic_vector(15 downto 0);
        conf4           : out    vl_logic_vector(15 downto 0);
        conf5           : out    vl_logic_vector(15 downto 0);
        conf6           : out    vl_logic_vector(15 downto 0);
        conf7           : out    vl_logic_vector(15 downto 0);
        conf8           : out    vl_logic_vector(15 downto 0);
        conf9           : out    vl_logic_vector(15 downto 0);
        conf10          : out    vl_logic_vector(15 downto 0);
        conf11          : out    vl_logic_vector(15 downto 0);
        conf12          : out    vl_logic_vector(15 downto 0);
        conf13          : out    vl_logic_vector(15 downto 0);
        conf14          : out    vl_logic_vector(15 downto 0);
        conf15          : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of rf_addr : constant is 2;
    attribute mti_svvh_generic_type of dw : constant is 1;
    attribute mti_svvh_generic_type of aw : constant is 1;
    attribute mti_svvh_generic_type of sw : constant is 3;
end wb_conmax_rf;
