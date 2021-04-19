#==============================================================================
# Scene_Item
#------------------------------------------------------------------------------
# Esta classe processa a tela de Itens
#==============================================================================

class Scene_Item
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Aqui são criadas as janelas de Ajuda e de Itens
    @help_window = Window_Help.new
    @item_window = Window_Item.new
    # Associar a janela de Ajuda
    @item_window.help_window = @help_window
    # Criar janela alvo (definir como invisível / inativa)
    @target_window = Window_Target.new
    @target_window.visible = false
    @target_window.active = false
    # Executar transição
    Graphics.transition
    # Loop principal
    loop do
      # Atualizar a tela de jogo
      Graphics.update
      # Atualizar a entrada de informações
      Input.update
      # Atualização do frame
      update
      # Abortar o loop se a tela foi alterada
      if $scene != self
        break
      end
    end
    # Prepara para transição
    Graphics.freeze
    # Exibição das janelas
    @help_window.dispose
    @item_window.dispose
    @target_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualizar janelas
    @help_window.update
    @item_window.update
    @target_window.update
    # Se a janela de Itens estiver ativa: chamar update_item
    if @item_window.active
      update_item
      return
    end
    # Se a janela alvo estiver ativa: chamar update_target
    if @target_window.active
      update_target
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
      # Alternar para a tela de Menu
      $scene = Scene_Menu.new(0)
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Selecionar os dados escolhidos na janela de Itens
      @item = @item_window.item
      # Se não for um Item usável
      unless @item.is_a?(RPG::Item)
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Se não puder ser usado
      unless $game_party.item_can_use?(@item.id)
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Se o alcance do Item for um aliado
      if @item.scope >= 3
        # Ativar a janela alvo
        @item_window.active = false
        @target_window.x = (@item_window.index + 1) % 2 * 304
        @target_window.visible = true
        @target_window.active = true
        # Definir a posição do cursor no alvo (aliado / todo grupo)
        if @item.scope == 4 || @item.scope == 6
          @target_window.index = -1
        else
          @target_window.index = 0
        end
      # Se o alcance for outro senão um aliado
      else
        # Se o ID do evento comum for inválido
        if @item.common_event_id > 0
          # Chamar evento comum da reserva
          $game_temp.common_event_id = @item.common_event_id
          # Reproduzir SE do Item
          $game_system.se_play(@item.menu_se)
          # Se for consumível
          if @item.consumable
            # Diminui 1 Item da quantidade total
            $game_party.lose_item(@item.id, 1)
            # Desenhar o Item
            @item_window.draw_item(@item_window.index)
          end
          # Alternar para a tela do Mapa
          $scene = Scene_Map.new
          return
        end
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Quando a janela alvo estiver Ativa)
  #--------------------------------------------------------------------------
  
  def update_target
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Se for impossível utilizar porque o Item não existe mais
      unless $game_party.item_can_use?(@item.id)
        # Recriar os conteúdos da janela de ìtens
        @item_window.refresh
      end
      # Apagar a janela alvo
      @item_window.active = true
      @target_window.visible = false
      @target_window.active = false
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Se chegar ao número 0 da quantidade de Itens
      if $game_party.item_number(@item.id) == 0
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Se o alvo for todos o Grupo
      if @target_window.index == -1
        # Os efeitos serão aplicados a todos
        used = false
        for i in $game_party.actors
          used |= i.item_effect(@item)
        end
      end
      # Se for apenas um aliado o alvo
      if @target_window.index >= 0
        # Aplicar os efeitos apenas no Herói alvo
        target = $game_party.actors[@target_window.index]
        used = target.item_effect(@item)
      end
      # Se o Item for usado
      if used
        # Reproduzir SE do Item
        $game_system.se_play(@item.menu_se)
        # Se for consumível
        if @item.consumable
          # Diminui 1 item da quantidade total
          $game_party.lose_item(@item.id, 1)
          # Redesenhar o Item
          @item_window.draw_item(@item_window.index)
        end
        # Recriar os conteúdos da janela alvo
        @target_window.refresh
        # Se todos no Grupo de Heróis estiverm mortos
        if $game_party.all_dead?
          # Alternar para a tela de Game Over
          $scene = Scene_Gameover.new
          return
        end
        # Se o ID do evento comum for válido
        if @item.common_event_id > 0
          # Chamar o evento comum da reserva
          $game_temp.common_event_id = @item.common_event_id
          # Alternar para a tela do Mapa
          $scene = Scene_Map.new
          return
        end
      end
      # Se o Item não for usado
      unless used
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
      end
      return
    end
  end
end
