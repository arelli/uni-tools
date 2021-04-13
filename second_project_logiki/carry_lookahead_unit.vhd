----------------------------------------------------------------------------------
-- Engineer: 
-- 
-- Create Date:    15:20:12 03/23/2021 
-- Design Name: 
-- Module Name:    carry_lookahead_unit - Behavioral 
-- Project Name: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity carry_lookahead_unit is
    Port ( P : in  STD_LOGIC_VECTOR (3 downto 0);
           G : in  STD_LOGIC_VECTOR (3 downto 0);
           Cin_cla : in  STD_LOGIC;
           Cfinal : out  STD_LOGIC;
           Cout_cla : out  STD_LOGIC_VECTOR (2 downto 0));
end carry_lookahead_unit;

architecture Behavioral of carry_lookahead_unit is

	begin 
	
	Cout_cla(0) <= (G(0) or (P(0) and Cin_cla));  -- from the equations given to us
	Cout_cla(1) <= (G(1) or (P(1) and (G(0))) or (P(1) and P(0) and Cin_cla));
	Cout_cla(2) <= (G(2) or (P(2) and G(1)) or (P(2) and P(1) and (G(0))) or (P(2) and P(1) and P(0) and Cin_cla));
	Cfinal <= (G(3) or (P(3) and G(2)) or (P(3) and P(2) and G(1)) or (P(3) and P(2) and P(1) and G(0)) or (P(3) and P(2) and P(1) and P(0) and Cin_cla));
end Behavioral;

