library verilog;
use verilog.vl_types.all;
entity OpenMIPS_KIMWENG_sopc is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        uart_in         : in     vl_logic;
        uart_out        : out    vl_logic;
        gpio_i          : in     vl_logic_vector(15 downto 0);
        gpio_o          : out    vl_logic_vector(31 downto 0);
        flash_data_i    : in     vl_logic_vector(7 downto 0);
        flash_addr_o    : out    vl_logic_vector(31 downto 0);
        flash_we_o      : out    vl_logic;
        flash_rst_o     : out    vl_logic;
        flash_oe_o      : out    vl_logic;
        flash_ce_o      : out    vl_logic;
        sdr_clk_o       : out    vl_logic;
        sdr_cs_n_o      : out    vl_logic;
        sdr_cke_o       : out    vl_logic;
        sdr_ras_n_o     : out    vl_logic;
        sdr_cas_n_o     : out    vl_logic;
        sdr_we_n_o      : out    vl_logic;
        sdr_dqm_o       : out    vl_logic_vector(3 downto 0);
        sdr_ba_o        : out    vl_logic_vector(1 downto 0);
        sdr_addr_o      : out    vl_logic_vector(12 downto 0);
        sdr_dq_io       : inout  vl_logic_vector(31 downto 0)
    );
end OpenMIPS_KIMWENG_sopc;
