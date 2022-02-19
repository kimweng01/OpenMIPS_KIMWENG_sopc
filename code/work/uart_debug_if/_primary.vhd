library verilog;
use verilog.vl_types.all;
entity uart_debug_if is
    port(
        wb_dat32_o      : out    vl_logic_vector(31 downto 0);
        wb_adr_i        : in     vl_logic_vector(4 downto 0);
        ier             : in     vl_logic_vector(3 downto 0);
        iir             : in     vl_logic_vector(3 downto 0);
        fcr             : in     vl_logic_vector(1 downto 0);
        mcr             : in     vl_logic_vector(4 downto 0);
        lcr             : in     vl_logic_vector(7 downto 0);
        msr             : in     vl_logic_vector(7 downto 0);
        lsr             : in     vl_logic_vector(7 downto 0);
        rf_count        : in     vl_logic_vector(4 downto 0);
        tf_count        : in     vl_logic_vector(4 downto 0);
        tstate          : in     vl_logic_vector(2 downto 0);
        rstate          : in     vl_logic_vector(3 downto 0)
    );
end uart_debug_if;
