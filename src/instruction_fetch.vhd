library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity InstructionFetch is
  Port (jump: in std_logic;
        jumpAddress: in std_logic_vector(31 downto 0);
        pcSrc: in std_logic; 
        branchAddress: in std_logic_vector(31 downto 0);
        en: in std_logic;
        rst: in std_logic;
        clk: in std_logic;
        pcPlus4: out std_logic_vector(31 downto 0);
        instruction: out std_logic_vector(31 downto 0) );
end InstructionFetch;

architecture Behavioral of InstructionFetch is

type mem_rom is array(0 to 63) of std_logic_vector(31 downto 0);
signal rom_signal : mem_rom := (
    0  => B"100011_00000_00001_0000000000000000",   -- x"8C010000" | PC:0   | lw $1, 0($0)                      | incarca valoarea min din ram 
    1  => B"100011_00000_00010_0000000000000100",   -- x"8C020004" | PC:4   | lw $2, 4($0)                      | incarca valoarea max din ram
    2  => B"100011_00000_00011_0000000000001000",   -- x"8C030008" | PC:8   | lw $3, 8($0)                      | incarca numarul de elemente din ram
    3  => B"000000_00000_00000_00101_00000_100000", -- x"00002820" | PC:12  | add $5, $0, $0                    | init contorul (i=0)
    4  => B"001000_00000_00100_0000000000010100",   -- x"20040014" | PC:16  | addi $4, $0, 20                   | init adresa de start a vectorului
    5  => B"000000_00000_00000_00110_00000_100000", -- x"00003020" | PC:20  | add $6, $0, $0                    | init suma numere pare
    6  => B"000000_00000_00000_00111_00000_100000", -- x"00003820" | PC:24  | add $7, $0, $0                    | init suma numere impare
    7  => B"000100_00101_00011_0000000000001101",   -- x"10A3000D" | PC:28  | loop: beq $5, $3, final           | daca i=N iesire din loop
    8  => B"100011_00100_01000_0000000000000000",   -- x"8C880000" | PC:32  | lw $8, 0($4)                      | incarca elementul v[i] din ram
    9  => B"000000_01000_00001_01110_00000_101010", -- x"0101702A" | PC:36  | slt $14, $8, $1                   | $14=1 daca v[i] < min altfel 0
    10 => B"000101_01110_00000_0000000000000111",   -- x"15C00007" | PC:40  | bne $14, $0, skip                 | daca v[i] < min jump la urmatorul element
    11 => B"000000_00010_01000_01110_00000_101010", -- x"0048702A" | PC:44  | slt $14, $2, $8                   | $14=1 daca v[i] > max altfel 0
    12 => B"000101_01110_00000_0000000000000101",   -- x"15C00005" | PC:48  | bne $14, $0, skip                 | daca v[i] > max jump la urmatorul element
    13 => B"001100_01000_01001_0000000000000001",   -- x"31090001" | PC:52  | andi $9, $8, 1                    | verifica ultimul bit daca numarul este par sau impar
    14 => B"000100_01001_00000_0000000000000010",   -- x"11200002" | PC:56  | beq $9, $0, par                   | daca e par sari la eticheta par
    15 => B"000000_00111_01000_00111_00000_100000", -- x"00E83820" | PC:60  | add $7, $7, $8                    | adauga v[i] la suma impara
    16 => B"000010_00000000000000000000010010",     -- x"08000012" | PC:64  | j skip                            | sare la eticheta skip
    17 => B"000000_00110_01000_00110_00000_100000", -- x"00C83020" | PC:68  | par: add $6, $6, $8               | adauga v[i] la suma para
    18 => B"001000_00100_00100_0000000000000100",   -- x"20840004" | PC:72  | skip: addi $4, $4, 4              | inc adresa vectorului
    19 => B"001000_00101_00101_0000000000000001",   -- x"20A50001" | PC:76  | addi $5, $5, 1                    | inc contor (i++)
    20 => B"000010_00000000000000000000000111",     -- x"08000007" | PC:80  | j loop                            | sare la inceputul loop
    21 => B"000000_00110_00111_00101_00000_101010", -- x"00C7282A" | PC:84  | final: slt $5, $6, $7             | $5 = 1 daca suma para < suma impara, altfel 0
    22 => B"000100_00101_00000_0000000000000010",   -- x"10A00002" | PC:88  | beq $5, $0, max_par               | daca suma para >= suma impara sari la max par
    23 => B"101011_00000_00111_0000000000001100",   -- x"AC07000C" | PC:92  | sw $7, 12($0)                     | salveaza suma impara ca suma maxima la adresa 12
    24 => B"000010_00000000000000000000011010",     -- x"0800001A" | PC:96  | j bit_swap                        | sari la bit_swap
    25 => B"101011_00000_00110_0000000000001100",   -- x"AC06000C" | PC:100 | max_par: sw $6, 12($0)            | salveaza suma para ca suma maxima la adresa 12
    26 => B"100011_00000_01010_0000000000001100",   -- x"8C0A000C" | PC:104 | bit_swap: lw $10, 12($0)          | incarca suma maxima din ram
    27 => B"000000_00000_00000_01011_00000_100000", -- x"00005820" | PC:108 | add $11, $0, $0                   | initializeaza rezultatul bit_swap cu 0 
    28 => B"001000_00000_01100_0000000000100000",   -- x"200C0020" | PC:112 | addi $12, $0, 32                  | initializeaza contorul celor 32 de biti (j=32)
    29 => B"000100_01100_00000_0000000000000110",   -- x"11800006" | PC:116 | swap_loop: beq $12, $0, end_swap  | daca s-au procesat toti cei 32 de biti sare la final
    30 => B"001100_01010_01101_0000000000000001",   -- x"314D0001" | PC:120 | andi $13, $10, 1                  | extrage LSB 
    31 => B"000000_00000_01011_01011_00001_000000", -- x"000B5840" | PC:124 | sll $11, $11, 1                   | shifteaza logic la stanga rezultatul pentru a face loc bitului
    32 => B"000000_01011_01101_01011_00000_100101", -- x"016D5825" | PC:128 | or $11, $11, $13                  | insereaza bitul extras in rezultatul inversat
    33 => B"000000_00000_01010_01010_00001_000010", -- x"000A5042" | PC:132 | srl $10, $10, 1                   | shifteaza logic la dreapta numarul sursa pentru urmatorul bit
    34 => B"001000_01100_01100_1111111111111111",   -- x"218CFFFF" | PC:136 | addi $12, $12, -1                 | decrementeaza contorul (j--)
    35 => B"000010_00000000000000000000011101",     -- x"0800001D" | PC:140 | j swap_loop                       | sare la incepului swap_loop
    36 => B"101011_00000_01011_0000000000010000",   -- x"AC0B0010" | PC:144 | end_swap: sw $11, 16($0)          | salveaza numarul inversat in ram la adresa 16
    others => X"00000000"
);

signal address: std_logic_vector(5 downto 0);
signal d: std_logic_vector(31 downto 0);
signal q: std_logic_vector(31 downto 0);
signal add: std_logic_vector(31 downto 0);

signal mux_br: std_logic_vector(31 downto 0);

begin
process(clk, rst)
begin
    if rst = '1' then
        q <= (others => '0');
    elsif rising_edge(clk) then
        if en = '1' then
            q <= d;
        end if;
    end if;
end process;
    
    add <= q + 4;
    pcPlus4 <= add;
    mux_br <= branchAddress when pcSrc = '1' else add;
    d <= jumpAddress when jump = '1' else mux_br;
    address <= q(7 downto 2);
    instruction <= rom_signal(conv_integer(address)); 
end Behavioral;