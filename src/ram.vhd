library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Ram is
  Port (address: in std_logic_vector(5 downto 0); 
        clk: in std_logic;
        wd: in std_logic_vector(31 downto 0);
        rd: out std_logic_vector(31 downto 0);
        memWrite: in std_logic;
        en: in std_logic);
end Ram;

architecture Behavioral of Ram is
type ram_mem is array(0 to 63) of std_logic_vector(31 downto 0);
signal ram_signal: ram_mem :=(
    0 => x"0000000A", --prag Min: 10
    1 => x"00000014", --prag Max: 20
    2 => x"00000003", --N: 3 
    3 => x"00000000", --(adresa 12) pentru salvarea sumei maxime
    4 => x"00000000", --(adresa 16) salveaza bit_swap
    5 => x"00000005", --v[0] 5 
    6 => x"0000000E", --v[1] 14
    7 => x"00000010", --v[2] 16
    others => x"00000000"
);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and memWrite = '1' then
                ram_signal(conv_integer(address)) <= wd;
            end if;
        end if;
    end process;
    rd <= ram_signal(conv_integer(address));

end Behavioral;