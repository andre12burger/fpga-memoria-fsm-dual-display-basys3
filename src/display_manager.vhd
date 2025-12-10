library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_manager is
    port (
        entrada_clock : in  std_logic;  
        entrada_reset : in  std_logic;  
        bcd_data_in   : in  std_logic_vector(15 downto 0);
        segment_out   : out std_logic_vector(6 downto 0);
        anode_select_out : out std_logic_vector(3 downto 0)
    );
end entity display_manager;

architecture Logic of display_manager is
    constant REFRESH_RATE_DIVISOR : integer := 250000;
    signal r_refresh_counter : integer range 0 to REFRESH_RATE_DIVISOR := 0;
    signal r_digit_index     : std_logic_vector(1 downto 0) := "00";
    signal w_active_digit    : std_logic_vector(3 downto 0);
begin

    process(entrada_clock, entrada_reset)
    begin
        if entrada_reset = '1' then
            r_refresh_counter <= 0;
            r_digit_index    <= "00";
        elsif rising_edge(entrada_clock) then
            if r_refresh_counter = REFRESH_RATE_DIVISOR then
                r_refresh_counter <= 0;
                r_digit_index <= std_logic_vector(unsigned(r_digit_index) + 1);
            else
                r_refresh_counter <= r_refresh_counter + 1;
            end if;
        end if;
    end process;

    with r_digit_index select
        w_active_digit <= bcd_data_in(3 downto 0)   when "00",
                          bcd_data_in(7 downto 4)   when "01",
                          bcd_data_in(11 downto 8)  when "10",
                          bcd_data_in(15 downto 12) when "11",
                          (others => '1')           when others; -- Padrão OFF

    process(w_active_digit)
    begin
        case w_active_digit is
            -- Números 0-9
            when "0000" => segment_out <= "1000000"; -- 0
            when "0001" => segment_out <= "1111001"; -- 1
            when "0010" => segment_out <= "0100100"; -- 2
            when "0011" => segment_out <= "0110000"; -- 3
            when "0100" => segment_out <= "0011001"; -- 4
            when "0101" => segment_out <= "0010010"; -- 5
            when "0110" => segment_out <= "0000010"; -- 6
            when "0111" => segment_out <= "1111000"; -- 7
            when "1000" => segment_out <= "0000000"; -- 8
            when "1001" => segment_out <= "0010000"; -- 9
            
            -- Letras
            when "1010" => segment_out <= "0001000"; -- A
            when "1011" => segment_out <= "1000111"; -- L
            when "1100" => segment_out <= "1000110"; -- C
            when "1101" => segment_out <= "0101111"; -- r
            when "1110" => segment_out <= "0111110"; -- U
            
            -- MUDANÇA: "1111" agora é APAGADO (OFF)
            when "1111" => segment_out <= "1111111"; -- OFF (Tudo apagado)
            
            when others => segment_out <= "1111111"; 
        end case;
    end process;

    with r_digit_index select
        anode_select_out <= "1110" when "00", 
                            "1101" when "01", 
                            "1011" when "10", 
                            "0111" when "11", 
                            "1111" when others;
end architecture Logic;