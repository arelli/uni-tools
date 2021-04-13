----------------------------------------------------------------------------------
-- Engineer: 
-- 
-- Create Date:    17:44:41 03/23/2021 
-- Design Name: 
-- Module Name:    topLevel - Behavioral 
-- Project Name: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity topLevel is
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           Cin : in  STD_LOGIC;
           Cout : out  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (3 downto 0));
end topLevel;

architecture Behavioral of topLevel is

	
	component C_P_unit
		Port ( Acp : in  STD_LOGIC_VECTOR (3 downto 0);
           Bcp : in  STD_LOGIC_VECTOR (3 downto 0);
           Pcp : out  STD_LOGIC_VECTOR (3 downto 0);
           Gcp : out  STD_LOGIC_VECTOR (3 downto 0) );
   end component;
	
	component Sum_Unit
		Port ( Cin_sum : in  STD_LOGIC;
           Csum : in  STD_LOGIC_VECTOR (2 downto 0);
           Psum : in  STD_LOGIC_VECTOR (3 downto 0);
           Ssum : out  STD_LOGIC_VECTOR (3 downto 0) );
	end component;
	
	component carry_lookahead_unit
		Port ( P : in  STD_LOGIC_VECTOR (3 downto 0);
           G : in  STD_LOGIC_VECTOR (3 downto 0);
           Cin_cla : in  STD_LOGIC;
           Cfinal : out  STD_LOGIC;
           Cout_cla : out  STD_LOGIC_VECTOR (2 downto 0) );	
	end component;
	
	signal Psignal: STD_LOGIC_VECTOR (3 downto 0);
	signal Gsignal : STD_LOGIC_VECTOR (3 downto 0);
	signal Csignal : STD_LOGIC_VECTOR (2 downto 0);
	
	begin
	
		C_P_Unit1 : C_P_unit	              
		Port map(   Acp => A,                
						Bcp => B,                
						Pcp => Psignal,          
						Gcp => Gsignal);         
						                       
		CLA1 : carry_lookahead_unit        
		Port map( 	P => Psignal ,         
						G => Gsignal,          
						Cin_cla => Cin,            
						Cfinal => Cout,        
						Cout_cla => Csignal);     
						                       
		Sum_Unit1 : Sum_Unit               
		Port map (  Cin_sum => Cin ,           
						Csum => Csignal,          
						Psum => Psignal,          
						Ssum =>  S);         
						                       

end Behavioral;

