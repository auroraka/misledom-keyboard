library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity top is
port(
datain,clkin,fclk,rst_in: in std_logic;
seg0,seg1:out std_logic_vector(6 downto 0);
datain_debug,clkin_debug:out std_logic;
fclk_debug,rst_in_debug:out std_logic
);
end top;

architecture behave of top is

component Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
--	fok : out std_logic ;  -- data output enable signal
	scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	) ;
end component ;

component seg_displayer is
port(
	isHex:in std_logic;
	num: in std_logic_vector(3 downto 0);
	seg : out std_logic_vector(6 downto 0)
);
end component;

signal scancode : std_logic_vector(7 downto 0);
signal rst : std_logic;
signal clk_f: std_logic;
begin

--debug--
rst_in_debug<=rst;
datain_debug<=datain;
clkin_debug<=clkin;
fclk_debug<=fclk;
--end debug --


rst<=not rst_in;

u0: Keyboard port map(datain,clkin,fclk,rst,scancode);
u1: seg_displayer port map('1',scancode(3 downto 0),seg0);
u2: seg_displayer port map('1',scancode(7 downto 4),seg1);

end behave;

