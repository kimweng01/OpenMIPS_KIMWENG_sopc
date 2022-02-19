library verilog;
use verilog.vl_types.all;
entity pc_reg is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        stall           : in     vl_logic_vector(5 downto 0);
        branch_flag_i   : in     vl_logic;
        branch_target_address_i: in     vl_logic_vector(31 downto 0);
        flush           : in     vl_logic;
        new_pc          : in     vl_logic_vector(31 downto 0);
        ce              : out    vl_logic;
        pc              : out    vl_logic_vector(31 downto 0)
    );
end pc_reg;
