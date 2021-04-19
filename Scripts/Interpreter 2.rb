#==============================================================================
# Interpreter (Parte 2)
#------------------------------------------------------------------------------
# É a classe que interpreta os comandos de eventos do jogo.
# É usada dentro da classe Game_Event e Game_System.
#==============================================================================

class Interpreter
  
  #--------------------------------------------------------------------------
  # Execução de um Comando de Evento
  #--------------------------------------------------------------------------
  
  def execute_command
    # Quando se chega ao fim da lista de execução
    if @index >= @list.size - 1
      # terminar evento
      command_end
      # Continuar
      return true
    end
    # Parâmetro de um comando de evento referência no @parameters
    @parameters = @list[@index].parameters
    # Ramificação por código de comando
    case @list[@index].code
    when 101  # Mostrar Mensagem
      return command_101
    when 102  # Mostrar Escolhas
      return command_102
    when 402  # No caso de [**]
      return command_402
    when 403  # No caso de cancelamento
      return command_403
    when 103  # Armazenar Número
      return command_103
    when 104  # opções de Mensagem
      return command_104
    when 105  # Definir teclas
      return command_105
    when 106  # Espera
      return command_106
    when 111  # Condições
      return command_111
    when 411  # Quando outro
      return command_411
    when 112  # Cilclo
      return command_112
    when 413  # Repetição
      return command_413
    when 113  # Romper Ciclo
      return command_113
    when 115  # Parar Evento
      return command_115
    when 116  # Apagar Evento Temp.
      return command_116
    when 117  # Evento Comum
      return command_117
    when 118  # Label
      return command_118
    when 119  # Ir para Label
      return command_119
    when 121  # opções de Switch
      return command_121
    when 122  # opções de Variável
      return command_122
    when 123  # Controle de Switch Local
      return command_123
    when 124  # Operações de Tempo
      return command_124
    when 125  # Mudar Dinheiro
      return command_125
    when 126  # Mudar Item
      return command_126
    when 127  # Mudar Arma
      return command_127
    when 128  # Mudar Armadura
      return command_128
    when 129  # Mudar Grupo
      return command_129
    when 131  # Mudar gráfico de Sistema
      return command_131
    when 132  # Mudar BMG de Batalha
      return command_132
    when 133  # Mudar ME de Batalha
      return command_133
    when 134  # Opções de Save
      return command_134
    when 135  # opções de Menu
      return command_135
    when 136  # opções de Encontro
      return command_136
    when 201  # Teletransporte
      return command_201
    when 202  # Posição de Evento
      return command_202
    when 203  # Movimento de Tela
      return command_203
    when 204  # Opções do Mapa
      return command_204
    when 205  # Tom da Névoa
      return command_205
    when 206  # Opacidade da Névoa
      return command_206
    when 207  # mostrar Animação
      return command_207
    when 208  # Mudar Transparência
      return command_208
    when 209  # Mover Evento
      return command_209
    when 210  # Esperar Fim do Movimento
      return command_210
    when 221  # Preparar Transição
      return command_221
    when 222  # Executar Transição
      return command_222
    when 223  # Cor da Tela
      return command_223
    when 224  # Efeito Flash
      return command_224
    when 225  # Efeito Tremor
      return command_225
    when 231  # Mostrar Imagem
      return command_231
    when 232  # Mover Imagem
      return command_232
    when 233  # Girar Imagem
      return command_233
    when 234  # Tonalidade Imagem
      return command_234
    when 235  # Deletar Imagem
      return command_235
    when 236  # Opções de Clima
      return command_236
    when 241  # Reproduzir BGM
      return command_241
    when 242  # Parar BGM
      return command_242
    when 245  # Reproduzir BGS
      return command_245
    when 246  # Parar BGS
      return command_246
    when 247  # Memorizar BGM/BGS
      return command_247
    when 248  # Reproduzir Memorizados
      return command_248
    when 249  # Reproduzir ME
      return command_249
    when 250  # Reproduzir SE
      return command_250
    when 251  # Parar SE
      return command_251
    when 301  #iniciar Batalha
      return command_301
    when 601  # Se Vencer
      return command_601
    when 602  # Se Fugir
      return command_602
    when 603  # Se Perder
      return command_603
    when 302  # Inserir Loja
      return command_302
    when 303  # Inserir Nome do Herói
      return command_303
    when 311  # Mudar HP
      return command_311
    when 312  # Mudar MP
      return command_312
    when 313  # Mudar Status
      return command_313
    when 314  # Curar Tudo
      return command_314
    when 315  # Mudar EXP
      return command_315
    when 316  # Mudar Nível
      return command_316
    when 317  # Mudar Parâmetros
      return command_317
    when 318  # Mudar Habilidades
      return command_318
    when 319  # Mudar Equipamento
      return command_319
    when 320  # Mudar Nome do Herói
      return command_320
    when 321  # Mudar Classe
      return command_321
    when 322  # Mudar Gráfico do Herói
      return command_322
    when 331  # Mudar HP do Inimigo
      return command_331
    when 332  # Mudar MP do Inimigo
      return command_332
    when 333  # Mudar Status do Inimigo
      return command_333
    when 334  # Aparição Inimiga
      return command_334
    when 335  # Transformação Inimiga
      return command_335
    when 336  # Curar Inimigo
      return command_336
    when 337  # Mostrar Animação
      return command_337
    when 338  # Receber Dano
      return command_338
    when 339  # Forçar Ação
      return command_339
    when 340  # Parar Batalha
      return command_340
    when 351  # Chamar Menu
      return command_351
    when 352  # Chamar Menu de Save
      return command_352
    when 353  # Game Over
      return command_353
    when 354  # Voltar à tela de Título
      return command_354
    when 355  # Chamar Script
      return command_355
    else      # Outros
      return true
    end
  end
  
  #--------------------------------------------------------------------------
  # Fim do Evento
  #--------------------------------------------------------------------------
  
  def command_end
    # Limpar a lista de comando de evento
    @list = nil
    # Se o evento e o ID do evento de mapa principal forem válidos
    if @main and @event_id > 0
      # Destravar evento
      $game_map.events[@event_id].unlock
    end
  end
  
  #--------------------------------------------------------------------------
  # Pular Evento
  #--------------------------------------------------------------------------
  
  def command_skip
    # Selecionar evento
    indent = @list[@index].indent
    # Loop
    loop do
      # Se o próximo comando de evento for do mesmo nível do evento anterior
      if @list[@index+1].indent == indent
        # Continuar
        return true
      end
      # Avançar índice
      @index += 1
    end
  end
  
  #--------------------------------------------------------------------------
  # Selecionar Herói
  #
  #     parameter : parâmetro
  #--------------------------------------------------------------------------
  
  def get_character(parameter)
    # Ramificação por parâmetro
    case parameter
    when -1  # Jogador
      return $game_player
    when 0  # Este evento
      events = $game_map.events
      return events == nil ? nil : events[@event_id]
    else  # Evento específico
      events = $game_map.events
      return events == nil ? nil : events[parameter]
    end
  end
  
  #--------------------------------------------------------------------------
  # Cáculo dos valores Operados
  #
  #     operation    : operação
  #     operand_type : tipo de operação (0: invariável 1: variável)
  #     operand      : operante (um valor numeral ou ID da variável)
  #--------------------------------------------------------------------------
  
  def operate_value(operation, operand_type, operand)
    # Selecionar operante
    if operand_type == 0
      value = operand
    else
      value = $game_variables[operand]
    end
    # Reversão de uma marca [redução]
    if operation == 1
      value = -value
    end
    # Retornar o valor
    return value
  end
end
