library verilog;
use verilog.vl_types.all;
entity uart_sync_flops is
    generic(
        Tp              : integer := 1;
        width           : integer := 1;
        init_value      : vl_logic := Hi0
    );
    port(
        rst_i           : in     vl_logic;
        clk_i           : in     vl_logic;
        stage1_rst_i    : in     vl_logic;
        stage1_clk_en_i : in     vl_logic;
        async_dat_i     : in     vl_logic_vector;
        sync_dat_o      : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Tp : constant is 1;
    attribute mti_svvh_generic_type of width : constant is 1;
    attribute mti_svvh_generic_type of init_value : constant is 1;
end uart_sync_flops;
