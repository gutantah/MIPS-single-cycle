library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity InstrDecoder is
    Port ( 
        clk : in std_logic;
        regwrite : in std_logic;
        instr : in std_logic_vector(25 downto 0);
        en : in std_logic;
        regdst : in std_logic;
        extop : in std_logic;
        wd : in std_logic_vector(31 downto 0);
        rd1 : out std_logic_vector(31 downto 0);
        rd2 : out std_logic_vector(31 downto 0);
        ext_imm: out std_logic_vector(31 downto 0);
        func : out std_logic_vector(5 downto 0);
        sa : out std_logic_vector(4 downto 0)
    );
end InstrDecoder;

architecture Behavioral of InstrDecoder is
type rf_type is array(0 to 31) of std_logic_vector(31 downto 0);
signal mem: rf_type:=(others => x"00000000");

signal rs: std_logic_vector(4 downto 0);
signal rt: std_logic_vector(4 downto 0);
signal rd: std_logic_vector(4 downto 0);
signal imm: std_logic_vector(15 downto 0);
signal writeaddr : std_logic_vector(4 downto 0);

begin
rs <= instr(25 downto 21);
rt <= instr(20 downto 16);
rd <= instr(15 downto 11);
func <= instr(5 downto 0);
sa <= instr(10 downto 6);

process(instr,extop, regdst, rd, rt)
begin
    if regdst='1' then 
        writeaddr <= rd;
    else
        writeaddr<=rt;
    end if;
    ext_imm (15 downto 0) <= instr(15 downto 0);
    if extop='1' then
        ext_imm(31 downto 16) <=(others => instr(15));
    else
        ext_imm(31 downto 16) <= (others => '0');
    end if;
end process;

process(clk)
begin
--rf
    if rising_edge(clk) then
        if en = '1' and regwrite = '1' then
            mem(conv_integer(writeaddr))<=wd;
        end if;
    end if;
end process;

rd1<=mem(conv_integer(rs));
rd2<=mem(conv_integer(rt));


end Behavioral;
