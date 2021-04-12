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
					
				else
					if Control = "000" then  -- step -5
						if Count_temp = "00000100" then
							Underflow <= '1';
							-- stop the counter
						else
							Count_temp <= Count_temp -5;
						end if;
						
					elsif Control = "001" then  -- step -2
						if Count_temp = "00000001" then
							Underflow <= '1';
							-- stop the counter
						else
							Count_temp <= Count_temp -2;
						end if;
					
					elsif Control = "010" then  -- step 0
						Count_temp <= Count_temp;
					
					elsif Control = "011" then  -- step 1
						if Count_temp = "11111111" then
								Overflow <= '1';
								-- stop the counter
						else
							Count_temp <= Count_temp + 1;
						end if;
					
					elsif Control = "100" then  -- step 2
						if Count_temp = "11111110" then
									Overflow <= '1';
									-- stop the counter
						else
							Count_temp <= Count_temp + 2;
						end if;
					
					elsif Control = "101" then    -- step 5
						if Count_temp = "11111111" then
									Overflow <= '1';
									-- stop the counter
						else
							Count_temp <= Count_temp + 5;
						end if;
					
					elsif Control = "110" then  -- step 6
						if Count_temp = "11111010" then
									Overflow <= '1';
									-- stop the counter
						else
							Count_temp <= Count_temp + 6;
						end if;
					
					elsif Control = "111" then    -- step 12
						if Count_temp = "11110100" then
									Overflow <= '1';
									-- stop the counter
						else
							Count_temp <= Count_temp + 12;
						end if;
					end if;
				end if;
		end process;
		Count <= Count_temp;
end Behavioral;

