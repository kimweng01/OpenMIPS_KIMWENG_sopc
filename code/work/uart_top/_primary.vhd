library verilog;
use verilog.vl_types.all;
entity uart_top is
    generic(
        uart_data_width : integer := 32;
        uart_addr_width : integer := 5
    );
    port(
        wb_clk_i        : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector;
        wb_dat_i        : in     vl_logic_vector;
        wb_dat_o        : out    vl_logic_vector;
        wb_we_i         : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        int_o           : out    vl_logic;
        stx_pad_o       : out    vl_logic;
        srx_pad_i       : in     vl_logic;
        rts_pad_o       : out    vl_logic;
        cts_pad_i       : in     vl_logic;
        dtr_pad_o       : out    vl_logic;
        dsr_pad_i       : in     vl_logic;
        ri_pad_i        : in     vl_logic;
        dcd_pad_i       : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of uart_data_width : constant is 1;
    attribute mti_svvh_generic_type of uart_addr_width : constant is 1;
end uart_top;
