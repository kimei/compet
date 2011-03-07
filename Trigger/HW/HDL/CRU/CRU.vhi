
-- VHDL Instantiation Created from source file CRU.vhd -- 12:06:15 02/15/2011
--
-- Notes: 
-- 1) This instantiation template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the instantiated module
-- 2) To use this template to instantiate this entity, cut-and-paste and then edit

	COMPONENT CRU
	PORT(
		fpga_100m_clk : IN std_logic;
		fpga_cpu_reset : IN std_logic;          
		mclk : OUT std_logic;
		mclk_b : OUT std_logic;
		gclk : OUT std_logic;
		mrst : OUT std_logic;
		lrst : OUT std_logic
		);
	END COMPONENT;

	Inst_CRU: CRU PORT MAP(
		fpga_100m_clk => ,
		fpga_cpu_reset => ,
		mclk => ,
		mclk_b => ,
		gclk => ,
		mrst => ,
		lrst => 
	);


