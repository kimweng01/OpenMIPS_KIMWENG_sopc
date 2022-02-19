library verilog;
use verilog.vl_types.all;
entity wb_conmax_pri_dec is
    generic(
        pri_sel         : vl_logic_vector(1 downto 0) := (Hi0, Hi0)
    );
    port(
        valid           : in     vl_logic;
        pri_in          : in     vl_logic_vector(1 downto 0);
        pri_out         : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of pri_sel : constant is 2;
end wb_conmax_pri_dec;
