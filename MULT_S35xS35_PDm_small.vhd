library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MULT_S35xS35_PDm_small is
  generic (
    m     : integer := 1;
    A_LEN : integer := 35;
    B_LEN : integer := 35;
    s     : integer := 1
  );
  port (
    CLK : in  std_logic;
  
    A   : in  std_logic_vector(A_LEN-1 downto 0);
    B   : in  std_logic_vector(B_LEN-1 downto 0);
    O   : out std_logic_vector(A_LEN + B_LEN - 1 downto 0)
  );
end MULT_S35xS35_PDm_small;

architecture rtl of MULT_S35xS35_PDm_small is

    function Pad(a : std_logic_vector; len : natural; s : integer) return std_logic_vector is
      variable b : std_logic_vector(len-1 downto 0);
    begin
      b := (others => '0');
      b(a'high downto 0) := a;

      -- sign extend when s = 1
      if (s = 1) and (b'high > a'high) then
        b(b'high downto a'high+1) := (others => a(a'high));
      end if;

      return b;
    end function;

  component MULT_S18xS18_PDm is
    generic (
      m : integer := 1
    );
    port (
      A   : in  std_logic_vector(17 downto 0);
      B   : in  std_logic_vector(17 downto 0);
      CLK : in  std_logic;
      O   : out std_logic_vector(35 downto 0)
    );
  end component;
  
  constant small_a : boolean := (A_LEN + 1 - s) <= 18;
  constant small_b : boolean := (B_LEN + 1 - s) <= 18;

  constant NA : integer := A_LEN - 18;      -- 1..18
  constant NB : integer := B_LEN - 18;      -- 1..18
  constant W  : integer := A_LEN + B_LEN;   -- 38..72

  signal a0_18 : std_logic_vector(17 downto 0);
  signal a1_18 : std_logic_vector(17 downto 0);

  signal b0_18 : std_logic_vector(17 downto 0);
  signal b1_18 : std_logic_vector(17 downto 0);

  signal P00 : std_logic_vector(35 downto 0);
  signal P01 : std_logic_vector(35 downto 0);
  signal P10 : std_logic_vector(35 downto 0);
  signal P10P01 : std_logic_vector(36 downto 0);
  signal P11 : std_logic_vector(35 downto 0);

  signal s14   : std_logic_vector(69 downto 0);
  signal s32   : std_logic_vector(69 downto 0);
  signal sum70 : std_logic_vector(69 downto 0);
  signal A35   : std_logic_vector(34 downto 0);
  signal B35   : std_logic_vector(34 downto 0);
  
  signal s1, s2, s3, s4 : std_logic_vector(69 downto 0) := (others => '0');

begin

    A35 <= pad(A, 35, s);
    B35 <= pad(B, 35, s);

    a0_18(16 downto 0) <= A35(16 downto 0);
    b0_18(16 downto 0) <= B35(16 downto 0);

    a1_18 <= A35(34 downto 17);
    b1_18 <= B35(34 downto 17);

    a0_18(17)          <= '0';
    b0_18(17)          <= '0';
  

  U00 : MULT_S18xS18_PDm
    generic map (
      m => m - 1
    )
    port map (
      A   => a0_18,
      B   => b0_18,
      CLK => CLK,
      O   => P00
    );
    s1 <= pad(P00, 70, 0);
    
    gen_U01 : if not small_b generate
      U01 : MULT_S18xS18_PDm
        generic map (
          m => m - 1
        )
        port map (
          A   => a0_18,
          B   => b1_18,
          CLK => CLK,
          O   => P01
        );
      s2 <= pad(P01, 53, 1) & "00000000000000000";
    end generate;

  gen_U10 : if not small_a generate
  U10 : MULT_S18xS18_PDm
    generic map (
      m => m  - 1 
    )
    port map (
      A   => a1_18,
      B   => b0_18,
      CLK => CLK,
      O   => P10
    );
    s3 <= pad(P10, 53, 1) & "00000000000000000";
  end generate;

  gen_U11 : if not (small_a or small_b) generate
  U11 : MULT_S18xS18_PDm
    generic map (
      m => m - 1
    )
    port map (
      A   => a1_18,
      B   => b1_18,
      CLK => CLK,
      O   => P11
    );
    
    s4 <= pad(P11, 36, 1) & "0000000000000000000000000000000000";
    
    process (CLK) begin
        if rising_edge(CLK) then
            S14 <= s1 + s4;
            S32 <= s3 + s2;
        end if;
    end process;
  end generate;
    
    gen_else : if (small_a or small_b) generate
        S14 <= s1 + s4;
        S32 <= s3 + s2;
    end generate;

    sum70 <= S14 + S32;
    O <= sum70(W-1 downto 0);

end rtl;
