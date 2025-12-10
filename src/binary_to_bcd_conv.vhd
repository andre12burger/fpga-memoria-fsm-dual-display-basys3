library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Necessário para aritmética

entity binary_to_bcd_conv is
    port (
        bin_in : in  std_logic_vector(7 downto 0); -- Entrada binária
        bcd_out : out std_logic_vector(11 downto 0) -- Saída BCD (Centena, Dezena, Unidade)
    );
end entity binary_to_bcd_conv;

architecture Logic of binary_to_bcd_conv is

    -- Função auxiliar: "Se dígito > 4, então dígito = dígito + 3"
    function check_and_add_3 (digit : std_logic_vector(3 downto 0)) 
    return std_logic_vector is
        variable val : integer;
    begin
        val := to_integer(unsigned(digit));
        if val > 4 then
            return std_logic_vector(to_unsigned(val + 3, 4));
        else
            return digit;
        end if;
    end function check_and_add_3;

begin

    -- Processo de conversão (Combinacional)
    process(bin_in)
        -- Variáveis temporárias para os dígitos BCD
        variable v_hundreds : std_logic_vector(3 downto 0);
        variable v_tens     : std_logic_vector(3 downto 0);
        variable v_units    : std_logic_vector(3 downto 0);
        -- Variável temporária para a entrada
        variable v_temp_binary : std_logic_vector(7 downto 0);
    begin
        -- 1. Inicialização
        v_hundreds    := (others => '0');
        v_tens        := (others => '0');
        v_units       := (others => '0');
        v_temp_binary := bin_in;

        -- 2. Loop de 8 iterações (para cada bit de entrada)
        for i in 1 to 8 loop
            
            -- 2.1. ETAPA "ADD-3"
            -- Verifica e corrige cada dígito ANTES do deslocamento
            v_hundreds := check_and_add_3(v_hundreds);
            v_tens     := check_and_add_3(v_tens);
            v_units    := check_and_add_3(v_units);

            -- 2.2. ETAPA "SHIFT LEFT"
            -- Desloca todos os 20 bits (12 BCD + 8 Bin) para a esquerda
            v_hundreds := v_hundreds(2 downto 0) & v_tens(3);
            v_tens     := v_tens(2 downto 0) & v_units(3);
            v_units    := v_units(2 downto 0) & v_temp_binary(7);
            v_temp_binary := v_temp_binary(6 downto 0) & '0';
            
        end loop;

        -- 3. Atribuição da Saída
        bcd_out <= v_hundreds & v_tens & v_units;
    end process;

end architecture Logic;