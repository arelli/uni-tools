--------------------------------------------------------------------------------
-- Create Date:   19:35:36 03/23/2021
-- Design Name:   
-- Module Name:   C:/Xilinx/projects/second_lab/AdderTest.vhd
-- Project Name:  second_lab
------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY AdderTest IS
END AdderTest;
 
ARCHITECTURE behavior OF AdderTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT topLevel
    PORT(
         A : IN  std_logic_vector(3 downto 0);
         B : IN  std_logic_vector(3 downto 0);
         Cin : IN  std_logic;
         Cout : OUT  std_logic;
         S : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic_vector(3 downto 0) := (others => '0');
   signal B : std_logic_vector(3 downto 0) := (others => '0');
   signal Cin : std_logic := '0';

 	--Outputs
   signal Cout : std_logic;
   signal S : std_logic_vector(3 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   --constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: topLevel PORT MAP (
          A => A,
          B => B,
          Cin => Cin,
          Cout => Cout,
          S => S
        );

 

   -- Stimulus process
   stim_proc: process
   begin		
      A <= "0000";
		B <= "0000";
		Cin <= '0';
      wait for 100 ns;	
		
		A <= "0000";
		B <= "0000";
		Cin <= '0';
      wait for 100 ns;
		
		A <= "0100";
		B <= "1000";
		Cin <= '0';
      wait for 100 ns;
		
		A <= "0010";
		B <= "0010";
		Cin <= '1';
      wait for 100 ns;

      
      wait;
   end process;

END;
