library verilog;
use verilog.vl_types.all;
entity hilo_reg is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        we              : in     vl_logic;
        hi_i            : in     vl_logic_vector(31 downto 0);
        lo_i            : in     vl_logic_vector(31 downto 0);
        hi_o            : out    vl_logic_vector(31 downto 0);
        lo_o            : out    vl_logic_vector(31 downto 0)
    );
end hilo_reg;
