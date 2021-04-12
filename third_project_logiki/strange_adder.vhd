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
	signal Valid_buffer:STD_LOGIC;  -- to be able to read the output of Valid in the if statements
	
	begin
		process
			begin
			wait until Clk'event and Clk = '1';
				if RST = '1' then
					Count_temp <= "00000000";
					Underflow <= '0';
					Overflow <= '0';
					Valid_buffer <= '1';
					
				else
					if Valid_buffer = '1' then
						case Control is
							when "000" =>
								if Count_temp <= "00000100" then
									Valid_buffer <= '0';
									Underflow <= '1';
								else
									Count_temp <= Count_temp -5;
								end if;
							
							when "001" => 
								if Count_temp <= "00000001" then
									Valid_buffer <= '0';
									Underflow <= '1';
								else
									Count_temp <= Count_temp -2;
								end if;
						
							when "010" => Count_temp <= Count_temp;
							
							when "011" => 
								if Count_temp >= "11111111" then
									Valid_buffer <= '0';
									Overflow <= '1';
								else
									Count_temp <= Count_temp +1;
								end if;
								
							when "100" => 
								if Count_temp >= "11111110" then
									Valid_buffer <= '0';
									Overflow <= '1';
								else
									Count_temp <= Count_temp +2;
								end if;
								
							when "101" => 
								if Count_temp >= "11111011" then  -- 255-(5-1)
									Valid_buffer <= '0';
									Overflow <= '1';
								else
									Count_temp <= Count_temp +5;
								end if;
			
							when "110" => 
								if Count_temp >= "11111010" then
									Valid_buffer <= '0';
									Overflow <= '1';
								else
									Count_temp <= Count_temp +6;
								end if;
								
							when "111" => 
								if Count_temp >= "11110011" then
									Valid_buffer <= '0';
									Overflow <= '1';
								else
									Count_temp <= Count_temp +12;
								end if;
								
							when others => 
								Valid_buffer <= '0';
						end case;
					else
						Count_temp <= Count_temp;
					end if;
				end if;
		end process;
		Count <= Count_temp;
		Valid <= Valid_buffer;
end Behavioral;

