library verilog;
use verilog.vl_types.all;
entity id is
    port(
        pc_i            : in     vl_logic_vector(31 downto 0);
        inst_i          : in     vl_logic_vector(31 downto 0);
        reg1_data_i     : in     vl_logic_vector(31 downto 0);
        reg2_data_i     : in     vl_logic_vector(31 downto 0);
        ex_wreg_i       : in     vl_logic;
        ex_wdata_i      : in     vl_logic_vector(31 downto 0);
        ex_wd_i         : in     vl_logic_vector(4 downto 0);
        ex_aluop_i      : in     vl_logic_vector(7 downto 0);
        mem_wreg_i      : in     vl_logic;
        mem_wdata_i     : in     vl_logic_vector(31 downto 0);
        mem_wd_i        : in     vl_logic_vector(4 downto 0);
        dlyslot_now_i   : in     vl_logic;
        inst_o          : out    vl_logic_vector(31 downto 0);
        reg1_read_o     : out    vl_logic;
        reg2_read_o     : out    vl_logic;
        reg1_addr_o     : out    vl_logic_vector(4 downto 0);
        reg2_addr_o     : out    vl_logic_vector(4 downto 0);
        aluop_o         : out    vl_logic_vector(7 downto 0);
        alusel_o        : out    vl_logic_vector(2 downto 0);
        reg1_o          : out    vl_logic_vector(31 downto 0);
        reg2_o          : out    vl_logic_vector(31 downto 0);
        wd_o            : out    vl_logic_vector(4 downto 0);
        wreg_o          : out    vl_logic;
        link_addr_o     : out    vl_logic_vector(31 downto 0);
        branch_target_address_o: out    vl_logic_vector(31 downto 0);
        branch_flag_o   : out    vl_logic;
        next_dlyslot_o  : out    vl_logic;
        dlyslot_now_o   : out    vl_logic;
        stallreq        : out    vl_logic;
        excepttype_o    : out    vl_logic_vector(31 downto 0);
        current_inst_addr_o: out    vl_logic_vector(31 downto 0)
    );
end id;
