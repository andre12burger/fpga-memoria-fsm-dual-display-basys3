library ieee;
use ieee.std_logic_1164.all;

entity output_multiplexer is
    port(
        mux_sel   : in std_logic; -- Sinal de seleção
        data_in_A : in std_logic_vector(7 downto 0); -- Entrada 0 (sel = '0')
        data_in_B : in std_logic_vector(7 downto 0); -- Entrada 1 (sel = '1')
        mux_out   : out std_logic_vector(7 downto 0) -- Saída
    );
end entity output_multiplexer;

architecture Combinational of output_multiplexer is
begin
    -- Lógica MUX padrão
    mux_out <= data_in_A when (mux_sel = '0') else data_in_B;
    
end architecture Combinational;