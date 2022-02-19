library verilog;
use verilog.vl_types.all;
entity uart_regs is
    port(
        clk             : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        wb_addr_i       : in     vl_logic_vector(4 downto 0);
        wb_dat_i        : in     vl_logic_vector(7 downto 0);
        wb_dat_o        : out    vl_logic_vector(7 downto 0);
        wb_we_i         : in     vl_logic;
        wb_re_i         : in     vl_logic;
        modem_inputs    : in     vl_logic_vector(3 downto 0);
        stx_pad_o       : out    vl_logic;
        srx_pad_i       : in     vl_logic;
        ier             : out    vl_logic_vector(3 downto 0);
        iir             : out    vl_logic_vector(3 downto 0);
        fcr             : out    vl_logic_vector(1 downto 0);
        mcr             : out    vl_logic_vector(4 downto 0);
        lcr             : out    vl_logic_vector(7 downto 0);
        msr             : out    vl_logic_vector(7 downto 0);
        lsr             : out    vl_logic_vector(7 downto 0);
        rf_count        : out    vl_logic_vector(4 downto 0);
        tf_count        : out    vl_logic_vector(4 downto 0);
        tstate          : out    vl_logic_vector(2 downto 0);
        rstate          : out    vl_logic_vector(3 downto 0);
        rts_pad_o       : out    vl_logic;
        dtr_pad_o       : out    vl_logic;
        int_o           : out    vl_logic
    );
end uart_regs;
