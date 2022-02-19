library verilog;
use verilog.vl_types.all;
entity wb_conmax_pri_enc is
    generic(
        pri_sel         : vl_logic_vector(1 downto 0) := (Hi0, Hi0)
    );
    port(
        valid           : in     vl_logic_vector(7 downto 0);
        pri0            : in     vl_logic_vector(1 downto 0);
        pri1            : in     vl_logic_vector(1 downto 0);
        pri2            : in     vl_logic_vector(1 downto 0);
        pri3            : in     vl_logic_vector(1 downto 0);
        pri4            : in     vl_logic_vector(1 downto 0);
        pri5            : in     vl_logic_vector(1 downto 0);
        pri6            : in     vl_logic_vector(1 downto 0);
        pri7            : in     vl_logic_vector(1 downto 0);
        pri_out         : out    vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of pri_sel : constant is 2;
end wb_conmax_pri_enc;
