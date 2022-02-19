library verilog;
use verilog.vl_types.all;
entity LLbit_reg is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        flush           : in     vl_logic;
        LLbit_i         : in     vl_logic;
        we              : in     vl_logic;
        LLbit_o         : out    vl_logic
    );
end LLbit_reg;
