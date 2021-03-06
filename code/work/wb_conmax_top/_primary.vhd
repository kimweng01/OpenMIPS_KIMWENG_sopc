library verilog;
use verilog.vl_types.all;
entity wb_conmax_top is
    generic(
        dw              : integer := 32;
        aw              : integer := 32;
        rf_addr         : vl_logic_vector(3 downto 0) := (Hi1, Hi1, Hi1, Hi1);
        pri_sel0        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel1        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel2        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel3        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel4        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel5        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel6        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel7        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel8        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel9        : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel10       : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel11       : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel12       : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel13       : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel14       : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        pri_sel15       : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        sw              : vl_notype
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        m0_data_i       : in     vl_logic_vector;
        m0_data_o       : out    vl_logic_vector;
        m0_addr_i       : in     vl_logic_vector;
        m0_sel_i        : in     vl_logic_vector;
        m0_we_i         : in     vl_logic;
        m0_cyc_i        : in     vl_logic;
        m0_stb_i        : in     vl_logic;
        m0_ack_o        : out    vl_logic;
        m0_err_o        : out    vl_logic;
        m0_rty_o        : out    vl_logic;
        m1_data_i       : in     vl_logic_vector;
        m1_data_o       : out    vl_logic_vector;
        m1_addr_i       : in     vl_logic_vector;
        m1_sel_i        : in     vl_logic_vector;
        m1_we_i         : in     vl_logic;
        m1_cyc_i        : in     vl_logic;
        m1_stb_i        : in     vl_logic;
        m1_ack_o        : out    vl_logic;
        m1_err_o        : out    vl_logic;
        m1_rty_o        : out    vl_logic;
        m2_data_i       : in     vl_logic_vector;
        m2_data_o       : out    vl_logic_vector;
        m2_addr_i       : in     vl_logic_vector;
        m2_sel_i        : in     vl_logic_vector;
        m2_we_i         : in     vl_logic;
        m2_cyc_i        : in     vl_logic;
        m2_stb_i        : in     vl_logic;
        m2_ack_o        : out    vl_logic;
        m2_err_o        : out    vl_logic;
        m2_rty_o        : out    vl_logic;
        m3_data_i       : in     vl_logic_vector;
        m3_data_o       : out    vl_logic_vector;
        m3_addr_i       : in     vl_logic_vector;
        m3_sel_i        : in     vl_logic_vector;
        m3_we_i         : in     vl_logic;
        m3_cyc_i        : in     vl_logic;
        m3_stb_i        : in     vl_logic;
        m3_ack_o        : out    vl_logic;
        m3_err_o        : out    vl_logic;
        m3_rty_o        : out    vl_logic;
        m4_data_i       : in     vl_logic_vector;
        m4_data_o       : out    vl_logic_vector;
        m4_addr_i       : in     vl_logic_vector;
        m4_sel_i        : in     vl_logic_vector;
        m4_we_i         : in     vl_logic;
        m4_cyc_i        : in     vl_logic;
        m4_stb_i        : in     vl_logic;
        m4_ack_o        : out    vl_logic;
        m4_err_o        : out    vl_logic;
        m4_rty_o        : out    vl_logic;
        m5_data_i       : in     vl_logic_vector;
        m5_data_o       : out    vl_logic_vector;
        m5_addr_i       : in     vl_logic_vector;
        m5_sel_i        : in     vl_logic_vector;
        m5_we_i         : in     vl_logic;
        m5_cyc_i        : in     vl_logic;
        m5_stb_i        : in     vl_logic;
        m5_ack_o        : out    vl_logic;
        m5_err_o        : out    vl_logic;
        m5_rty_o        : out    vl_logic;
        m6_data_i       : in     vl_logic_vector;
        m6_data_o       : out    vl_logic_vector;
        m6_addr_i       : in     vl_logic_vector;
        m6_sel_i        : in     vl_logic_vector;
        m6_we_i         : in     vl_logic;
        m6_cyc_i        : in     vl_logic;
        m6_stb_i        : in     vl_logic;
        m6_ack_o        : out    vl_logic;
        m6_err_o        : out    vl_logic;
        m6_rty_o        : out    vl_logic;
        m7_data_i       : in     vl_logic_vector;
        m7_data_o       : out    vl_logic_vector;
        m7_addr_i       : in     vl_logic_vector;
        m7_sel_i        : in     vl_logic_vector;
        m7_we_i         : in     vl_logic;
        m7_cyc_i        : in     vl_logic;
        m7_stb_i        : in     vl_logic;
        m7_ack_o        : out    vl_logic;
        m7_err_o        : out    vl_logic;
        m7_rty_o        : out    vl_logic;
        s0_data_i       : in     vl_logic_vector;
        s0_data_o       : out    vl_logic_vector;
        s0_addr_o       : out    vl_logic_vector;
        s0_sel_o        : out    vl_logic_vector;
        s0_we_o         : out    vl_logic;
        s0_cyc_o        : out    vl_logic;
        s0_stb_o        : out    vl_logic;
        s0_ack_i        : in     vl_logic;
        s0_err_i        : in     vl_logic;
        s0_rty_i        : in     vl_logic;
        s1_data_i       : in     vl_logic_vector;
        s1_data_o       : out    vl_logic_vector;
        s1_addr_o       : out    vl_logic_vector;
        s1_sel_o        : out    vl_logic_vector;
        s1_we_o         : out    vl_logic;
        s1_cyc_o        : out    vl_logic;
        s1_stb_o        : out    vl_logic;
        s1_ack_i        : in     vl_logic;
        s1_err_i        : in     vl_logic;
        s1_rty_i        : in     vl_logic;
        s2_data_i       : in     vl_logic_vector;
        s2_data_o       : out    vl_logic_vector;
        s2_addr_o       : out    vl_logic_vector;
        s2_sel_o        : out    vl_logic_vector;
        s2_we_o         : out    vl_logic;
        s2_cyc_o        : out    vl_logic;
        s2_stb_o        : out    vl_logic;
        s2_ack_i        : in     vl_logic;
        s2_err_i        : in     vl_logic;
        s2_rty_i        : in     vl_logic;
        s3_data_i       : in     vl_logic_vector;
        s3_data_o       : out    vl_logic_vector;
        s3_addr_o       : out    vl_logic_vector;
        s3_sel_o        : out    vl_logic_vector;
        s3_we_o         : out    vl_logic;
        s3_cyc_o        : out    vl_logic;
        s3_stb_o        : out    vl_logic;
        s3_ack_i        : in     vl_logic;
        s3_err_i        : in     vl_logic;
        s3_rty_i        : in     vl_logic;
        s4_data_i       : in     vl_logic_vector;
        s4_data_o       : out    vl_logic_vector;
        s4_addr_o       : out    vl_logic_vector;
        s4_sel_o        : out    vl_logic_vector;
        s4_we_o         : out    vl_logic;
        s4_cyc_o        : out    vl_logic;
        s4_stb_o        : out    vl_logic;
        s4_ack_i        : in     vl_logic;
        s4_err_i        : in     vl_logic;
        s4_rty_i        : in     vl_logic;
        s5_data_i       : in     vl_logic_vector;
        s5_data_o       : out    vl_logic_vector;
        s5_addr_o       : out    vl_logic_vector;
        s5_sel_o        : out    vl_logic_vector;
        s5_we_o         : out    vl_logic;
        s5_cyc_o        : out    vl_logic;
        s5_stb_o        : out    vl_logic;
        s5_ack_i        : in     vl_logic;
        s5_err_i        : in     vl_logic;
        s5_rty_i        : in     vl_logic;
        s6_data_i       : in     vl_logic_vector;
        s6_data_o       : out    vl_logic_vector;
        s6_addr_o       : out    vl_logic_vector;
        s6_sel_o        : out    vl_logic_vector;
        s6_we_o         : out    vl_logic;
        s6_cyc_o        : out    vl_logic;
        s6_stb_o        : out    vl_logic;
        s6_ack_i        : in     vl_logic;
        s6_err_i        : in     vl_logic;
        s6_rty_i        : in     vl_logic;
        s7_data_i       : in     vl_logic_vector;
        s7_data_o       : out    vl_logic_vector;
        s7_addr_o       : out    vl_logic_vector;
        s7_sel_o        : out    vl_logic_vector;
        s7_we_o         : out    vl_logic;
        s7_cyc_o        : out    vl_logic;
        s7_stb_o        : out    vl_logic;
        s7_ack_i        : in     vl_logic;
        s7_err_i        : in     vl_logic;
        s7_rty_i        : in     vl_logic;
        s8_data_i       : in     vl_logic_vector;
        s8_data_o       : out    vl_logic_vector;
        s8_addr_o       : out    vl_logic_vector;
        s8_sel_o        : out    vl_logic_vector;
        s8_we_o         : out    vl_logic;
        s8_cyc_o        : out    vl_logic;
        s8_stb_o        : out    vl_logic;
        s8_ack_i        : in     vl_logic;
        s8_err_i        : in     vl_logic;
        s8_rty_i        : in     vl_logic;
        s9_data_i       : in     vl_logic_vector;
        s9_data_o       : out    vl_logic_vector;
        s9_addr_o       : out    vl_logic_vector;
        s9_sel_o        : out    vl_logic_vector;
        s9_we_o         : out    vl_logic;
        s9_cyc_o        : out    vl_logic;
        s9_stb_o        : out    vl_logic;
        s9_ack_i        : in     vl_logic;
        s9_err_i        : in     vl_logic;
        s9_rty_i        : in     vl_logic;
        s10_data_i      : in     vl_logic_vector;
        s10_data_o      : out    vl_logic_vector;
        s10_addr_o      : out    vl_logic_vector;
        s10_sel_o       : out    vl_logic_vector;
        s10_we_o        : out    vl_logic;
        s10_cyc_o       : out    vl_logic;
        s10_stb_o       : out    vl_logic;
        s10_ack_i       : in     vl_logic;
        s10_err_i       : in     vl_logic;
        s10_rty_i       : in     vl_logic;
        s11_data_i      : in     vl_logic_vector;
        s11_data_o      : out    vl_logic_vector;
        s11_addr_o      : out    vl_logic_vector;
        s11_sel_o       : out    vl_logic_vector;
        s11_we_o        : out    vl_logic;
        s11_cyc_o       : out    vl_logic;
        s11_stb_o       : out    vl_logic;
        s11_ack_i       : in     vl_logic;
        s11_err_i       : in     vl_logic;
        s11_rty_i       : in     vl_logic;
        s12_data_i      : in     vl_logic_vector;
        s12_data_o      : out    vl_logic_vector;
        s12_addr_o      : out    vl_logic_vector;
        s12_sel_o       : out    vl_logic_vector;
        s12_we_o        : out    vl_logic;
        s12_cyc_o       : out    vl_logic;
        s12_stb_o       : out    vl_logic;
        s12_ack_i       : in     vl_logic;
        s12_err_i       : in     vl_logic;
        s12_rty_i       : in     vl_logic;
        s13_data_i      : in     vl_logic_vector;
        s13_data_o      : out    vl_logic_vector;
        s13_addr_o      : out    vl_logic_vector;
        s13_sel_o       : out    vl_logic_vector;
        s13_we_o        : out    vl_logic;
        s13_cyc_o       : out    vl_logic;
        s13_stb_o       : out    vl_logic;
        s13_ack_i       : in     vl_logic;
        s13_err_i       : in     vl_logic;
        s13_rty_i       : in     vl_logic;
        s14_data_i      : in     vl_logic_vector;
        s14_data_o      : out    vl_logic_vector;
        s14_addr_o      : out    vl_logic_vector;
        s14_sel_o       : out    vl_logic_vector;
        s14_we_o        : out    vl_logic;
        s14_cyc_o       : out    vl_logic;
        s14_stb_o       : out    vl_logic;
        s14_ack_i       : in     vl_logic;
        s14_err_i       : in     vl_logic;
        s14_rty_i       : in     vl_logic;
        s15_data_i      : in     vl_logic_vector;
        s15_data_o      : out    vl_logic_vector;
        s15_addr_o      : out    vl_logic_vector;
        s15_sel_o       : out    vl_logic_vector;
        s15_we_o        : out    vl_logic;
        s15_cyc_o       : out    vl_logic;
        s15_stb_o       : out    vl_logic;
        s15_ack_i       : in     vl_logic;
        s15_err_i       : in     vl_logic;
        s15_rty_i       : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of dw : constant is 1;
    attribute mti_svvh_generic_type of aw : constant is 1;
    attribute mti_svvh_generic_type of rf_addr : constant is 2;
    attribute mti_svvh_generic_type of pri_sel0 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel1 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel2 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel3 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel4 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel5 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel6 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel7 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel8 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel9 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel10 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel11 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel12 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel13 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel14 : constant is 2;
    attribute mti_svvh_generic_type of pri_sel15 : constant is 2;
    attribute mti_svvh_generic_type of sw : constant is 3;
end wb_conmax_top;
