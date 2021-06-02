----------------------------------------------------------------------------------
-- Company: 		ECE TUC - HRY203
-- Engineer: 		Jason Lambridis, Rafail Ellinitakis
-- 
-- Create Date: 	05/04/2021 
-- Design Name: 
-- Module Name:  	FSM - Behavioral 
-- Project Name: 	HRY203_lab4
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           Control : out  STD_LOGIC_VECTOR (2 downto 0));
end FSM;

architecture Behavioral of FSM is

	type state is (state_0, state_1, state_2, state_3, state_4);
	signal FSM_state: state;
	signal initial_state: state;
	
begin

	initial_state <= state_0;
	
	process
	begin
		wait until Clk'event and Clk = '1';
		
		if RST = '1' then
			FSM_state <= initial_state;
			
		else 
			case FSM_state is
				when state_0 =>
					if A ='1' and B ='0' then 
						FSM_state <= state_1;
					elsif A ='0' and B ='1' then 
						FSM_state <= state_4;
					else
						FSM_state <= FSM_state;
					end if;
					
				when state_1 =>
					if A ='1' and B ='0' then 
						FSM_state <= state_2;
					elsif A ='0' and B ='1' then 
						FSM_state <= state_0;
					else
						FSM_state <= FSM_state;
					end if;
					
				when state_2 =>
					if A ='1' and B ='0' then 
						FSM_state <= state_3;
					elsif A ='0' and B ='1' then 
						FSM_state <= state_1;
					else
						FSM_state <= FSM_state;
					end if;
					
				when state_3 =>
					if A ='1' and B ='0' then 
						FSM_state <= state_4;
					elsif A ='0' and B ='1' then 
						FSM_state <= state_2;
					else
						FSM_state <= FSM_state;
					end if;
					
				when state_4 =>
					if A ='1' and B ='0' then 
						FSM_state <= state_0;
					elsif A ='0' and B ='1' then 
						FSM_state <= state_3;
					else
						FSM_state <= FSM_state;
					end if;
					
				when others => -- not all states are covered(3-bit means a total possible of 8 states)
					FSM_state <= initial_state;  -- so we need to cover those extra "dead" states.
			
			end case;
		end if;  -- the RESET if
	end process;
	-- below we give the actual output values per each state to the Control output bus.
	with FSM_state select Control <=
		"000" when state_0,
		"001" when state_1,
		"010" when state_2,
		"011" when state_3,
		"100" when state_4,
		"000" when others;
	
end Behavioral;

