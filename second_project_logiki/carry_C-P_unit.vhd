----------------------------------------------------------------------------------
-- Engineer: 
-- 
-- Create Date:    15:08:50 03/23/2021 
-- Design Name: 
-- Module Name:    carry_C-P_unit - Behavioral 
-- Project Name: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity carry_C-P_unit is
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           P : out  STD_LOGIC_VECTOR (3 downto 0);
           G : out  STD_LOGIC_VECTOR (3 downto 0));
end carry_C-P_unit;

architecture Behavioral of carry_C-P_unit is

	begin
	
	P <= (A xor B);  -- VHDL automatically does bitwise operations for us.
	G <= (A and B);


end Behavioral;

