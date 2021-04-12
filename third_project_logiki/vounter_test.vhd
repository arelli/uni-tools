--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:39:04 04/12/2021
-- Design Name:   
-- Module Name:   C:/Xilinx/projects/third_project/vounter_test.vhd
-- Project Name:  third_project
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

ENTITY vounter_test IS
END vounter_test;
 
ARCHITECTURE behavior OF vounter_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT strange_adder
    PORT(
         Clk : IN  std_logic;
         RST : IN  std_logic;
         Control : IN  std_logic_vector(2 downto 0);
         Count : OUT  std_logic_vector(7 downto 0);
         Overflow : OUT  std_logic;
         Underflow : OUT  std_logic;
         Valid : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal RST : std_logic := '0';
   signal Control : std_logic_vector(2 downto 0) := (others => '0');

 	--Outputs
   signal Count : std_logic_vector(7 downto 0);
   signal Overflow : std_logic;
   signal Underflow : std_logic;
   signal Valid : std_logic;

   -- Clock period definitions
--   constant Clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: strange_adder PORT MAP (
          Clk => Clk,
          RST => RST,
          Control => Control,
          Count => Count,
          Overflow => Overflow,
          Underflow => Underflow,
          Valid => Valid
        );

   -- Stimulus process
   stim_proc: process
   begin		

-- A <= std_logic_vector(to_signed(i,4));
		
		-- The reset sequence, that lasts 10 clock cycles
		for i in 0 to 10 loop
			RST   <= '1';
			Clk  <= '0';
			wait for 100 ns;
			RST   <= '1';
			Clk  <= '1';
			wait for 100 ns;	
		end loop;
		
		-- count to 280 with step 5 to observe the overflow(12.400 ns)
		for i in 0 to 56 loop
			Control <= "101";
			RST   <= '0';
			Clk  <= '0';
			wait for 100 ns;
			Control <= "101";
			RST   <= '0';
			Clk  <= '1';
			wait for 100 ns;	
		end loop;
		
		-- reset the circuit to prove it can count again
		for i in 0 to 2 loop
			RST   <= '1';
			Clk  <= '0';
			wait for 100 ns;
			RST   <= '1';
			Clk  <= '1';
			wait for 100 ns;	
		end loop;
		
		-- count to 25 again just for proof of concept
		for i in 0 to 5 loop
			Control <= "101";  -- step +5
			RST   <= '0';
			Clk  <= '0';
			wait for 100 ns;
			Control <= "101";
			RST   <= '0';
			Clk  <= '1';
			wait for 100 ns;	
		end loop;
		
		-- count downwards to demonstrate control change, and Underflow(after 5th loop)
		for i in 0 to 7 loop
			Control <= "000";  -- step -5
			RST   <= '0';
			Clk  <= '0';
			wait for 100 ns;
			Control <= "000";
			RST   <= '0';
			Clk  <= '1';
			wait for 100 ns;	
		end loop;
	

      wait;
   end process;

END;
