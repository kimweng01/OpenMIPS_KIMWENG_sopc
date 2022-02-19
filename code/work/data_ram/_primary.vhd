library verilog;
use verilog.vl_types.all;
entity data_ram is
    port(
        clk             : in     vl_logic;
        ce              : in     vl_logic;
        we              : in     vl_logic;
        addr            : in     vl_logic_vector(31 downto 0);
        sel             : in     vl_logic_vector(3 downto 0);
        data_i          : in     vl_logic_vector(31 downto 0);
        data_o          : out    vl_logic_vector(31 downto 0)
    );
end data_ram;
