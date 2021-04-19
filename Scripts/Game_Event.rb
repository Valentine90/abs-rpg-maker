#==============================================================================
# Game_Event
#------------------------------------------------------------------------------
# Esta é a classe que engloba os eventos. O que inclui as funções nas páginas de
# evento alterando estas através das Condições de Evento, e faz funcionar os 
# Processos Paralelos. Esta classe está inserida na classe Game_Map.
#==============================================================================

class Game_Event < Game_Character
  
  #--------------------------------------------------------------------------
  # Variáveis Públicas
  #--------------------------------------------------------------------------
  
  attr_reader   :trigger                  # trigger
  attr_reader   :list                     # lista dos comandos de evento
  attr_reader   :starting                 # flag de início
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #     map_id : ID do mapa
  #     event  : evento (RPG::Event)
  #--------------------------------------------------------------------------
  
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    # Mover para a posição de início
    moveto(@event.x, @event.y)
    refresh
  end
  
  #--------------------------------------------------------------------------
  # Limpar Bandeira de Início
  #--------------------------------------------------------------------------
  
  def clear_starting
    @starting = false
  end
  
  #--------------------------------------------------------------------------
  # Determinar o Começo do Evento
  #    (Quer esteja ou não esteja na mesma posição da Condição de Início)
  #--------------------------------------------------------------------------
  
  def over_trigger?
    # Se não for através do Herói como gráfico
    if @character_name != "" and not @through
      # Começar determinando a face
      return false
    end
    # Aqui verifica-se o bloqueio do Terreno
    unless $game_map.passable?(@x, @y, 0)
      # Começar determinando a face
      return false
    end
    # Começar determinando como mesma posição
    return true
  end
  
  #--------------------------------------------------------------------------
  # Começar o Evento
  #--------------------------------------------------------------------------
  
  def start
    # Aqui verifica-se o tamanho da lista de eventos, caso seje maior do que 1, 
    # os eventos desta lista são iniciados
    if @list.size > 1
      @starting = true
    end
  end
  
  #--------------------------------------------------------------------------
  # Ocultar Temporariamente
  #--------------------------------------------------------------------------
  
  def erase
    @erased = true
    refresh
  end
  
  #--------------------------------------------------------------------------
  # Atualizar
  #--------------------------------------------------------------------------
  
  def refresh
    # Iniciar as variáveis locais
    new_page = nil
    # Se não foram temporariamente ocultas
    unless @erased
      # Checar a ordem dos eventos
      for page in @event.pages.reverse
        # Tornar possível a referência ao evento
        c = page.condition
        # Aqui é verificada a primeira condição de switch
        if c.switch1_valid
          if $game_switches[c.switch1_id] == false
            next
          end
        end
        # E depois a segunda condição de Switch
        if c.switch2_valid
          if $game_switches[c.switch2_id] == false
            next
          end
        end
        # Aqui é confirmada a condição de variável
        if c.variable_valid
          if $game_variables[c.variable_id] < c.variable_value
            next
          end
        end
        # Aqui é confirmado o Switch Local
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        # Desinir a Variável Local
        new_page = page
        # Remover loop
        break
      end
    end
    # Se a página de eventos for igual à anterior
    if new_page == @page
      # Finalizar método
      return
    end
    # Definir @page como a página de evento atual
    @page = new_page
    # Limpar flag de início
    clear_starting
    # Se alguma página não completar as condições de evento
    if @page == nil
      # Definir cada instância variável
      @tile_id = 0
      @character_name = ""
      @character_hue = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      # Fim do método
      return
    end
    # Definir cada instância variável
    @tile_id = @page.graphic.tile_id
    @character_name = @page.graphic.character_name
    @character_hue = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end
    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed
    @move_frequency = @page.move_frequency
    @move_route = @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list
    @interpreter = nil
    # Se o trigger for Processo Paralelo
    if @trigger == 4
      # Criar um interpretador para o Processo Paralelo
      @interpreter = Interpreter.new
    end
    # Aqui é checado o acionamento automático
    check_event_trigger_auto
  end
  
  #--------------------------------------------------------------------------
  # Determinante de Início de Evento ao Toque
  #--------------------------------------------------------------------------
  
  def check_event_trigger_touch(x, y)
    # se o evento estiver ocorrendo
    if $game_system.map_interpreter.running?
      return
    end
    # Se o trigger for tocado e coincidir com as coordenadas do Herói
    if @trigger == 2 and x == $game_player.x and y == $game_player.y
      # Para determinar o início é verificado se o Herói está pulando e se está
      # de frente para o Evento
      if not jumping? and not over_trigger?
        start
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # Determinante de Início de Evento Automático
  #--------------------------------------------------------------------------
  
  def check_event_trigger_auto
    # Se o trigger for tocado e coincidir com as coordenadas do Herói
    if @trigger == 2 and @x == $game_player.x and @y == $game_player.y
      # Para determinar o início é verificado se o Herói está pulando e se está
      # de frente para o Evento
      if not jumping? and over_trigger?
        start
      end
    end
    # Se o trigger for de Início Automático
    if @trigger == 3
      start
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    super
    # Determinante de início de Evento automático
    check_event_trigger_auto
    # Se o Processo Paralelo for válido
    if @interpreter != nil
      # Aqui é conferido se o Evento já não está ocorrendo
      unless @interpreter.running?
        # Configurar Evento
        @interpreter.setup(@list, @event.id)
      end
      # Interpretador
      @interpreter.update
    end
  end
end
