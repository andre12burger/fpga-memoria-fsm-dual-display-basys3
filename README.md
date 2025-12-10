# Sistema de Memória com Máquina de Estados e Duplo Display - VHDL

![VHDL](https://img.shields.io/badge/VHDL-Hardware-blue)
![FPGA](https://img.shields.io/badge/FPGA-Basys3-green)
![FSM](https://img.shields.io/badge/Design-FSM-purple)
![Xilinx](https://img.shields.io/badge/Xilinx-Vivado-red)
![License](https://img.shields.io/badge/license-MIT-orange)

## 📋 Descrição

Sistema avançado de memória implementado em VHDL para FPGA Xilinx Basys3, controlado por **máquina de estados finitos (FSM)**. O projeto apresenta uma sequência automática de operações de escrita e leitura em memória, com visualização através de **dois displays de 7 segmentos** independentes e feedback visual via LED RGB.

## 🎥 Demonstração

[Vídeo de demonstração na Basys3](https://www.youtube.com/shorts/pL90DnOhiHA)

## 🏗️ Arquitetura

### Visão Geral

Este projeto implementa um **sistema autônomo** que executa automaticamente uma sequência de operações:
1. **Estado de Segurança** (3 segundos) - Displays piscam "8888 8888", LED RGB pisca em amarelo
2. **Aviso de Escrita** (3 segundos) - Display pisca "E5CrItA"
3. **Escrita em 4 posições** (3 segundos cada) - Valores pré-definidos, LED verde sempre aceso
4. **Aviso de Leitura** (3 segundos) - Display pisca "LEItUrA"
5. **Leitura das 4 posições** (3 segundos cada) - Exibe valores decimais, LED azul sempre aceso
6. **Reset da Memória** (3 segundos) - Display pisca "000", LED vermelho piscando
7. **Estado Final** - LEDs RGB alternando cores (vermelho → verde → azul)

### Módulos Principais

- **`top_level.vhd`**: Módulo principal que integra todos os componentes
- **`maquina_estados.vhd`**: Máquina de estados finitos (FSM) - controla a sequência de operações
- **`data_storage_unit.vhd`**: Unidade de armazenamento de dados (4 posições x 8 bits)
- **`memory_cell_8bit.vhd`**: Célula de memória individual de 8 bits com controle de escrita
- **`address_decoder.vhd`**: Decodificador de endereços 1-para-2
- **`debounce_button.vhd`**: Anti-bouncing para botão de reset
- **`output_multiplexer.vhd`**: Multiplexador de saída 4x1
- **`binary_to_bcd_conv.vhd`**: Conversor binário para BCD (3 dígitos)
- **`display_manager.vhd`**: Gerenciador de display 7 segmentos com suporte a letras
- **`pinagem.xdc`**: Arquivo de constraints (pinagem Basys3)

### Diagrama de Blocos

```
┌────────────────────────────────────────────────────────────────────┐
│                          TOP LEVEL                                 │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              MÁQUINA DE ESTADOS (FSM)                        │  │
│  │                                                              │  │
│  │  Estados:                                                    │  │
│  │  • SEGURANCA (3s)          • ESCRITA_POSICAO_0..3            │  │
│  │  • AVISO_ESCRITA           • AVISO_LEITURA                   │  │
│  │  • LEITURA_POSICAO_0..3    • RESET_MEMORIA                   │  │
│  │  • FINAL                                                     │  │
│  │                                                              │  │
│  │  Saídas de Controle:                                         │  │
│  │  → addr (linha/coluna)     → write_enable                    │  │
│  │  → reset_memoria           → exibir_dado                     │  │
│  │  → numero_dado[7:0]        → led_rgb[2:0]                    │  │
│  │  → painel_esquerdo[15:0]   → painel_direito[15:0]            │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                            ↓                                       │
│  ┌─────────────────┐     ┌──────────────────┐                      │
│  │  Address        │     │  Data Storage    │                      │
│  │  Decoder        │ →sel→│   Unit (4x8b)   │                      │
│  └─────────────────┘     └──────────────────┘                      │
│                                    ↓                               │
│                           ┌─────────────┐                          │
│                           │   Output    │                          │
│                           │     MUX     │                          │
│                           └─────────────┘                          │
│                                    ↓                               │
│                           ┌─────────────┐                          │
│                           │  Binary to  │                          │
│                           │  BCD Conv   │                          │
│                           └─────────────┘                          │
│                                    ↓                               │
│          ┌─────────────────────────┴─────────────────────┐         │
│          ↓                                               ↓         │
│  ┌───────────────┐                               ┌───────────────┐ │
│  │   Display     │ → 7-Seg Display               │   Display     │ │
│  │   Manager     │   Esquerdo (4 dig)            │   Manager     │ │
│  │  (Esquerdo)   │                               │   (Direito)   │ │
│  └───────────────┘                               └───────────────┘ │
│                                                                    │
│  LEDs ← led_data_out[7:0], led_addr_out[1:0], led_rgb[2:0]         │
└────────────────────────────────────────────────────────────────────┘
```

## 🎨 Máquina de Estados (FSM)

### Diagrama de Estados

```
     ┌─────────────┐
     │  SEGURANCA  │ (3s - Display pisca: "8888 8888")
     │LED: Amarelo │ (piscando)
     │   Piscando  │
     └──────┬──────┘
            ↓
     ┌──────────────┐
     │AVISO_ESCRITA │ (3s - Display pisca: "E5CrItA")
     │LED: Piscando │
     └──────┬───────┘
            ↓
     ┌────────────────┐
     │ ESCRITA_POS_0  │ (3s cada)
     │ ESCRITA_POS_1  │ Valores: 3, 25, 255, 42
     │ ESCRITA_POS_2  │ LED: Verde (sempre aceso)
     │ ESCRITA_POS_3  │
     └────────┬───────┘
              ↓
     ┌──────────────┐
     │AVISO_LEITURA │ (3s - Display pisca: "LEItUrA")
     │LED: Piscando │
     └──────┬───────┘
            ↓
     ┌────────────────┐
     │ LEITURA_POS_0  │ (3s cada)
     │ LEITURA_POS_1  │ Exibe valor decimal
     │ LEITURA_POS_2  │ LED: Azul (sempre aceso)
     │ LEITURA_POS_3  │
     └────────┬───────┘
              ↓
     ┌──────────────┐
     │RESET_MEMORIA │ (3s - Display pisca: "000")
     │LED: Vermelho │ (piscando)
     └──────┬───────┘
            ↓
     ┌──────────────┐
     │    FINAL     │ (Display apagado)
     │LEDs Alternando│ (Vermelho → Verde → Azul)
     └──────────────┘
```

### Valores Pré-programados

| Endereço | Valor Decimal | Valor Binário |
|----------|---------------|---------------|
| 00 | 3 | 0000 0011 |
| 01 | 25 | 0001 1001 |
| 10 | 255 | 1111 1111 |
| 11 | 42 | 0010 1010 |

## 🔌 Pinagem (Basys3)

### Clock e Controle
| Sinal | Pino | Descrição |
|-------|------|-----------|
| `entrada_clock` | W5 | Clock de 100 MHz |
| `entrada_reset` | U18 | Botão de reset (ativo baixo) |

### Display 7 Segmentos Esquerdo
| Sinal | Pinos | Descrição |
|-------|-------|-----------|
| `saida_segmento_esquerdo[6:0]` | W7, W6, U8, V8, U5, V5, U7 | Segmentos a-g |
| `saida_anodo_selecao_esquerdo[3:0]` | U2, U4, V4, W4 | Seleção de dígito |

### Display 7 Segmentos Direito
| Sinal | Pinos | Descrição |
|-------|-------|-----------|
| `saida_segmento_direito[6:0]` | T8, V9, R8, T6, T5, T10, T9 | Segmentos a-g |
| `saida_anodo_selecao_direito[3:0]` | V7, U7, V5, V4 | Seleção de dígito |

### LEDs de Status
| Sinal | Pinos | Descrição |
|-------|-------|-----------|
| `saida_led_rgb[2:0]` | N3, P3, P1 | LED RGB (indica estado) |
| `saida_leds_endereco[1:0]` | U16, E19 | Endereço atual |
| `saida_leds_dado[7:0]` | L1, P1, N3, P3, U3, W3, V3, V13 | Valor do dado |

## 🚀 Como Usar

### Pré-requisitos
- Xilinx Vivado (versão 2018.2 ou superior)
- Placa FPGA Digilent Basys3
- Cabo USB para programação

### Compilação no Vivado

1. **Criar novo projeto:**
   - File → Project → New
   - Selecione a parte: `xc7a35tcpg236-1` (Basys3)

2. **Adicionar arquivos:**
   - Adicione todos os `.vhd` da pasta `src/`
   - Adicione `pinagem.xdc` da pasta `hardware/`

3. **Definir top-level:**
   - Set `top_level.vhd` como Top Module

4. **Compilar e programar:**
   - Run Synthesis → Run Implementation → Generate Bitstream
   - Open Hardware Manager → Program Device

### Operação

O sistema opera **automaticamente** após a programação:

1. **Estado de Segurança (3s)** - Todos os 8 displays piscam "8", LED amarelo piscando
2. **Aviso de Escrita (3s)** - Display pisca "E5CrItA" (Escrita)
3. **Escrita nas 4 posições (3s cada)** - Valores: 3, 25, 255, 42 - LED verde sempre aceso
4. **Aviso de Leitura (3s)** - Display pisca "LEItUrA" (Leitura)
5. **Leitura das 4 posições (3s cada)** - Exibe valores decimais, LED azul sempre aceso
6. **Reset da memória (3s)** - Display pisca "000", LED vermelho piscando
7. **Estado final** - Display apagado, LEDs RGB alternando (Vermelho → Verde → Azul)

**Para reiniciar:** Pressione o botão de reset (U18) ou recarregue o bitstream

### Indicadores Visuais

**LED RGB - Código de Cores:**
- 🟡 Amarelo (piscando): Estado de segurança - display pisca "8888 8888"
- 💡 LED piscando: Aviso de escrita - display pisca "E5CrItA"
- 🟢 Verde (sempre aceso): Escrevendo na memória - 4 posições (3s cada)
- 💡 LED piscando: Aviso de leitura - display pisca "LEItUrA"
- 🔵 Azul (sempre aceso): Lendo da memória - exibe valores decimais (3s cada)
- 🔴 Vermelho (piscando): Reset da memória - display pisca "000"
- 🌈 Alternando (R→G→B): Estado final - display apagado, ciclo de 1s por cor

## 📁 Estrutura do Projeto

```
.
├── README.md
├── LICENSE
├── .gitignore
├── src/                                    # Código fonte VHDL
│   ├── top_level.vhd                      # Top-level entity
│   ├── maquina_estados.vhd                # FSM principal
│   ├── data_storage_unit.vhd
│   ├── memory_cell_8bit.vhd
│   ├── address_decoder.vhd
│   ├── debounce_button.vhd
│   ├── output_multiplexer.vhd
│   ├── binary_to_bcd_conv.vhd
│   └── display_manager.vhd
├── hardware/                               # Arquivos de hardware
│   └── pinagem.xdc                        # Constraints
└── docs/                                   # Documentação
    └── fsm_diagram.md                     # Diagrama FSM detalhado
```

## 🛠️ Tecnologias Utilizadas

- **Linguagem**: VHDL
- **Ferramenta**: Xilinx Vivado
- **Hardware**: Digilent Basys3 (Artix-7 XC7A35T-1CPG236C)
- **Clock**: 100 MHz
- **Displays**: 2x (7 segmentos x 4 dígitos cada)
- **Design Pattern**: Máquina de Estados Finitos (FSM)

## 📝 Funcionalidades

✅ **Máquina de estados finitos** com 12 estados  
✅ **Operação autônoma** - sequência automática de escrita/leitura  
✅ **Duplo display 7 segmentos** - visualização simultânea  
✅ **Display de texto** - suporte a letras (A, L, C, r, U, E, I)  
✅ **Feedback visual via LED RGB** - 7 cores diferentes para cada estado  
✅ **Temporização precisa** - intervalos de 0.5s a 3s  
✅ **Memória de 4 posições x 8 bits**  
✅ **Conversão binário → BCD** automática  
✅ **Debounce em hardware** para reset confiável  
✅ **LEDs de status** para endereço e dados  

## 🔍 Diferenciais deste Projeto

Este é o projeto mais avançado da série, incluindo:
- **Máquina de Estados Finitos (FSM)** complexa com 12 estados
- **Operação totalmente autônoma** - não requer interação do usuário
- **Dois displays independentes** para visualização ampliada
- **Suporte a caracteres alfabéticos** nos displays
- **Sistema de temporização preciso** com múltiplos intervalos
- **Feedback visual rico** através de LED RGB multicolorido
- **Sequência completa** de operações: escrita → leitura → reset

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:
- Reportar bugs
- Sugerir melhorias
- Enviar pull requests
- Adicionar novos estados ou funcionalidades

## 📄 Licença

Este projeto está sob a licença MIT.

## ✍️ Autores

Projeto desenvolvido como trabalho final da disciplina de Sistemas Digitais.

---

⭐ Se este projeto foi útil para você, considere dar uma estrela!
