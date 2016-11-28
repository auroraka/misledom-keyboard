library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use IEEE.NUMERIC_STD.all;

entity keyboard_ctrl is
port(
	k_data : in std_logic;
	k_clk : in std_logic;
	clk_50 : in std_logic;
	rst : in std_logic;
	addr : in std_logic;
	rdn_not : in std_logic; -- debug
	data_ready_out: out std_logic;
	k_data_ready_out: out std_logic; -- debug
	data_out:out std_logic_vector(7 downto 0);
	seg0 : out std_logic_vector(6 downto 0); -- debug
	seg1 : out std_logic_vector(6 downto 0); -- debug
	k_state_debug : out std_logic_vector(1 downto 0);
	r_state_debug : out std_logic_vector(1 downto 0)
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

--[Debug]--
signal count_debug: std_logic_vector(3 downto 0);
signal rdn: std_logic;
--[End Debug]--


type state_type  is (idle,press_one,press_two);
signal kcode : std_logic_vector(7 downto 0); -- scancode recive from keyboard 
signal kdata : std_logic_vector(3 downto 0); -- trans scancode to 0-F
signal fok:std_logic; -- key press
signal state : state_type;
signal store_data: std_logic_vector(7 downto 0); -- key press data
signal k_data_ready : std_logic; -- when press to 0-F key and a SPACE key
signal rst_not : std_logic;
type rdn_read_type is (idle,readed_data_ready,readed_data);
signal read_state:rdn_read_type; 


begin

--[Debug]--
rdn<=not rdn_not;
k_data_ready_out<=k_data_ready;
process(state)
begin
	case state is 
		when idle => k_state_debug<="11";
		when press_one => k_state_debug<="01";
		when press_two => k_state_debug<="10";		
	end case;
end process;

process(read_state)
begin
	case read_state is 
		when idle => r_state_debug<="11";
		when readed_data_ready => r_state_debug<="01";
		when readed_data => r_state_debug<="10";	
	end case;
end process;
--[End dDbug]--


data_out<=store_data;
--data_out<=kcode;
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

seg_displayer1 : seg_displayer port map(
	isHex =>'1',
	num => count_debug,
	seg=>seg1
);

process(rst,fok,kcode,kdata)
variable cnt:integer:=0;
variable store_data : std_logic_vector(7 downto 0);
begin
	if (rst = '0') then
		state<=idle;
		store_data:="00000000";
		k_data_ready<='0';
		cnt:=0;
		count_debug<="0000";
		data_out<=store_data;
	elsif (rising_edge(fok)) then
		count_debug<=count_debug+1;
		cnt:=cnt+1;
		if (cnt=3) then
			cnt:=0;
			case state is 
				when idle =>
					store_data(7 downto 4):=kdata;
					state<=press_one;
					k_data_ready<='0';
					data_out<=store_data;
				when press_one =>
					store_data(3 downto 0):=kdata;
					state<=press_two;
					k_data_ready<='0';
					data_out<=store_data;
				when press_two =>
					if (kcode="00101001") then--0x29 Space
						k_data_ready<='1';
					else
						store_data:=kcode;
						k_data_ready<='0';
					end if;
					data_out<=store_data;
				    --k_data_ready<='1';
					state<=idle;
				when others =>
					store_data:="00000000";
					state<=idle;
					k_data_ready<='0';
					data_out<=store_data;
			end case;
		end if;
	end if;
end process;

process (rst,rdn) 
begin
	if (rst ='0') then
		read_state<=idle;
		data_ready_out<='0';
	elsif falling_edge(rdn) then
		if (k_data_ready ='0') then 
			read_state<=idle;   -- [key point] , we assume keyboard is slow enough so the kernel will check data_ready when k_data_ready is '0'
			data_ready_out<='0';
		else -- if k_data_ready = '1' , it will continuse for a long time , but data_ready_out showed '1' only for the first read
			case read_state is 
				when idle =>
					if (addr ='1') then
						data_ready_out<=k_data_ready;
						read_state <=readed_data_ready;
					else 
					end if;
				when readed_data_ready =>
					if (addr ='1') then
						data_ready_out<=k_data_ready;
					else 
						read_state<=readed_data;
					end if;
				when readed_data =>
					if (addr ='1') then
						data_ready_out<='0';
					else
					end if;
			end case;
		end if;
	end if;

end process;

end bhv_keyboard_ctrl;

