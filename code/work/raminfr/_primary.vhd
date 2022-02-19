library verilog;
use verilog.vl_types.all;
entity raminfr is
    generic(
        addr_width      : integer := 4;
        data_width      : integer := 8;
        depth           : integer := 16
    );
    port(
        clk             : in     vl_logic;
        we              : in     vl_logic;
        a               : in     vl_logic_vector;
        dpra            : in     vl_logic_vector;
        di              : in     vl_logic_vector;
        dpo             : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of addr_width : constant is 1;
    attribute mti_svvh_generic_type of data_width : constant is 1;
    attribute mti_svvh_generic_type of depth : constant is 1;
end raminfr;
