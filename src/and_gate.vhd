
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AND_GATE is
    Port (
        A : in STD_LOGIC;
        B : in STD_LOGIC;
        Y : out STD_LOGIC
    );
end AND_GATE;

architecture RTL of AND_GATE is
begin
    Y <= A AND B;
end RTL;
