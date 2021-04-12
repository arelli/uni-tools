----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:05:23 04/12/2021 
-- Design Name: 
-- Module Name:    strange_adder - Behavioral 
-- Project Name: strange adder- Third Lab
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;  --https://stackoverflow.com/questions/26598471/found-0-definitions-of-operator-in-vhdl/32384573



entity strange_adder is
    Port ( Clk : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Control : in  STD_LOGIC_VECTOR (2 downto 0);
           Count : out  STD_LOGIC_VECTOR (7 downto 0);
           Overflow : out  STD_LOGIC;
           Underflow : out  STD_LOGIC;
           Valid : out  STD_LOGIC);
end strange_adder;

architecture Behavioral of strange_adder is
	signal Count_temp:STD_LOGIC_VECTOR(7 DOWNTO 0);
	
	begin
		process
			begin
			wait until Clk'event and Clk = '1';
				if RST = '1' then
					Count_temp <= "00000000";
					Underflow <= '0';
					Overflow <= '0';
					Valid <= '1';
					
				elsif
					
				else
					case Control is
						when "000" =>
							Count_temp <= Count_temp -5;
						when "001" =>
							Count_temp <= Count_temp -2;
							
						when "010" =>
							Count_temp <= Count_temp;
							
						when "011" =>
							Count_temp <= Count_temp +1;
							
						when "100" =>
							Count_temp <= Count_temp +2;
							
						when "101" =>
							Count_temp <= Count_temp +5;
							
						when "110" =>
							Count_temp <= Count_temp +6;
							
						when "111" =>
							Count_temp <= Count_temp +12;
						when others =>
							Valid <= '0';
							
					end case;
				end if;
		end process;
		Count <= Count_temp;
end Behavioral;

