LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY dma_channel IS
PORT(
    mclk       : IN STD_LOGIC;
	puc_rst    : IN STD_LOGIC;
    --dma reg input
	---------------------------------------------
	dmax_ctl   : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	dmax_sa    : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	dmax_da    : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	dmax_sz    : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
	dmax_tsel   : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    ---------------------------------------------
	trigger    : IN STD_LOGIC;
	transfer_done : OUT STD_LOGIC;
	--------dma_interface-----------------
	dma_ready : IN STD_LOGIC;
	dma_resp  : IN STD_LOGIC;
	dma_dout  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	dma_wkup  : OUT STD_LOGIC;
	dma_en    : OUT STD_LOGIC;
	dma_addr  : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
	dma_din   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    dma_we    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)

	
	
);
END ENTITY;

ARCHITECTURE arch_channel OF dma_channel IS

--------------------------------------------------
--------------------------------------------------

--------------------------------------------
SIGNAL dma_dt : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL dma_dst_incr : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL dma_src_incr : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL dma_dst_byte : STD_LOGIC;
SIGNAL dma_src_byte : STD_LOGIC;
SIGNAL dma_level : STD_LOGIC;
SIGNAL transfer_en : STD_LOGIC;
SIGNAL dma_ifg : STD_LOGIC;
SIGNAL dma_ie  : STD_LOGIC;
SIGNAL dma_abort : STD_LOGIC;
SIGNAL dma_req : STD_LOGIC;
--------------------------------------------------

TYPE ISTATE IS(reset,load,idle,wft,rd_mem,wr_mem,modify,reload,rst_req,rst);
SIGNAL state : ISTATE;

SIGNAL T_size : INTEGER;
SIGNAL T_sourceADD : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL T_destADD : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL trigger_pos : STD_LOGIC;
SIGNAL trigger_r : STD_LOGIC;
SIGNAL trigger_sel : STD_LOGIC;

SIGNAL read_done : STD_LOGIC;
SIGNAL write_done : STD_LOGIC;
SIGNAL transfer_data : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL dma_dout_valid : STD_LOGIC;
SIGNAL dma_we_r : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL rdout_valid : STD_LOGIC;


BEGIN
-----------------------------------------------------------------------------------------
dma_dt<=dmax_ctl(14 DOWNTO 12);
dma_dst_incr<=dmax_ctl(11 DOWNTO 10);
dma_src_incr<=dmax_ctl(9 DOWNTO 8);
dma_dst_byte<=dmax_ctl(7);
dma_src_byte<=dmax_ctl(6);
dma_level<=dmax_ctl(5);
dma_ifg<=dmax_ctl(3);
dma_ie<=dmax_ctl(2);
dma_abort<=dmax_ctl(1);
------------------------------------------------------------------------
WITH dmax_tsel SELECT
     trigger_sel<= dma_req WHEN "0000",
	               trigger WHEN OTHERS;

dma_we<=dma_we_r;
PROCESS(mclk,puc_rst)
BEGIN
IF(puc_rst='1')THEN
    rdout_valid<='0';
