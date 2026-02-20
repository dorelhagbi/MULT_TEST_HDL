library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity MULT_S18xS18_PDm is
  generic (
    AL: integer := 18;
    BL: integer := 18;
    m : integer := 1;
    s : integer := 1
    );
  port (
    A   : in  std_logic_vector((AL - 1) downto 0);
    B   : in  std_logic_vector((BL - 1) downto 0);
    CLK : in  std_logic;
    O   : out std_logic_vector((AL + BL -1) downto 0)
  );
end MULT_S18xS18_PDm;

architecture architecture_MULT_S18xS18_PDm of MULT_S18xS18_PDm is

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



  signal P      : std_logic_vector(47 downto 0);
  signal P_d    : std_logic_vector(47 downto 0);
  signal result : std_logic_vector((AL + BL - 1) downto 0);

  component MACC_PA
    port(
      CLK : in STD_LOGIC;
      AL_N : in STD_LOGIC;
      A : in STD_LOGIC_VECTOR(17 downto 0);
      A_EN : in STD_LOGIC;
      A_SRST_N : in STD_LOGIC;
      A_BYPASS : in STD_LOGIC;
      B : in STD_LOGIC_VECTOR(17 downto 0);
      B_EN : in STD_LOGIC;
      B_SRST_N : in STD_LOGIC;
      B_BYPASS : in STD_LOGIC;
      C : in STD_LOGIC_VECTOR(47 downto 0);
      C_ARST_N : in STD_LOGIC;
      C_EN : in STD_LOGIC;
      C_SRST_N : in STD_LOGIC;
      C_BYPASS : in STD_LOGIC;
      CARRYIN : in STD_LOGIC;
      D : in STD_LOGIC_VECTOR(17 downto 0);
      D_ARST_N : in STD_LOGIC;
      D_EN : in STD_LOGIC;
      D_SRST_N : in STD_LOGIC;
      D_BYPASS : in STD_LOGIC;
      P_EN : in STD_LOGIC;
      P_SRST_N : in STD_LOGIC;
      P_BYPASS : in STD_LOGIC;
      CDIN : in STD_LOGIC_VECTOR(47 downto 0);
      PASUB : in STD_LOGIC;
      PASUB_EN : in STD_LOGIC;
      PASUB_SL_N : in STD_LOGIC;
      PASUB_AD_N : in STD_LOGIC;
      PASUB_SD_N : in STD_LOGIC;
      PASUB_BYPASS : in STD_LOGIC;
      CDIN_FDBK_SEL : in STD_LOGIC_VECTOR(1 downto 0);
      CDIN_FDBK_SEL_EN : in STD_LOGIC;
      CDIN_FDBK_SEL_SL_N : in STD_LOGIC;
      CDIN_FDBK_SEL_AD_N : in STD_LOGIC_VECTOR(1 downto 0);
      CDIN_FDBK_SEL_SD_N : in STD_LOGIC_VECTOR(1 downto 0);
      CDIN_FDBK_SEL_BYPASS : in STD_LOGIC;
      ARSHFT17 : in STD_LOGIC;
      ARSHFT17_EN : in STD_LOGIC;
      ARSHFT17_SL_N : in STD_LOGIC;
      ARSHFT17_AD_N : in STD_LOGIC;
      ARSHFT17_SD_N : in STD_LOGIC;
      ARSHFT17_BYPASS : in STD_LOGIC;
      SUB : in STD_LOGIC;
      SUB_EN : in STD_LOGIC;
      SUB_SL_N : in STD_LOGIC;
      SUB_AD_N : in STD_LOGIC;
      SUB_SD_N : in STD_LOGIC;
      SUB_BYPASS : in STD_LOGIC;
      SIMD : in STD_LOGIC;
      DOTP : in STD_LOGIC;
      OVFL_CARRYOUT_SEL : in STD_LOGIC;
      OVFL_CARRYOUT : out STD_LOGIC;
      P : out STD_LOGIC_VECTOR(47 downto 0);
      CDOUT : out STD_LOGIC_VECTOR(47 downto 0)
    );
  end component;

