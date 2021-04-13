----------------------------------------------------------------------------------
-- Engineer: 
-- 
-- Create Date:    18:48:10 03/23/2021 
-- Design Name: 
-- Module Name:    C_P_unit - Behavioral 

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity C_P_unit is
    Port ( Acp : in  STD_LOGIC_VECTOR (3 downto 0);
           Bcp : in  STD_LOGIC_VECTOR (3 downto 0);
           Pcp : out  STD_LOGIC_VECTOR (3 downto 0);
           Gcp : out  STD_LOGIC_VECTOR (3 downto 0));
end C_P_unit;

architecture Behavioral of C_P_unit is

	begin
	
	Pcp <= (Acp xor Bcp);  -- VHDL automatically does bitwise operations for us.
	Gcp <= (Acp and Bcp);


end Behavioral;

