library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MEM is
  Port (memWrite: in std_logic;
        aluResIn: in std_logic_vector(31 downto 0);
        rd2: in std_logic_vector(31 downto 0);
        clk: in std_logic;
        en: in std_logic;
        memData: out std_logic_vector(31 downto 0);
        aluResOut: out std_logic_vector(31 downto 0)
       );
end MEM;

architecture Behavioral of MEM is
signal rd_signal: std_logic_vector(31 downto 0);

component Ram is
    Port (address: in std_logic_vector(5 downto 0); 
        clk: in std_logic;
        wd: in std_logic_vector(31 downto 0);
        rd: out std_logic_vector(31 downto 0);
        memWrite: in std_logic;
        en: in std_logic);
end component;

begin
    ram_label: Ram port map(
        address => aluResIn(7 downto 2),
        clk => clk,
        wd => rd2,
        memWrite => memWrite,
        en => en,  
        rd => rd_signal
    );
    
    memData <= rd_signal;
    aluResOut <= aluResIn;

end Behavioral;