ELSIF(mclk 'EVENT AND mclk='1')THEN
   IF(dma_ready='1')THEN
    IF(dma_we_r="00")THEN
	   rdout_valid<='1';
	ELSE
	   rdout_valid<='0';
	END IF;
   ELSE
       rdout_valid<='0';
   END IF;
END IF;
END PROCESS;		 
		 	
PROCESS(mclk,puc_rst)
BEGIN
IF(puc_rst='1')THEN
   trigger_r<='0';
ELSIF(mclk 'EVENT AND mclk='1')THEN
   trigger_r<=trigger_sel;
END IF;
END PROCESS;
trigger_pos<=trigger_sel AND (NOT trigger_r);

----------------------------------
PROCESS(mclk,puc_rst)
BEGIN
IF(puc_rst='1')THEN
   state<=reset;
ELSIF(mclk 'EVENT AND mclk='1')THEN
  CASE(state)IS
  WHEN reset     => 
                   transfer_done<='0';
  
  	               transfer_en<=dmax_ctl(4);
	               T_size<=0;
				   T_sourceADD<=(OTHERS=>'0');
				   T_destADD<=(OTHERS=>'0');
				   dma_en<='0';
				   dma_we_r<="00";
				   --dma_priority<='0';
				   dma_addr<=(OTHERS=>'0');
				   dma_din<=(OTHERS=>'0');
				   transfer_data<=(OTHERS=>'0');
				   read_done<='0';
				   write_done<='0';
				   dma_req<='0';
				   
                   IF(transfer_en='1')THEN
				      state<=load;
                   ELSE
				      state<=reset;
				   END IF;
				   
  WHEN load      =>
                   T_size<= conv_integer(dmax_sz);
                   T_sourceADD<=dmax_sa;
                   T_destADD<=dmax_da;
  
                   state<=idle;
  
  WHEN idle      =>
                   dma_en<='0';
                   --dma_priority<='0';
				   dma_we_r<="00";
                   dma_addr<=(OTHERS=>'0');
				   dma_din<=(OTHERS=>'0');
                   transfer_data<=(OTHERS=>'0');
                   read_done<='0';
				   write_done<='0';
  
                   IF(dma_abort='0')THEN
				      state<=wft;
				   ELSE 
				      state<=idle;
				   END IF;
				   IF(transfer_en='0')THEN
				      state<=reset;
				   END IF;
				   
  WHEN wft       =>
--                   dma_req<=dmax_ctl(0);
                   IF(dmax_tsel="0000")THEN
                     dma_req<=trigger;
                   END IF;

 
                   IF((trigger_pos='1' AND dma_level='0')OR(trigger='1' AND dma_level='1'))THEN
				      state<=rd_mem;
				   ELSE
				      state<=wft;
				   END IF;
                   IF(transfer_en='0')THEN
				      state<=reset;
				   END IF;

  
  WHEN rd_mem    =>
				   dma_en<='1';
				   dma_we_r<="00";
--				   dma_priority<='0';
				   dma_addr<=T_sourceADD(15 DOWNTO 1);
				   IF(rdout_valid='1')THEN
				      transfer_data<=dma_dout;
					  read_done<='1';
				   END IF;
				   
				  IF(read_done='1')THEN
				      state<=wr_mem;
				   ELSE
				      state<=rd_mem;
				   END IF;
  
  WHEN wr_mem    =>
                   read_done<='0';
				   
                   dma_en<='1';
				   dma_we_r<="11";
--				   dma_priority<='0';
				   dma_addr<=T_destADD(15 DOWNTO 1);
				   dma_din<=transfer_data;
				   write_done<='1';
				   
                   IF(write_done='1')THEN
				      IF(dma_ready='1')THEN------有可能这个周期写进去的数是无效的，所以还得继续在写状态下写数据，下一个周期再检测ready信号是否有效，有效才跳转
					     state<=modify;
					  ELSE
					     state<=wr_mem;
					  END IF;
				   END IF;				   
				   
  
  WHEN modify    =>  
                   write_done<='0';
				   IF(dma_src_byte='1')THEN
				      T_size<=T_size-1;
				      CASE(dma_src_incr)IS
				   	  WHEN "10" => T_sourceADD<=T_sourceADD-'1';
				   	  WHEN "11" => T_sourceADD<=T_sourceADD+'1';
				   	  WHEN OTHERS => NULL;
				      END CASE;
				   ELSE
				      T_size<=T_size-2;
				      CASE(dma_src_incr)IS
				   	  WHEN "10" => T_sourceADD<=T_sourceADD-"10";
				   	  WHEN "11" => T_sourceADD<=T_sourceADD+"10";
				   	  WHEN OTHERS => NULL;
				      END CASE;
				   END IF;
				   
				   IF(dma_dst_byte='1')THEN
				      CASE(dma_dst_incr)IS
				   	  WHEN "10" => T_destADD<=T_destADD-'1';
				   	  WHEN "11" => T_destADD<=T_destADD+'1';
				   	  WHEN OTHERS => NULL;
                      END CASE;
                   ELSE
                      CASE(dma_dst_incr)IS
                   	  WHEN "10" => T_destADD<=T_destADD-"10";
                   	  WHEN "11" => T_destADD<=T_destADD+"10";
                   	  WHEN OTHERS => NULL;
                      END CASE;
                   END IF;
  
                   IF(dma_level='1' AND trigger='0')THEN
                      state<=idle;
				   END IF;
				   IF((dma_dt="000" AND T_size=0) OR transfer_en='0')THEN
				      state<=rst;
				   END IF;
				   IF(dma_dt="100" AND transfer_en='1' AND T_size=0)THEN
				      state<=reload;
				   END IF;
				   IF(T_size>0 AND transfer_en='1')THEN
				      state<=rst_req;
				   END IF;
				   
  
  WHEN reload    =>
                  T_size<= conv_integer(dmax_sz);
                  T_sourceADD<=dmax_sa;
                  T_destADD<=dmax_da;
  
                   state<=rst_req;
  
  WHEN rst_req   =>
                   dma_req<='0';
				   
                   state<=wft;
  
  WHEN rst      =>
                  transfer_en<='0';
                  dma_req<='0';
                  T_size<= conv_integer(dmax_sz);

                  state<=reset;
				  
				  transfer_done<='1';
  
  WHEN OTHERS    => NULL;
  
  END CASE;
  
  END IF;
END PROCESS;


END arch_channel;











