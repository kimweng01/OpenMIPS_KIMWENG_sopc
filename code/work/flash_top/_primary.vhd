library verilog;
use verilog.vl_types.all;
entity flash_top is
    port(
        wb_clk_i        : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_we_i         : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        flash_adr_o     : out    vl_logic_vector(31 downto 0);
        flash_dat_i     : in     vl_logic_vector(7 downto 0);
        flash_rst       : out    vl_logic;
        flash_oe        : out    vl_logic;
        flash_ce        : out    vl_logic;
        flash_we        : out    vl_logic
    );
end flash_top;
