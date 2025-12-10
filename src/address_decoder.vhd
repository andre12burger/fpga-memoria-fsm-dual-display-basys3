library ieee;                  
use ieee.std_logic_1164.all;

entity address_decoder is
    port (
        sel_in : in  std_logic;
        sel_out : out std_logic_vector(1 downto 0)
    );
end entity address_decoder;

architecture Logic of address_decoder is
begin
    -- Lógica combinacional para decodificar
    process(sel_in)
    begin
        if sel_in = '1' then
            sel_out <= "10"; -- Entrada 1 seleciona saída 1
        else
            sel_out <= "01"; -- Entrada 0 seleciona saída 0
        end if;
    end process;

end architecture Logic;