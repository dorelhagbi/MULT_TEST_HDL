library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MULT_AUTO_PDm_full is
  generic (
    A_LEN : integer := 18; -- 1 to 69
    B_LEN : integer := 18; -- 1 to 69
    m     : integer := 1;  -- for max_len > 35 m >= 2
    s     : integer := 1   -- 0 to UNSIGN 1 to SIGN
  );
  port (
    CLK : in  std_logic;
    A   : in  std_logic_vector(A_LEN-1 downto 0);
    B   : in  std_logic_vector(B_LEN-1 downto 0);
    O   : out std_logic_vector(A_LEN + B_LEN - 1 downto 0)
  );
end MULT_AUTO_PDm_full;

architecture RTL of MULT_AUTO_PDm_full is

  component MULT_S18xS18_PDm is
    generic (
      AL : integer := 18;
      BL : integer := 18;
      m  : integer := 1;
      s  : integer := 1
    );
    port (
      A   : in  std_logic_vector((AL - 1) downto 0);
      B   : in  std_logic_vector((BL - 1) downto 0);
      CLK : in  std_logic;
      O   : out std_logic_vector((AL + BL - 1) downto 0)
    );
  end component;

  component MULT_S35xS35_PDm is
    generic (
      m     : integer := 1;
      s     : integer := 1;
      A_LEN : integer := 35;
      B_LEN : integer := 35
    );
    port (
      CLK : in  std_logic;
      A   : in  std_logic_vector(A_LEN-1 downto 0);
      B   : in  std_logic_vector(B_LEN-1 downto 0);
      O   : out std_logic_vector(A_LEN + B_LEN - 1 downto 0)
    );
  end component;

  component MULT_S69xS69_PDm is
    generic (
      m     : integer := 2;
      s     : integer := 1;
      A_LEN : integer := 69;
      B_LEN : integer := 69
    );
    port (
      CLK : in  std_logic;
      A   : in  std_logic_vector(A_LEN-1 downto 0);
      B   : in  std_logic_vector(B_LEN-1 downto 0);
      O   : out std_logic_vector(A_LEN + B_LEN - 1 downto 0)
    );
  end component;

  function max_int(a : integer; b : integer) return integer is
  begin
    if a >= b then
      return a;
    else
      return b;
    end if;
  end function;

  constant BASE_MAX_LEN : integer := max_int(A_LEN, B_LEN);
  constant MAX_LEN      : integer := BASE_MAX_LEN + (1 - s);

begin

  gen_s18 : if (MAX_LEN <= 18) generate
    u_mult : MULT_S18xS18_PDm
      generic map (
        AL => A_LEN,
        BL => B_LEN,
        m  => m,
        s  => s
      )
      port map (
        CLK => CLK,
        A   => A,
        B   => B,
        O   => O
      );
  end generate;

  gen_s35 : if (MAX_LEN > 18) and (MAX_LEN <= 35) generate
    u_mult : MULT_S35xS35_PDm
      generic map (
        m     => m,
        s     => s,
        A_LEN => A_LEN,
        B_LEN => B_LEN
      )
      port map (
        CLK => CLK,
        A   => A,
        B   => B,
        O   => O
      );
  end generate;

  gen_s69 : if (MAX_LEN > 35) and (MAX_LEN <= 69) generate
    u_mult : MULT_S69xS69_PDm
      generic map (
        m     => m,
        s     => s,
        A_LEN => A_LEN,
        B_LEN => B_LEN
      )
      port map (
        CLK => CLK,
        A   => A,
        B   => B,
        O   => O
      );
  end generate;

  gen_ovf : if (MAX_LEN > 69) generate
    assert false
      report "MULT_AUTO_PDm: unsupported operand length (MAX_LEN > 69)"
      severity failure;
  end generate;

end RTL;
