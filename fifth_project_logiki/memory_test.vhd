--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:50:14 05/20/2021
-- Design Name:   
-- Module Name:   C:/Users/iason/Desktop/HRY203/HRY203_lab5/memory_test.vhd
-- Project Name:  HRY203_lab5
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: lab5_memory
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY memory_test IS
END memory_test;
 
ARCHITECTURE behavior OF memory_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT lab5_memory
    PORT(
         clka : IN  std_logic;
         wea : IN  std_logic_vector(0 downto 0);
         addra : IN  std_logic_vector(3 downto 0);
         dina : IN  std_logic_vector(3 downto 0);
         douta : OUT  std_logic_vector(3 downto 0) 
        );
    END COMPONENT;
    

   --Inputs
   signal clka : std_logic := '0';
   signal wea : std_logic_vector(0 downto 0) := (others => '0');
   signal addra : std_logic_vector(3 downto 0) := (others => '0');
   signal dina : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal douta : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clka_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: lab5_memory PORT MAP (
          clka => clka,
          wea => wea,
          addra => addra,
          dina => dina,
          douta => douta
        );

   -- Clock process definitions
   clka_process :process
   begin
		clka <= '0';
		wait for clka_period/2;
		clka <= '1';
		wait for clka_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clka_period*10;
		
--			wea <= "1";
--			
--			for i in 0 to 10 loop
--				addra <= std_logic_vector(to_signed(i,4));
--				dina <= std_logic_vector(to_signed(10-i,4));
--				
--				wait for clka_period*10;
--			end loop;
--			
--			wea <= "0";
--			
--			for j in 0 to 10 loop
--				addra <= std_logic_vector(to_signed(j,4));
--				
--				wait for clka_period*10;
--			end loop;



--			for i in 0 to 10 loop
--					wea <= "1";
--					addra <= std_logic_vector(to_signed(i,4));
--					dina <= std_logic_vector(to_signed(10-i,4));
--					
--				wait for clka_period;
--					wea <= "0";
--				wait for clka_period*5;
--				
--			
--			end loop;

					wea <= "1";
					addra <= "0001";
					dina <= "1111";
					
				wait for clka_period;
					wea <= "0";
				wait for clka_period*5;
				
					wea <= "1";
					addra <= "0010";
					dina <= "1111";
					
				wait for clka_period;
					wea <= "0";
				wait for clka_period*5;
			
			
			
				
      wait;
   end process;

END;
