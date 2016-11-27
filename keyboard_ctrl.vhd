library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity keyboard_ctrl is
port(
	k_data : in std_logic;
	k_clk : in std_logic;
	clk_50 : in std_logic;
	rst : in std_logic;
	rdn : in std_logic;
	data_ready_out: out std_logic;
	data_out:out std_logic_vector(7 downto 0);
	seg0 : out std_logic_vector(6 downto 0)
);
end keyboard_ctrl;

architecture bhv_keyboard_ctrl of keyboard_ctrl is

component seg_displayer is
	port(
		isHex : in std_logic;
		num : in std_logic_vector(3 downto 0);
		seg: out std_logic_vector(6 downto 0)
	) ;
end component ;

component keyboard_decoder is
	port(
		kcode : in std_logic_vector(7 downto 0);
		kdata : out std_logic_vector(3 downto 0)
	) ;
end component ;

type state_type  is (idle,press_one,press_two);
signal kcode : std_logic_vector(7 downto 0); -- scancode recive from keyboard 
signal kdata : std_logic_vector(3 downto 0); -- trans scancode to 0-F
signal fok:std_logic; -- key press
signal state : state_type;
signal store_data: std_logic_vector(7 downto 0); -- key press data
signal k_data_ready : std_logic; -- when press to 0-F key and a SPACE key
shared variable data_ready_signal :std_logic;
signal rst_not : std_logic;

begin

data_ready_out<=data_ready_signal;
data_out<=store_data;
rst_not<=not rst;

keyboard0: entity work.keyboard port map(
	datain=>k_data,
	clkin=>k_clk,
	fclk=>clk_50,
	rst=>rst_not,
	scancode=>kcode,
	fok_out=>fok
);

keyboard_decoder0 : keyboard_decoder port map(
	kcode=>kcode,
	kdata=>kdata
);

seg_displayer0 : seg_displayer port map(
	isHex =>'1',
	num => kdata,
	seg=>seg0
);

process(rst,fok)
begin
	if (rst = '1') then
		state<=idle;
		store_data<="00000000";
		k_data_ready<='0';
	elsif (rising_edge(fok)) then
		case state is 
			when idle =>
				store_data(7 downto 4)<=kdata;
				state<=press_one;
				k_data_ready<='0';
			when press_one =>
				store_data(3 downto 0)<=kdata;
				state<=press_two;
				k_data_ready<='0';
			when press_two =>
				if (kcode="00101001") then--0x29 Space
					k_data_ready<='1';
				else
					store_data<="00000000";
					k_data_ready<='0';
				end if;
				state<=idle;
			when others =>
				store_data<="00000000";
				state<=idle;
				k_data_ready<='0';
		end case;
	end if;
end process;

--process(rst,k_data_ready,rdn) 
process(rst,k_data_ready) 
begin
	if (rst = '1') then
		data_ready_signal:='0';
	elsif (falling_edge(rdn)) then
		data_ready_signal:='0';
	elsif (rising_edge(k_data_ready)) then
		data_ready_signal:='1';
	end if;
end process;

end bhv_keyboard_ctrl;

