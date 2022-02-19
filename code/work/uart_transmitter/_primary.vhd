library verilog;
use verilog.vl_types.all;
entity uart_transmitter is
    generic(
        s_idle          : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        s_send_start    : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        s_send_byte     : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        s_send_parity   : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        s_send_stop     : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0);
        s_pop_byte      : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        lcr             : in     vl_logic_vector(7 downto 0);
        tf_push         : in     vl_logic;
        wb_dat_i        : in     vl_logic_vector(7 downto 0);
        enable          : in     vl_logic;
        stx_pad_o       : out    vl_logic;
        tstate          : out    vl_logic_vector(2 downto 0);
        tf_count        : out    vl_logic_vector(4 downto 0);
        tx_reset        : in     vl_logic;
        lsr_mask        : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of s_idle : constant is 1;
    attribute mti_svvh_generic_type of s_send_start : constant is 1;
    attribute mti_svvh_generic_type of s_send_byte : constant is 1;
    attribute mti_svvh_generic_type of s_send_parity : constant is 1;
    attribute mti_svvh_generic_type of s_send_stop : constant is 1;
    attribute mti_svvh_generic_type of s_pop_byte : constant is 1;
end uart_transmitter;
