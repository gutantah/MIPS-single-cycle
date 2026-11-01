library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
 Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is
signal en: std_logic;

signal branch_address_signal: std_logic_vector(31 downto 0);
signal jump_address_signal:std_logic_vector(31 downto 0);
signal pcsrc_signal: std_logic;
signal instr_signal: std_logic_vector(31 downto 0);
signal pc_plus_4_signal: std_logic_vector(31 downto 0);

--uc
signal regDst_signal: std_logic;
signal extOp_signal: std_logic;
signal aluSrc_signal: std_logic;
signal branch_signal: std_logic;
signal bne_signal: std_logic;
signal jump_signal: std_logic;
signal aluOp_signal: std_logic_vector(2 downto 0);
signal memWrite_signal: std_logic;
signal memToReg_signal: std_logic;
signal regWrite_signal: std_logic;

signal rd1_signal: std_logic_vector(31 downto 0);
signal rd2_signal: std_logic_vector(31 downto 0);
signal ext_imm_signal: std_logic_vector(31 downto 0);
signal func_signal: std_logic_vector(5 downto 0);
signal sa_signal: std_logic_vector(4 downto 0);
signal wd_signal: std_logic_vector(31 downto 0);

signal zero_signal: std_logic;
signal alures_signal: std_logic_vector(31 downto 0);

signal memdata_signal: std_logic_vector(31 downto 0);
signal aluresout_signal: std_logic_vector(31 downto 0);


signal mux: std_logic_vector(31 downto 0);
signal selection: std_logic_vector(2 downto 0);

component mpg is
 Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component ssd is
Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

component InstructionFetch is
  Port (jump: in std_logic;
        jumpAddress: in std_logic_vector(31 downto 0);
        pcSrc: in std_logic; 
        branchAddress: in std_logic_vector(31 downto 0);
        en: in std_logic;
        rst: in std_logic;
        clk: in std_logic;
        pcPlus4: out std_logic_vector(31 downto 0);
        instruction: out std_logic_vector(31 downto 0) );
end component;

component InstrDecoder is
Port (regWrite: in std_logic;
        instr: in std_logic_vector(25 downto 0);
        regDst: in std_logic;    
        en: in std_logic;
        extOp: in std_logic;  
        wd: in std_logic_vector(31 downto 0);
        rd1: out std_logic_vector(31 downto 0);
        rd2: out std_logic_vector(31 downto 0);
        ext_imm: out std_logic_vector(31 downto 0);
        func: out std_logic_vector(5 downto 0); 
        sa: out std_logic_vector(4 downto 0);
        clk: in std_logic
   );
end component;

component ControlUnit is
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
end component;
component InstructionExecute is
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
end component; 
component MEM is
Port (memWrite: in std_logic;
        aluResIn: in std_logic_vector(31 downto 0);
        rd2: in std_logic_vector(31 downto 0);
        clk: in std_logic;
        en: in std_logic;
        memData: out std_logic_vector(31 downto 0);
        aluResOut: out std_logic_vector(31 downto 0)
       );
end component;
begin
    mpg_label: mpg port map(
        enable => en,
        btn => btn(0),
        clk => clk
    );
    
    ssd_label: ssd port map(
        clk => clk,
        digits => mux,
        cat => cat,
        an => an
    );
    
    IF_Fetch_label: InstructionFetch port map(
        jump => jump_signal,
        jumpAddress => jump_address_signal,
        pcSrc => pcsrc_signal,
        branchAddress => branch_address_signal,
        en => en,
        rst => btn(1),
        clk => clk,
        pcPlus4 => pc_plus_4_signal,
        instruction => instr_signal
    );
    
    InstructionDecode_label: InstrDecoder port map(
        regWrite => regWrite_signal,
        instr => instr_signal(25 downto 0),
        regDst => regDst_signal,
        en => en,
        extOp => extOp_signal,
        wd => wd_signal,
        rd1 => rd1_signal,
        rd2 => rd2_signal,
        ext_imm => ext_imm_signal,
        func => func_signal,
        sa => sa_signal,
        clk => clk
    );
    
    ControlUnit_label: ControlUnit port map(
        instr => instr_signal(31 downto 26),
        branch => branch_signal,
        bne => bne_signal,
        regDst => regDst_signal,
        extOp => extOp_signal,
        aluSrc => aluSrc_signal,
        jump => jump_signal,
        aluOp => aluOp_signal,
        memWrite => memWrite_signal,
        memToReg => memToReg_signal,
        regwrite => regwrite_signal
    );
    
    InstructionExecute_label: InstructionExecute port map(
        rd1 => rd1_signal,
        rd2 => rd2_signal,
        ext_imm => ext_imm_signal,
        sa => sa_signal,
        func =>func_signal,
        pc_plus_4 => pc_plus_4_signal,
        alusrc => alusrc_signal,
        aluop => aluop_signal,
        
        zero => zero_signal,
        alures => alures_signal,
        branch_address => branch_address_signal
   );
   
   MEM_label: MEM port map(
        memWrite => memwrite_signal,
        aluResIn =>alures_signal,
        rd2 => rd2_signal,
        clk => clk,
        en => en,
        memData => memdata_signal,
        aluResOut => aluresout_signal
   );
   
wd_signal <= memdata_signal when memtoreg_signal='1' else aluresout_signal;
pcsrc_signal <= (zero_signal and branch_signal) or (not zero_signal and bne_signal);
jump_address_signal <= pc_plus_4_signal(31 downto 28) & instr_signal(25 downto 0) &"00";
    
selection <= sw(7 downto 5);
process(selection)
begin
    case selection is
        when "000" => mux <= instr_signal;
        when "001" => mux <= pc_plus_4_signal;
        when "010" => mux <= rd1_signal;
        when "011" => mux <= rd2_signal;
        when "100" => mux <= ext_imm_signal;
        when "101" => mux <= alures_signal;
        when "110" => mux <= memdata_signal;
        when "111" => mux <= wd_signal;
    end case;   
end process;
    
led(11 downto 9)<=aluop_signal;    
led(8)<=regdst_signal;
led(7)<=extop_signal;
led(6)<=alusrc_signal;
led(5)<=branch_signal;
led(4)<=bne_signal;
led(3)<=jump_signal;
led(2)<=memwrite_signal;
led(1)<=memtoreg_signal;
led(0)<=regwrite_signal;
end Behavioral;