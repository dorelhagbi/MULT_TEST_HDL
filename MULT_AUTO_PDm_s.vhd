library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MULT_AUTO_PDm is
  generic (
    A_LEN : integer := 18; -- 1 to 69
    B_LEN : integer := 18; -- 1 to 69
    m     : integer := 1;  -- clock delay (1..4)
    s     : integer := 1   -- 0 = UNSIGNED, 1 = SIGNED
  );
  port (
    CLK : in  std_logic;
    A   : in  std_logic_vector(A_LEN-1 downto 0);
    B   : in  std_logic_vector(B_LEN-1 downto 0);
    O   : out std_logic_vector(A_LEN + B_LEN - 1 downto 0)
  );
end MULT_AUTO_PDm;

architecture RTL of MULT_AUTO_PDm is

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
begin

  gen_m_check : if (m < 1) or (m > 4) generate
    assert false
      report "MULT_AUTO_PDm: unsupported m (only 1,2,3,4)"
      severity failure;
  end generate;

  gen_s18 : if (A_LEN + (1 - s) <= 18) and (B_LEN + (1 - s) <= 18) generate
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

  gen_numeric : if not ((A_LEN + (1 - s) <= 18) and (B_LEN + (1 - s) <= 18)) generate
    signal p1, p2, p3, p4 : std_logic_vector(A_LEN + B_LEN - 1 downto 0);
    signal mult_v : std_logic_vector(A_LEN + B_LEN - 1 downto 0);

  begin
    process (CLK)
    begin
      if rising_edge(CLK) then
        if s = 1 then
          mult_v <= std_logic_vector(signed(A) * signed(B));
        else
          mult_v <= std_logic_vector(unsigned(A) * unsigned(B));
        end if;

        p1 <= mult_v;
        p2 <= p1;
        p3 <= p2;
        p4 <= p3;

        case m is
          when 1 => O <= p1;
          when 2 => O <= p2;
          when 3 => O <= p3;
          when 4 => O <= p4;
          when others => O <= (others => '0');
        end case;
      end if;
    end process;
  end generate;

end RTL;