begin

  gen_comb : if m = 0 generate
    result <= signed(A) * signed(B);
	O <= std_logic_vector(result);  
    end generate;

  gen_pd1 : if m = 1 generate
    U_MACC_PA : MACC_PA
      port map(
        CLK => CLK,
        AL_N => '1',
        A => Pad(A,18,s),
        A_EN => '1',
        A_SRST_N => '1',
        A_BYPASS => '1',
        B => Pad(B,18,s),
        B_EN => '1',
        B_SRST_N => '1',
        B_BYPASS => '1',
        C => (others => '0'),
        C_ARST_N => '1',
        C_EN => '1',
        C_SRST_N => '1',
        C_BYPASS => '1',
        CARRYIN => '0',
        D => (others => '0'),
        D_ARST_N => '1',
        D_EN => '1',
        D_SRST_N => '1',
        D_BYPASS => '1',
        P_EN => '1',
        P_SRST_N => '1',
        P_BYPASS => '0',
        CDIN => (others => '0'),
        PASUB => '0',
        PASUB_EN => '1',
        PASUB_SL_N => '1',
        PASUB_AD_N => '1',
        PASUB_SD_N => '0',
        PASUB_BYPASS => '1',
        CDIN_FDBK_SEL => "00",
        CDIN_FDBK_SEL_EN => '1',
        CDIN_FDBK_SEL_SL_N => '1',
        CDIN_FDBK_SEL_AD_N => "11",
        CDIN_FDBK_SEL_SD_N => "00",
        CDIN_FDBK_SEL_BYPASS => '1',
        ARSHFT17 => '0',
        ARSHFT17_EN => '1',
        ARSHFT17_SL_N => '1',
        ARSHFT17_AD_N => '1',
        ARSHFT17_SD_N => '0',
        ARSHFT17_BYPASS => '1',
        SUB => '0',
        SUB_EN => '1',
        SUB_SL_N => '1',
        SUB_AD_N => '1',
        SUB_SD_N => '1',
        SUB_BYPASS => '1',
        SIMD => '0',
        DOTP => '0',
        OVFL_CARRYOUT_SEL => '0',
        OVFL_CARRYOUT => open,
        P => P,
        CDOUT => open
      );
    O(AL+BL-1 downto 0) <= P(AL+BL-1 downto 0);
  end generate;

  gen_pd2 : if m = 2 generate
    U_MACC_PA : MACC_PA
      port map(
        CLK => CLK,
        AL_N => '1',
        A => Pad(A,18,s),
        A_EN => '1',
        A_SRST_N => '1',
        A_BYPASS => '0',
        B => Pad(B,18,s),
        B_EN => '1',
        B_SRST_N => '1',
        B_BYPASS => '0',
        C => (others => '0'),
        C_ARST_N => '1',
        C_EN => '1',
        C_SRST_N => '1',
        C_BYPASS => '1',
        CARRYIN => '0',
        D => (others => '0'),
        D_ARST_N => '1',
        D_EN => '1',
        D_SRST_N => '1',
        D_BYPASS => '1',
        P_EN => '1',
        P_SRST_N => '1',
        P_BYPASS => '0',
        CDIN => (others => '0'),
        PASUB => '0',
        PASUB_EN => '1',
        PASUB_SL_N => '1',
        PASUB_AD_N => '1',
        PASUB_SD_N => '0',
        PASUB_BYPASS => '1',
        CDIN_FDBK_SEL => "00",
        CDIN_FDBK_SEL_EN => '1',
        CDIN_FDBK_SEL_SL_N => '1',
        CDIN_FDBK_SEL_AD_N => "11",
        CDIN_FDBK_SEL_SD_N => "00",
        CDIN_FDBK_SEL_BYPASS => '1',
        ARSHFT17 => '0',
        ARSHFT17_EN => '1',
        ARSHFT17_SL_N => '1',
        ARSHFT17_AD_N => '1',
        ARSHFT17_SD_N => '0',
        ARSHFT17_BYPASS => '1',
        SUB => '0',
        SUB_EN => '1',
        SUB_SL_N => '1',
        SUB_AD_N => '1',
        SUB_SD_N => '1',
        SUB_BYPASS => '1',
        SIMD => '0',
        DOTP => '0',
        OVFL_CARRYOUT_SEL => '0',
        OVFL_CARRYOUT => open,
        P => P,
        CDOUT => open
      );
    O(AL+BL-1 downto 0) <= P(AL+BL-1 downto 0);
  end generate;
  
  
  gen_pd3 : if m = 3 generate
    U_MACC_PA : MACC_PA
      port map(
        CLK => CLK,
        AL_N => '1',
        A => Pad(A,18,s),
        A_EN => '1',
        A_SRST_N => '1',
        A_BYPASS => '0',
        B => Pad(B,18,s),
        B_EN => '1',
        B_SRST_N => '1',
        B_BYPASS => '0',
        C => (others => '0'),
        C_ARST_N => '1',
        C_EN => '1',
        C_SRST_N => '1',
        C_BYPASS => '1',
        CARRYIN => '0',
        D => (others => '0'),
        D_ARST_N => '1',
        D_EN => '1',
        D_SRST_N => '1',
        D_BYPASS => '1',
        P_EN => '1',
        P_SRST_N => '1',
        P_BYPASS => '0',
        CDIN => (others => '0'),
        PASUB => '0',
        PASUB_EN => '1',
        PASUB_SL_N => '1',
        PASUB_AD_N => '1',
        PASUB_SD_N => '0',
        PASUB_BYPASS => '1',
        CDIN_FDBK_SEL => "00",
        CDIN_FDBK_SEL_EN => '1',
        CDIN_FDBK_SEL_SL_N => '1',
        CDIN_FDBK_SEL_AD_N => "11",
        CDIN_FDBK_SEL_SD_N => "00",
        CDIN_FDBK_SEL_BYPASS => '1',
        ARSHFT17 => '0',
        ARSHFT17_EN => '1',
        ARSHFT17_SL_N => '1',
        ARSHFT17_AD_N => '1',
        ARSHFT17_SD_N => '0',
        ARSHFT17_BYPASS => '1',
        SUB => '0',
        SUB_EN => '1',
        SUB_SL_N => '1',
        SUB_AD_N => '1',
        SUB_SD_N => '1',
        SUB_BYPASS => '1',
        SIMD => '0',
        DOTP => '0',
        OVFL_CARRYOUT_SEL => '0',
        OVFL_CARRYOUT => open,
        P => P,
        CDOUT => open
      );
    process(CLK)
    begin
      if rising_edge(CLK) then
        O(AL+BL-1 downto 0) <= P(AL+BL-1 downto 0);
      end if;
    end process;

  end generate;
  
   
  
  gen_pd4 : if m = 4 generate
    U_MACC_PA : MACC_PA
      port map(
        CLK => CLK,
        AL_N => '1',
        A => Pad(A,18,s),
        A_EN => '1',
        A_SRST_N => '1',
        A_BYPASS => '0',
        B => Pad(B,18,s),
        B_EN => '1',
        B_SRST_N => '1',
        B_BYPASS => '0',
        C => (others => '0'),
        C_ARST_N => '1',
        C_EN => '1',
        C_SRST_N => '1',
        C_BYPASS => '1',
        CARRYIN => '0',
        D => (others => '0'),
        D_ARST_N => '1',
        D_EN => '1',
        D_SRST_N => '1',
        D_BYPASS => '1',
        P_EN => '1',
        P_SRST_N => '1',
        P_BYPASS => '0',
        CDIN => (others => '0'),
        PASUB => '0',
        PASUB_EN => '1',
        PASUB_SL_N => '1',
        PASUB_AD_N => '1',
        PASUB_SD_N => '0',
        PASUB_BYPASS => '1',
        CDIN_FDBK_SEL => "00",
        CDIN_FDBK_SEL_EN => '1',
        CDIN_FDBK_SEL_SL_N => '1',
        CDIN_FDBK_SEL_AD_N => "11",
        CDIN_FDBK_SEL_SD_N => "00",
        CDIN_FDBK_SEL_BYPASS => '1',
        ARSHFT17 => '0',
        ARSHFT17_EN => '1',
        ARSHFT17_SL_N => '1',
        ARSHFT17_AD_N => '1',
        ARSHFT17_SD_N => '0',
        ARSHFT17_BYPASS => '1',
        SUB => '0',
        SUB_EN => '1',
        SUB_SL_N => '1',
        SUB_AD_N => '1',
        SUB_SD_N => '1',
        SUB_BYPASS => '1',
        SIMD => '0',
        DOTP => '0',
        OVFL_CARRYOUT_SEL => '0',
        OVFL_CARRYOUT => open,
        P => P,
        CDOUT => open
      );
    process(CLK)
    begin
      if rising_edge(CLK) then
        P_d(AL+BL-1 downto 0) <= P(AL+BL-1 downto 0);
        O(AL+BL-1 downto 0) <= P_d(AL+BL-1 downto 0);
      end if;
    end process;

  end generate;


end architecture_MULT_S18xS18_PDm;
