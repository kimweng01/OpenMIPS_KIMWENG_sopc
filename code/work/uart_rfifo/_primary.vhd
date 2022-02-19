library verilog;
use verilog.vl_types.all;
entity uart_rfifo is
    generic(
        fifo_width      : integer := 8;
        fifo_depth      : integer := 16;
        fifo_pointer_w  : integer := 4;
        fifo_counter_w  : integer := 5
    );
    port(
        clk             : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        data_in         : in     vl_logic_vector;
        data_out        : out    vl_logic_vector;
        push            : in     vl_logic;
        pop             : in     vl_logic;
        overrun         : out    vl_logic;
        count           : out    vl_logic_vector;
        error_bit       : out    vl_logic;
        fifo_reset      : in     vl_logic;
        reset_status    : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of fifo_width : constant is 1;
    attribute mti_svvh_generic_type of fifo_depth : constant is 1;
    attribute mti_svvh_generic_type of fifo_pointer_w : constant is 1;
    attribute mti_svvh_generic_type of fifo_counter_w : constant is 1;
end uart_rfifo;
