library verilog;
use verilog.vl_types.all;
entity OpenMIPS is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        inst_wishbone_data_i: in     vl_logic_vector(31 downto 0);
        inst_wishbone_ack_i: in     vl_logic;
        inst_wishbone_addr_o: out    vl_logic_vector(31 downto 0);
        inst_wishbone_data_o: out    vl_logic_vector(31 downto 0);
        inst_wishbone_we_o: out    vl_logic;
        inst_wishbone_sel_o: out    vl_logic_vector(3 downto 0);
        inst_wishbone_stb_o: out    vl_logic;
        inst_wishbone_cyc_o: out    vl_logic;
        data_wishbone_data_i: in     vl_logic_vector(31 downto 0);
        data_wishbone_ack_i: in     vl_logic;
        data_wishbone_addr_o: out    vl_logic_vector(31 downto 0);
        data_wishbone_data_o: out    vl_logic_vector(31 downto 0);
        data_wishbone_we_o: out    vl_logic;
        data_wishbone_sel_o: out    vl_logic_vector(3 downto 0);
        data_wishbone_stb_o: out    vl_logic;
        data_wishbone_cyc_o: out    vl_logic;
        int_i           : in     vl_logic_vector(5 downto 0);
        timer_int_o     : out    vl_logic
    );
end OpenMIPS;
