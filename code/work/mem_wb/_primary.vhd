library verilog;
use verilog.vl_types.all;
entity mem_wb is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        mem_wd          : in     vl_logic_vector(4 downto 0);
        mem_wreg        : in     vl_logic;
        mem_wdata       : in     vl_logic_vector(31 downto 0);
        mem_hi          : in     vl_logic_vector(31 downto 0);
        mem_lo          : in     vl_logic_vector(31 downto 0);
        mem_whilo       : in     vl_logic;
        mem_LLbit_we    : in     vl_logic;
        mem_LLbit_value : in     vl_logic;
        mem_cp0_reg_we  : in     vl_logic;
        mem_cp0_reg_wr_addr: in     vl_logic_vector(4 downto 0);
        mem_cp0_reg_data: in     vl_logic_vector(31 downto 0);
        stall           : in     vl_logic_vector(5 downto 0);
        flush           : in     vl_logic;
        wb_wd           : out    vl_logic_vector(4 downto 0);
        wb_wreg         : out    vl_logic;
        wb_wdata        : out    vl_logic_vector(31 downto 0);
        wb_hi           : out    vl_logic_vector(31 downto 0);
        wb_lo           : out    vl_logic_vector(31 downto 0);
        wb_whilo        : out    vl_logic;
        wb_LLbit_we     : out    vl_logic;
        wb_LLbit_value  : out    vl_logic;
        wb_cp0_reg_we   : out    vl_logic;
        wb_cp0_reg_wr_addr: out    vl_logic_vector(4 downto 0);
        wb_cp0_reg_data : out    vl_logic_vector(31 downto 0)
    );
end mem_wb;
