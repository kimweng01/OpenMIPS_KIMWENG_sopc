library verilog;
use verilog.vl_types.all;
entity wb_conmax_arb is
    generic(
        grant0          : vl_logic_vector(2 downto 0) := (Hi0, Hi0, Hi0);
        grant1          : vl_logic_vector(2 downto 0) := (Hi0, Hi0, Hi1);
        grant2          : vl_logic_vector(2 downto 0) := (Hi0, Hi1, Hi0);
        grant3          : vl_logic_vector(2 downto 0) := (Hi0, Hi1, Hi1);
        grant4          : vl_logic_vector(2 downto 0) := (Hi1, Hi0, Hi0);
        grant5          : vl_logic_vector(2 downto 0) := (Hi1, Hi0, Hi1);
        grant6          : vl_logic_vector(2 downto 0) := (Hi1, Hi1, Hi0);
        grant7          : vl_logic_vector(2 downto 0) := (Hi1, Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        req             : in     vl_logic_vector(7 downto 0);
        gnt             : out    vl_logic_vector(2 downto 0);
        \next\          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of grant0 : constant is 2;
    attribute mti_svvh_generic_type of grant1 : constant is 2;
    attribute mti_svvh_generic_type of grant2 : constant is 2;
    attribute mti_svvh_generic_type of grant3 : constant is 2;
    attribute mti_svvh_generic_type of grant4 : constant is 2;
    attribute mti_svvh_generic_type of grant5 : constant is 2;
    attribute mti_svvh_generic_type of grant6 : constant is 2;
    attribute mti_svvh_generic_type of grant7 : constant is 2;
end wb_conmax_arb;
