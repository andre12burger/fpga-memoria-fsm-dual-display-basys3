# ==============================================
#  PINAGEM BOOLEAN BOARD - Projeto Final
# ==============================================

# --- Clock ---
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {entrada_clock}]
create_clock -period 10.000 -name sys_clk [get_ports entrada_clock]

# --- Configuração ---
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# ==============================================
# ENTRADAS
# ==============================================

# Botão de Reset (BTN[3] - J1)
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {entrada_reset}]

# ==============================================
# SAÍDAS - DISPLAY ESQUERDO (D0)
# ==============================================

# Ânodos (Ativo Baixo)
set_property -dict {PACKAGE_PIN D5 IOSTANDARD LVCMOS33} [get_ports {saida_anodo_selecao_esquerdo[0]}]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports {saida_anodo_selecao_esquerdo[1]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {saida_anodo_selecao_esquerdo[2]}]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports {saida_anodo_selecao_esquerdo[3]}]

# Segmentos A-G (Ativo Baixo)
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_esquerdo[0]}]
set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_esquerdo[1]}]
set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_esquerdo[2]}]
set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_esquerdo[3]}]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_esquerdo[4]}]
set_property -dict {PACKAGE_PIN D6 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_esquerdo[5]}]
set_property -dict {PACKAGE_PIN B5 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_esquerdo[6]}]

# ==============================================
# SAÍDAS - DISPLAY DIREITO (D1)
# ==============================================

# Ânodos (Ativo Baixo)
set_property -dict {PACKAGE_PIN H3 IOSTANDARD LVCMOS33} [get_ports {saida_anodo_selecao_direito[0]}]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {saida_anodo_selecao_direito[1]}]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {saida_anodo_selecao_direito[2]}]
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS33} [get_ports {saida_anodo_selecao_direito[3]}]

# Segmentos A-G (Ativo Baixo)
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_direito[0]}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_direito[1]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_direito[2]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_direito[3]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_direito[4]}]
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_direito[5]}]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports {saida_segmento_direito[6]}]

# ==============================================
# SAÍDAS - LED RGB
# ==============================================

# LED RGB1 (LED colorido da direita)
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {saida_led_rgb[0]}]; # Red
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {saida_led_rgb[1]}]; # Green
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {saida_led_rgb[2]}]; # Blue

# ==============================================
# SAÍDAS - LEDs DE DEBUG
# ==============================================

# LEDs de Endereço (2 LEDs - Linha e Coluna)
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {saida_leds_endereco[0]}]; # LED0 = Coluna
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {saida_leds_endereco[1]}]; # LED1 = Linha

# LEDs de Dado (8 LEDs - Bits 0 a 7 do dado)
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {saida_leds_dado[0]}]; # LED2 = Bit 0
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {saida_leds_dado[1]}]; # LED3 = Bit 1
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {saida_leds_dado[2]}]; # LED4 = Bit 2
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {saida_leds_dado[3]}]; # LED5 = Bit 3
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {saida_leds_dado[4]}]; # LED6 = Bit 4
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS33} [get_ports {saida_leds_dado[5]}]; # LED7 = Bit 5
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {saida_leds_dado[6]}]; # LED8 = Bit 6
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS33} [get_ports {saida_leds_dado[7]}]; # LED9 = Bit 7