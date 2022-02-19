library verilog;
use verilog.vl_types.all;
entity uart_wb is
    port(
        clk             : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        wb_we_i         : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        wb_adr_i        : in     vl_logic_vector(4 downto 0);
        wb_adr_int      : out    vl_logic_vector(4 downto 0);
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_dat8_i       : out    vl_logic_vector(7 downto 0);
        wb_dat8_o       : in     vl_logic_vector(7 downto 0);
        wb_dat32_o      : in     vl_logic_vector(31 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        we_o            : out    vl_logic;
        re_o            : out    vl_logic
    );
end uart_wb;
