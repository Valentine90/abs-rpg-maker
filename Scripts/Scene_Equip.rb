#==============================================================================
# Scene_Equip
#------------------------------------------------------------------------------
# Esta classe processa a tela de Equipamento
#==============================================================================

class Scene_Equip
  
  #--------------------------------------------------------------------------
  # Inicialização dos Objetos
  #
  #     actor_index : Índice de Heróis
  #     equip_index : Índice de Equipamentos
  #--------------------------------------------------------------------------
  
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
    @equip_index = equip_index
  end
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Selecionar Herói
    @actor = $game_party.actors[@actor_index]
    # Criar janelas
    @help_window = Window_Help.new
    @left_window = Window_EquipLeft.new(@actor)
    @right_window = Window_EquipRight.new(@actor)
    @item_window1 = Window_EquipItem.new(@actor, 0)
    @item_window2 = Window_EquipItem.new(@actor, 1)
    @item_window3 = Window_EquipItem.new(@actor, 2)
    @item_window4 = Window_EquipItem.new(@actor, 3)
    @item_window5 = Window_EquipItem.new(@actor, 4)
    # Associar a janela de ajuda
    @right_window.help_window = @help_window
    @item_window1.help_window = @help_window
    @item_window2.help_window = @help_window
    @item_window3.help_window = @help_window
    @item_window4.help_window = @help_window
    @item_window5.help_window = @help_window
    # Definir a posição do cursor
    @right_window.index = @equip_index
    refresh
    # Executar transição
    Graphics.transition
    # Loop principal
    loop do
      # Atualizar a tela de jogo
      Graphics.update
      # Atualizar a entrada de informações
      Input.update
      # Atualizar o frame
      update
      # Abortar loop se a tela for alterada
      if $scene != self
        break
      end
    end
    # Preparar para a transição
    Graphics.freeze
    # Exibição das janelas
    @help_window.dispose
    @left_window.dispose
    @right_window.dispose
    @item_window1.dispose
    @item_window2.dispose
    @item_window3.dispose
    @item_window4.dispose
    @item_window5.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualizar
  #--------------------------------------------------------------------------
  
  def refresh
    # Definir a janela de Itens como visível
    @item_window1.visible = (@right_window.index == 0)
    @item_window2.visible = (@right_window.index == 1)
    @item_window3.visible = (@right_window.index == 2)
    @item_window4.visible = (@right_window.index == 3)
    @item_window5.visible = (@right_window.index == 4)
    # Selecionar os ´tens equipados atualmente
    item1 = @right_window.item
    # Set current item window to @item_window
    case @right_window.index
    when 0
      @item_window = @item_window1
    when 1
      @item_window = @item_window2
    when 2
      @item_window = @item_window3
    when 3
      @item_window = @item_window4
    when 4
      @item_window = @item_window5
    end
    # Se a janela da direita estiver ativa
    if @right_window.active
      # Limpar parâmetros para depois fazer a troca de equipamentos
      @left_window.set_new_parameters(nil, nil, nil)
    end
    # Se a janela de Itens estiver ativa
    if @item_window.active
      # Selecionar o Item escolhido
      item2 = @item_window.item
      # Mudar Equipamento
      last_hp = @actor.hp
      last_sp = @actor.sp
      @actor.equip(@right_window.index, item2 == nil ? 0 : item2.id)
      # Selecionar parâmetros para depois fazer a troca de equipamentos
      new_atk = @actor.atk
      new_pdef = @actor.pdef
      new_mdef = @actor.mdef
      # Retornar equipamento
      @actor.equip(@right_window.index, item1 == nil ? 0 : item1.id)
      @actor.hp = last_hp
      @actor.sp = last_sp
      # Desenhar na janela da esquerda
      @left_window.set_new_parameters(new_atk, new_pdef, new_mdef)
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar janelas
    @left_window.update
    @right_window.update
    @item_window.update
    refresh
    # Se a janela da direita estiver ativa: chamar update_right
    if @right_window.active
      update_right
      return
    end
    # Se a janela de Itens estiver ativa: chamar update_item
    if @item_window.active
      update_item
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Quando a janela da direita estiver Ativa)
  #--------------------------------------------------------------------------
  
  def update_right
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Alternar para a tela de Menu
      $scene = Scene_Menu.new(2)
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Se o equipamento for fixo
      if @actor.equip_fix?(@right_window.index)
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Ativar janela de Itens
      @right_window.active = false
      @item_window.active = true
      @item_window.index = 0
      return
    end
    # Se o botão R for pressionado
    if Input.trigger?(Input::R)
      # Reproduzir SE de cursor
      $game_system.se_play($data_system.cursor_se)
      # O cursor se move para o próximo Herói
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # Alternar para uma tela de equipamento diferente
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
    # Se o botão L for precionado
    if Input.trigger?(Input::L)
      # Reproduzir SE de cursor
      $game_system.se_play($data_system.cursor_se)
      # O cursor se move para o Herói anterior
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # Alternar para uma tela de equipamento diferente
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Quando a janela de Itens estiver Ativa)
  #--------------------------------------------------------------------------
  
  def update_item
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Ativar janela da direita
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Reproduzir SE de Equipamento
      $game_system.se_play($data_system.equip_se)
      # Selecionar dados escolhidos na janela de Item
      item = @item_window.item
      # Mudar Equipamento
      @actor.equip(@right_window.index, item == nil ? 0 : item.id)
      # Ativar janela da direita
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      # Recriar os conteúdos da janela de Itens e da direita
      @right_window.refresh
      @item_window.refresh
      return
    end
  end
end
