----------------------------------------------------------------------------------

-- Engineer: 
-- 
-- Create Date:    17:04:51 03/23/2021 
-- Design Name: 
-- Module Name:    Sum_Unit - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Sum_Unit is
    Port ( Cin_sum : in  STD_LOGIC;
           Csum : in  STD_LOGIC_VECTOR (2 downto 0);
           Psum : in  STD_LOGIC_VECTOR (3 downto 0);
           Ssum : out  STD_LOGIC_VECTOR (3 downto 0));
end Sum_Unit;

architecture Behavioral of Sum_Unit is
	begin
	
		Ssum(0) <= (Psum(0) xor Cin_sum);
		Ssum(1) <= Psum(1) xor Csum(0);
		Ssum(2) <= Psum(2) xor Csum(1);
		Ssum(3) <= Psum(3) xor Csum(2);

end Behavioral;

