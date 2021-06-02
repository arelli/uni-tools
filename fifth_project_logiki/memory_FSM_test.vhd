--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:26:34 05/21/2021
-- Design Name:   
-- Module Name:   C:/Users/iason/Desktop/HRY203/HRY203_lab5/memory_FSM_test.vhd
-- Project Name:  HRY203_lab5
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: memory_FSM
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
 
ENTITY memory_FSM_test IS
END memory_FSM_test;
 
ARCHITECTURE behavior OF memory_FSM_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT memory_FSM
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         Push : IN  std_logic;
         Pop : IN  std_logic;
         NumberIN : IN  std_logic_vector(3 downto 0);
         NumberOUT : OUT  std_logic_vector(3 downto 0);
         Empty : OUT  std_logic;
         Full : OUT  std_logic;
         AlmostEmpty : OUT  std_logic;
         AlmostFull : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal Push : std_logic := '0';
   signal Pop : std_logic := '0';
   signal NumberIN : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal NumberOUT : std_logic_vector(3 downto 0);
   signal Empty : std_logic;
   signal Full : std_logic;
   signal AlmostEmpty : std_logic;
   signal AlmostFull : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: memory_FSM PORT MAP (
          CLK => CLK,
          RST => RST,
          Push => Push,
          Pop => Pop,
          NumberIN => NumberIN,
          NumberOUT => NumberOUT,
          Empty => Empty,
          Full => Full,
          AlmostEmpty => AlmostEmpty,
          AlmostFull => AlmostFull
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- reset the controller 
			RST <= '1';
			Push <= '0';
			Pop <= '0';
      wait for CLK_period*10;
		
			RST <= '0';
			Push <= '0';
			Pop <= '0';
      wait for CLK_period;
		
		
		for i in 0 to 7 loop  -- push 8 times(the numbers 10,9,8....,3)
				NumberIN <= std_logic_vector(to_signed(10-i,4));
				Push <= '1';
				Pop <= '0';
			wait for CLK_period;
				-- un-press the buttons.
				RST <= '0';
				Push <= '0';
				Pop <= '0';
			wait for CLK_period*2;
		end loop;
		
		for j in 0 to 6 loop  -- test for 7 consecutive pops
				Push <= '0';
				Pop <= '1';
			wait for CLK_period;
				Push <= '0';
				Pop <= '0';
			wait for CLK_period*2;
		end loop;
		
      wait;
   end process;

END;
