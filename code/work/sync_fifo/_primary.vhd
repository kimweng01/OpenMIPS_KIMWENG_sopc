library verilog;
use verilog.vl_types.all;
entity sync_fifo is
    generic(
        W               : integer := 8;
        D               : integer := 4;
        AW              : vl_notype
    );
    port(
        clk             : in     vl_logic;
        reset_n         : in     vl_logic;
        wr_en           : in     vl_logic;
        wr_data         : in     vl_logic_vector;
        full            : out    vl_logic;
        empty           : out    vl_logic;
        rd_en           : in     vl_logic;
        rd_data         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of W : constant is 1;
    attribute mti_svvh_generic_type of D : constant is 1;
    attribute mti_svvh_generic_type of AW : constant is 3;
end sync_fifo;
