library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity InstructionExecute is
  Port(rd1: in std_logic_vector(31 downto 0);
        rd2: in std_logic_vector(31 downto 0);
        ext_imm: in std_logic_vector(31 downto 0);
        sa: in std_logic_vector(4 downto 0);
        func:in std_logic_vector(5 downto 0);
        pc_plus_4: in std_logic_vector(31 downto 0);
        alusrc: in std_logic;
        aluop: in std_logic_vector(2 downto 0);
        
        zero: out std_logic;
        alures: out std_logic_vector(31 downto 0);
        branch_address: out std_logic_vector(31 downto 0)
   );
end InstructionExecute;

architecture Behavioral of InstructionExecute is
signal aluctrl_signal: std_logic_vector(2 downto 0);
signal alu: std_logic_vector(31 downto 0);
signal alu_in2: std_logic_vector(31 downto 0);
begin
alu_in2 <= rd2 when alusrc ='0' else ext_imm;
process(aluop, func)
begin
case aluop is
    when "000" => --tip r
        case func is
            when "100000" => aluctrl_signal <= "000"; --add
            when "100010" => aluctrl_signal <= "001"; --sub
            when "100101" => aluctrl_signal <= "010"; --or
            when "100100" => aluctrl_signal <= "011"; --and
            when "100110" => aluctrl_signal <= "111"; --xor
            
            when "000000" => aluctrl_signal <= "100"; --sll
            when "000010" => aluctrl_signal <= "101"; --srl
            when "101010" => aluctrl_signal <= "110"; --slt
            when others => null;

        end case;
    when "001" => aluctrl_signal <= "000"; --cod + si add
    when "011" => aluctrl_signal <= "001"; --cod - si sub
    when "100" => aluctrl_signal <= "011"; --cod & si and
    when others => aluctrl_signal <= (others => 'X');
end case;
end process;
process(aluctrl_signal, sa, rd1, alu_in2)
begin
case aluctrl_signal is
    when "000" => alu <=rd1+alu_in2;
    when "001" => alu <=rd1-alu_in2;
    when "010" => alu <=rd1 or alu_in2;
    when "011" => alu <=rd1 and alu_in2;
    when "100" => alu <= to_stdlogicvector(to_bitvector(alu_in2) sll conv_integer(sa));
    when "101" => alu <= to_stdlogicvector(to_bitvector(alu_in2) srl conv_integer(sa));
    when "110" => if signed(rd1)<signed(alu_in2) then 
                        alu<=x"00000001"; 
                    else 
                        alu<=x"00000000"; end if;
    when "111" => alu <= rd1 xor alu_in2;
    when others => alu <=(others=>'X');
end case;
end process;
process(alu)
begin
    if alu = x"00000000" then
     zero <= '1';
    else
     zero<='0';
    end if;
end process;

branch_address <= pc_plus_4+(ext_imm(29 downto 0)&"00");
alures<=alu;
end Behavioral;
