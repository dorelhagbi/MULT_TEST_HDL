library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MULT_S69xS69_PDm is
  generic (
    m     : integer := 2;
    A_LEN : integer := 69;
    B_LEN : integer := 69;
    s     : integer := 1
  );
  port (
    CLK : in  std_logic;

    A   : in  std_logic_vector(A_LEN-1 downto 0);
    B   : in  std_logic_vector(B_LEN-1 downto 0);
    O   : out std_logic_vector(A_LEN + B_LEN - 1 downto 0)
  );
end MULT_S69xS69_PDm;

architecture rtl of MULT_S69xS69_PDm is

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

  component MULT_S35xS35_PDm is
    generic (
      m     : integer := 1;
      A_LEN : integer := 35;
      B_LEN : integer := 35
    );
    port (
      CLK : in  std_logic;

      A   : in  std_logic_vector(34 downto 0);
      B   : in  std_logic_vector(34 downto 0);
      O   : out std_logic_vector(69 downto 0)
    );
  end component;

  constant NA : integer := A_LEN - 35;     -- 1..35 (for 69 -> 34)
  constant NB : integer := B_LEN - 35;     -- 1..35 (for 69 -> 34)
  constant W  : integer := A_LEN + B_LEN;  -- 70..138 (for 69x69 -> 138)

  signal a0_35 : std_logic_vector(34 downto 0);
  signal a1_35 : std_logic_vector(34 downto 0);

  signal b0_35 : std_logic_vector(34 downto 0);
  signal b1_35 : std_logic_vector(34 downto 0);

  signal P00 : std_logic_vector(69 downto 0);
  signal P01 : std_logic_vector(69 downto 0);
  signal P10 : std_logic_vector(69 downto 0);
  signal P11 : std_logic_vector(69 downto 0);

  signal S12  : std_logic_vector(137 downto 0);
  signal S34  : std_logic_vector(137 downto 0);
  signal sum138 : std_logic_vector(137 downto 0);

  signal A69 : std_logic_vector(68 downto 0);
  signal B69 : std_logic_vector(68 downto 0);

  signal s1, s2, s3, s4 : std_logic_vector(137 downto 0);

begin

  A69 <= Pad(A, 69, s);
  B69 <= Pad(B, 69, s);

    a0_35(33 downto 0) <= A69(33 downto 0);
    b0_35(33 downto 0) <= B69(33 downto 0);

    a0_35(34) <= '0';
    b0_35(34) <= '0';

    a1_35 <= A69(68 downto 34);
    b1_35 <= B69(68 downto 34);

  U00 : MULT_S35xS35_PDm
    generic map (
      m => m - 1
    )
    port map (
      A   => a0_35,
      B   => b0_35,
      CLK => CLK,
      O   => P00
    );

  U01 : MULT_S35xS35_PDm
    generic map (
      m => m - 1
    )
    port map (
      A   => a0_35,
      B   => b1_35,
      CLK => CLK,
      O   => P01
    );

  U10 : MULT_S35xS35_PDm
    generic map (
      m => m - 1
    )
    port map (
      A   => a1_35,
      B   => b0_35,
      CLK => CLK,
      O   => P10
    );

  U11 : MULT_S35xS35_PDm
    generic map (
      m => m - 1
    )
    port map (
      A   => a1_35,
      B   => b1_35,
      CLK => CLK,
      O   => P11
    );

    s1 <= pad(P00, 138, 0);
    s2 <= pad(P10, 104, 1) & "0000000000000000000000000000000000"; -- 34 zeros
    s3 <= pad(P01, 104, 1) & "0000000000000000000000000000000000"; -- 34 zeros
    s4 <= pad(P11, 70,  1) & "00000000000000000000000000000000000000000000000000000000000000000000"; -- 68 zeros


  process(CLK) begin
    if rising_edge(CLK) then
      S12 <= s1 + s2;
      S34 <= s3 + s4;
    end if;
  end process;

  sum138 <= S12 + S34;
  O <= sum138(W-1 downto 0);

end rtl;
