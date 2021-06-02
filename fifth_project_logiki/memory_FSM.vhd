----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:18:46 05/20/2021 
-- Design Name: 
-- Module Name:    memory_FSM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.library UNISIM;
--use UNISIM.VComponents.all;

entity memory_FSM is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Push : in  STD_LOGIC;
           Pop : in  STD_LOGIC;
           NumberIN : in  STD_LOGIC_VECTOR (3 downto 0);
           NumberOUT : out  STD_LOGIC_VECTOR (3 downto 0);
           Empty : out  STD_LOGIC;
           Full : out  STD_LOGIC;
           AlmostEmpty : out  STD_LOGIC;
           AlmostFull : out  STD_LOGIC);
end memory_FSM;

architecture Behavioral of memory_FSM is
	
	COMPONENT FSM
	PORT(
		CLK : IN std_logic;
		RST : IN std_logic;
		Push : IN std_logic;
		Pop : IN std_logic;          
		WE : OUT std_logic_vector(0 downto 0);
		Address : OUT std_logic_vector(3 downto 0);
		Empty : OUT std_logic;
		Full : OUT std_logic;
		AlmostEmpty : OUT std_logic;
		AlmostFull : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT lab5_memory
	  PORT (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	  );
	END COMPONENT;

	
	signal wea_temp:STD_LOGIC_VECTOR(0 DOWNTO 0);
	signal addra_temp:STD_LOGIC_VECTOR(3 DOWNTO 0);

begin

		Inst_FSM: FSM PORT MAP(
		CLK => CLK,
		RST => RST,
		Push => Push ,
		Pop => Pop,
		WE => wea_temp,
		Address => addra_temp,
		Empty => Empty,
		Full => Full,
		AlmostEmpty => AlmostEmpty,
		AlmostFull => AlmostFull
	);

		memory : lab5_memory
	  PORT MAP (
		 clka => CLK,
		 wea => wea_temp,
		 addra => addra_temp,
		 dina => NumberIN,
		 douta => NumberOut
	  );
	  
end Behavioral;

