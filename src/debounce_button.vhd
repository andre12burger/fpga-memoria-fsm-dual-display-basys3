library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Componente de debounce para botão que gera um pulso único
-- Útil para reset: aperta uma vez, gera pulso de reset
entity debounce_button is
    generic (
        DEBOUNCE_TIME : integer := 10000000 -- 100ms a 100MHz
    );
    port (
        clk_in  : in  std_logic; -- Clock principal
        btn_in  : in  std_logic; -- Entrada do botão (ativo-baixo na Boolean)
        pulse_out : out std_logic  -- Saída: pulso único de 1 clock cycle
    );
end entity debounce_button;

architecture Logic of debounce_button is
    signal s_btn_sync_0  : std_logic := '1'; -- Sincronizador
    signal s_btn_sync_1  : std_logic := '1'; -- Sincronizador
    signal s_btn_stable  : std_logic := '1'; -- Sinal estável após debounce
    signal s_counter     : integer range 0 to DEBOUNCE_TIME := 0;
    signal s_btn_prev    : std_logic := '1'; -- Estado anterior
begin

    -- Processo de debounce e detecção de borda
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            -- Sincronização do botão (2 estágios para evitar metaestabilidade)
            s_btn_sync_0 <= btn_in;
            s_btn_sync_1 <= s_btn_sync_0;
            
            -- Lógica de debounce
            if s_btn_sync_1 /= s_btn_stable then
                -- Botão mudou de estado, inicia contador
                if s_counter < DEBOUNCE_TIME then
                    s_counter <= s_counter + 1;
                else
                    -- Tempo de debounce completo, aceita novo estado
                    s_btn_stable <= s_btn_sync_1;
                    s_counter <= 0;
                end if;
            else
                -- Botão estável, reseta contador
                s_counter <= 0;
            end if;
            
            -- Guarda estado anterior para detecção de borda
            s_btn_prev <= s_btn_stable;
            
            -- Detecção de borda de descida (botão ativo-baixo: 1→0 = pressionado)
            if s_btn_prev = '1' and s_btn_stable = '0' then
                pulse_out <= '1'; -- Gera pulso de 1 clock cycle
            else
                pulse_out <= '0';
            end if;
        end if;
    end process;

end architecture Logic;
