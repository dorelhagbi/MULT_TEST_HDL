library IEEE;
use IEEE.std_logic_1164.all;

entity top_MULT_S69xS69_10x is
  port (
    CLK  : in  std_logic;
    AIN  : in  std_logic;
    BIN  : in  std_logic;
    DOUT : out std_logic
  );
end top_MULT_S69xS69_10x;

architecture rtl of top_MULT_S69xS69_10x is
  constant N : integer := 69;
  constant W : integer := 2*N;

  signal A : std_logic_vector(N-1 downto 0) := (others => '0');
  signal B : std_logic_vector(N-1 downto 0) := (others => '0');

  signal O0, O1, O2, O3, O4 : std_logic_vector(W-1 downto 0);
  signal O5, O6, O7, O8, O9 : std_logic_vector(W-1 downto 0);

  signal dout_r : std_logic := '0';

  attribute syn_keep : boolean;
  attribute syn_keep of A : signal is true;
  attribute syn_keep of B : signal is true;
  attribute syn_keep of O0, O1, O2, O3, O4, O5, O6, O7, O8, O9 : signal is true;
  attribute syn_keep of dout_r : signal is true;

begin

  process(CLK)
  begin
    if rising_edge(CLK) then
      A <= A(N-2 downto 0) & AIN;
      B <= B(N-2 downto 0) & BIN;
      dout_r <= O0(0) xor O1(0) xor O2(0) xor O3(0) xor O4(0) xor
                O5(0) xor O6(0) xor O7(0) xor O8(0) xor O9(0);
    end if;
  end process;

  DOUT <= dout_r;

  -- 10 instances total: m=3 (5x), m=4 (5x)
  U0 : entity work.MULT_S69xS69_PDm generic map (m => 5, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O0);

  U1 : entity work.MULT_S69xS69_PDm generic map (m => 4, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O1);

  U2 : entity work.MULT_S69xS69_PDm generic map (m => 4, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O2);

  U3 : entity work.MULT_S69xS69_PDm generic map (m => 4, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O3);

  U4 : entity work.MULT_S69xS69_PDm generic map (m => 4, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O4);

  U5 : entity work.MULT_S69xS69_PDm generic map (m => 4, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O5);

  U6 : entity work.MULT_S69xS69_PDm generic map (m => 4, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O6);

  U7 : entity work.MULT_S69xS69_PDm generic map (m => 4, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O7);

  U8 : entity work.MULT_S69xS69_PDm generic map (m => 4, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O8);

  U9 : entity work.MULT_S69xS69_PDm generic map (m => 4, A_LEN => N, B_LEN => N)
    port map (CLK => CLK, A => A, B => B, O => O9);

end rtl;
