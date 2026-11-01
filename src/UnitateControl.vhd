library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
  Port (instr: in std_logic_vector(5 downto 0);
        branch: out std_logic;
        bne: out std_logic;
        regDst: out std_logic;
        extOp: out std_logic;
        aluSrc: out std_logic;
        jump: out std_logic;
        aluOp: out std_logic_vector(2 downto 0);
        memWrite: out std_logic;
        memToReg: out std_logic;
        regwrite: out std_logic
      );
end ControlUnit;

architecture Behavioral of ControlUnit is

begin
    process(instr)
    begin
        regDst <= '0';
        branch <= '0';
        bne <='0';
        extOp <= '0';
        aluSrc <= '0';
        jump <= '0';
        aluOp <= "000";
        memWrite <= '0';
        memToReg <= '0';
        regwrite <= '0';
        case instr is
           when "000000" =>  --tip r
            regDst<='1';
            regwrite<='1';
            aluop<="000";
           when "001000" => -- addi
            extop<='1';
            alusrc<='1';
            regwrite<='1';
            aluop<="001";   --cod+
           when  "100011" => --lw
            extop<='1';
            alusrc<='1';
            regwrite<='1';
            memtoreg<='1';
            aluop<="001";   --cod+
           when "101011" => --sw
            extop<='1';
            alusrc<='1';
            memwrite<='1';
            aluop<="001";
           when "000100" => --beq
            branch<='1';
            aluop<="011";    --cod-
           when "000101" => --bne
            bne<='1';
            aluop<="011";
           when "001100" => --andi
            alusrc<='1';
            regwrite<='1';
            aluop<="100"; --&
           when "000010" => --j
            jump<='1';
           when others =>
            null;
           end case;
   end process;
      

end Behavioral;