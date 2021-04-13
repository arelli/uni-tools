
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY C_P_Unit_test IS
END C_P_Unit_test;
 
ARCHITECTURE behavior OF C_P_Unit_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT C_P_unit
    PORT(
         Acp : IN  std_logic_vector(3 downto 0);
         Bcp : IN  std_logic_vector(3 downto 0);
         Pcp : OUT  std_logic_vector(3 downto 0);
         Gcp : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Acp : std_logic_vector(3 downto 0) := (others => '0');
   signal Bcp : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal Pcp : std_logic_vector(3 downto 0);
   signal Gcp : std_logic_vector(3 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   --constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: C_P_unit PORT MAP (
          Acp => Acp,
          Bcp => Bcp,
          Pcp => Pcp,
          Gcp => Gcp
        );

   -- Stimulus process
   stim_proc: process
   begin		
	
		wait for 100 ns;
		
      Acp <="0000" ;
		Bcp <= "0001";
      wait for 100 ns;	
		
		Acp<="0010";
		Bcp <= "0001";
      wait for 100 ns;
		
		Acp<="0010";
		Bcp <= "0011";
      wait for 100 ns;
		
		Acp<="0011";
		Bcp <= "0111";
      wait for 100 ns;
		
      wait;
   end process;

END;
