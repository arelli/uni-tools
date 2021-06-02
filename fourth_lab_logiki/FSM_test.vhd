----------------------------------------------------------------------------------
-- Company: 		ECE TUC - HRY203
-- Engineer: 		Jason Lambridis, Rafail Ellinitakis
-- 
-- Create Date: 	05/04/2021 
-- Design Name: 
-- Module Name:   FSM_test
-- Project Name:  HRY203_lab4
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY FSM_test IS
END FSM_test;
 
ARCHITECTURE behavior OF FSM_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FSM
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         A : IN  std_logic;
         B : IN  std_logic;
         Control : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal A : std_logic := '0';
   signal B : std_logic := '0';

 	--Outputs
   signal Control : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FSM PORT MAP (
          CLK => CLK,
          RST => RST,
          A => A,
          B => B,
          Control => Control
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
      -- hold reset state for 100 ns.
		RST <= '1';
      wait for CLK_period*10;	
		
		RST <= '0';
		for i in 0 to 4 loop	
		 
			A <= '0';
			B <= '0';
			wait for CLK_period;
			A <= '1';
			B <= '1';
			wait for CLK_period; 
			A <= '1'; 
			B <= '0';
			wait for CLK_period;
			A <= '0';
			B <= '1';
			wait for CLK_period;
			 
			A <= '1';
			B <= '0';
			wait for CLK_period;	
			
		end loop;
		
		RST <= '1';
		wait for CLK_period*2; 
		RST <= '0'; 
		
		wait;
   end process;  

END;
   