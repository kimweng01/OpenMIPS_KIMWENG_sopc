library verilog;
use verilog.vl_types.all;
entity uart_receiver is
    generic(
        sr_idle         : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        sr_rec_start    : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        sr_rec_bit      : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        sr_rec_parity   : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        sr_rec_stop     : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        sr_check_parity : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        sr_rec_prepare  : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        sr_end_bit      : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        sr_ca_lc_parity : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0);
        sr_wait1        : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi1);
        sr_push         : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi0)
    );
    port(
        clk             : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        lcr             : in     vl_logic_vector(7 downto 0);
        rf_pop          : in     vl_logic;
        srx_pad_i       : in     vl_logic;
        enable          : in     vl_logic;
        counter_t       : out    vl_logic_vector(9 downto 0);
        rf_count        : out    vl_logic_vector(4 downto 0);
        rf_data_out     : out    vl_logic_vector(10 downto 0);
        rf_error_bit    : out    vl_logic;
        rf_overrun      : out    vl_logic;
        rx_reset        : in     vl_logic;
        lsr_mask        : in     vl_logic;
        rstate          : out    vl_logic_vector(3 downto 0);
        rf_push_pulse   : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of sr_idle : constant is 1;
    attribute mti_svvh_generic_type of sr_rec_start : constant is 1;
    attribute mti_svvh_generic_type of sr_rec_bit : constant is 1;
    attribute mti_svvh_generic_type of sr_rec_parity : constant is 1;
    attribute mti_svvh_generic_type of sr_rec_stop : constant is 1;
    attribute mti_svvh_generic_type of sr_check_parity : constant is 1;
    attribute mti_svvh_generic_type of sr_rec_prepare : constant is 1;
    attribute mti_svvh_generic_type of sr_end_bit : constant is 1;
    attribute mti_svvh_generic_type of sr_ca_lc_parity : constant is 1;
    attribute mti_svvh_generic_type of sr_wait1 : constant is 1;
    attribute mti_svvh_generic_type of sr_push : constant is 1;
end uart_receiver;
