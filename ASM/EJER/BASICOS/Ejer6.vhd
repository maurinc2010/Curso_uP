library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ejer6 is 
	port 
     (Reset, Enable, Clock : in  std_logic;
	  Inc_C : out std_logic;
      Count : out  std_logic_vector(3 downto 0));
end Ejer6;

architecture comportamental of Ejer6 is
begin
	process (clock,reset)
		variable cnt : unsigned(3 downto 0);
	begin
		if Reset = '0' then 
			cnt := "0000";
			Inc_C <= '0';
		elsif rising_edge(Clock) then
			if Enable = '1' then
				cnt  := cnt + 1;
				Inc_C <= '0';
				if cnt = "1010" then
					cnt := "0000";
					Inc_C <= '1';
				end if;
			end if;
		end if;
		Count <= std_logic_vector(cnt);
	end process;
end comportamental;
