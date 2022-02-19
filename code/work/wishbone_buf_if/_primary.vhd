library verilog;
use verilog.vl_types.all;
entity wishbone_buf_if is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        stall_i         : in     vl_logic_vector(5 downto 0);
        flush_i         : in     vl_logic;
        cpu_ce_i        : in     vl_logic;
        cpu_data_i      : in     vl_logic_vector(31 downto 0);
        cpu_addr_i      : in     vl_logic_vector(31 downto 0);
        cpu_we_i        : in     vl_logic;
        cpu_sel_i       : in     vl_logic_vector(3 downto 0);
        cpu_data_o      : out    vl_logic_vector(31 downto 0);
        wishbone_data_i : in     vl_logic_vector(31 downto 0);
        wishbone_ack_i  : in     vl_logic;
        wishbone_addr_o : out    vl_logic_vector(31 downto 0);
        wishbone_data_o : out    vl_logic_vector(31 downto 0);
        wishbone_we_o   : out    vl_logic;
        wishbone_sel_o  : out    vl_logic_vector(3 downto 0);
        wishbone_stb_o  : out    vl_logic;
        wishbone_cyc_o  : out    vl_logic;
        stallreq        : out    vl_logic
    );
end wishbone_buf_if;
