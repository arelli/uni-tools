----------------------------------------------------------------------------------
-- Create Date:    17:52:54 05/21/2021 
-- Design Name: 
-- Module Name:    FSM - Behavioral 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;  -- this is the standard library to use 

entity FSM is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Push : in  STD_LOGIC;
           Pop : in  STD_LOGIC;
           WE : out  STD_LOGIC_VECTOR (0 downto 0);
           Address : out  STD_LOGIC_VECTOR (3 downto 0);
           Empty : out  STD_LOGIC;
           Full : out  STD_LOGIC;
           AlmostEmpty : out  STD_LOGIC;
           AlmostFull : out  STD_LOGIC);
end FSM;

architecture Behavioral of FSM is

	signal counter: integer;

begin

	process
	begin
		wait until Clk'event and Clk = '1';
		
		if RST = '1' then  -- the reset state when the RST is pressed
			-- removed the assignment to the Address bus here(caused double/parallel declaration)
			counter <= 0;
			WE <= "0";
			Empty <= '1';  -- when resetting we have a cold start, so the state must be "empty"
			Full <= '0';
			AlmostEmpty <= '0';
			AlmostFull <= '0';
			
					
		else 
		-- the controller(FSM) has 5 states: Empty, AlmostEmpty, something-in-between, AlmostFull, Full
		-- To avoid naming states and counting in seperate, the states themselves are groups of counter
		-- values. This way we have the counter integrated in the FSM the most effective way.
			case counter is
				when 0 =>
					WE <= "0";  -- when the state becomes 0, the writing is done, and should stop(we are at the next clock cycle)
					Empty <= '1';
					Full <= '0';
					AlmostEmpty <= '0';
					AlmostFull <= '0';
					
					if Push = '1' AND Pop = '0' then
						counter <= 1;  -- the counter when leaving state "0" will always be 1. Avoid unnecessary math.
						WE <= "1";
						-- no need for else statement here as we stay the same
					end if;
				
					
				when 1 | 2 | 3 =>  -- position AlmostEmpty is defined as 1, 2 OR 3 elements in the stack
					WE <= "0";
					Empty <= '0';
					Full <= '0';
					AlmostEmpty <= '1';
					AlmostFull <= '0';
					
					if Push = '1' AND Pop = '0' then
						counter <= counter + 1;
						WE <= "1";	
					elsif Pop = '1' AND Push = '0' then
						counter <= counter - 1;
						WE <= "0";  -- during pop, we do not need to enable writing
					end if; 
					
					
				when 7 | 8 | 9 =>  -- the AlmosfTull state
					WE <= "0";
					Empty <= '0';
					Full <= '0';
					AlmostEmpty <= '0';
					AlmostFull <= '1';
					
					if Push = '1' AND Pop = '0' then
						counter <= counter + 1;
						WE <= "1";	
					elsif Pop = '1' AND Push = '0' then
						counter <= counter - 1;
						WE <= "0";
					end if;
				
				
				when 10 =>	 -- the full state
					WE <= "0";
					Empty <= '0';
					Full <= '1';
					AlmostEmpty <= '0';
					AlmostFull <= '0';
					if Pop = '1' AND Push = '0' then
						counter <= 9;
						WE <= "0";						
					end if;
					
					
				when others =>  -- this is the not named state, between counter = 4 and counter = 6
					WE <= "0";
					Empty <= '0';
					Full <= '0';
					AlmostEmpty <= '0';
					AlmostFull <= '0';
					
					if Push = '1' AND Pop = '0' then
						counter <= counter + 1;
						WE <= "1";
					elsif Pop = '1' AND Push = '0' then
						counter <= counter - 1;
						WE <= "0";
					end if;
			end case;	
		end if;
	end process;
	Address <= std_logic_vector(to_unsigned(counter,4));  -- this runs in parralel with the above process.
	-- the term "runs" is not exaclty correct, as it is just a simple wire connecting the counter "bus"
	-- to the address bus using the neccessary hardware "casting" to vector.
end Behavioral;




