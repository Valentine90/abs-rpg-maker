#==============================================================================
# Scene_Shop
#------------------------------------------------------------------------------
# Esta classe processa a tela da Loja
#==============================================================================

class Scene_Shop
  
  #--------------------------------------------------------------------------
  # Processamento Principal
  #--------------------------------------------------------------------------
  
  def main
    # Criar janela de ajuda
    @help_window = Window_Help.new
    # Criar janela de comandos de Loja
    @command_window = Window_ShopCommand.new
    # Criar janela de dinheiro
    @gold_window = Window_Gold.new
    @gold_window.x = 480
    @gold_window.y = 64
    # Criar janela testa-de-ferro
    @dummy_window = Window_Base.new(0, 128, 640, 352)
    # Criar janela de compra
    @buy_window = Window_ShopBuy.new($game_temp.shop_goods)
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    # Criar janela de venda
    @sell_window = Window_ShopSell.new
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
    # Criar janela de entrada de quantidade
    @number_window = Window_ShopNumber.new
    @number_window.active = false
    @number_window.visible = false
    # Criar janela de Status
    @status_window = Window_ShopStatus.new
    @status_window.visible = false
    # Executar transição
    Graphics.transition
    # Loop principal
    loop do
      # Atualizar tela de jogo
      Graphics.update
      # Atualizar entrada de informações
      Input.update
      # Atualização do frame
      update
      # Abortar loop se a tela se alterou
      if $scene != self
        break
      end
    end
    # Preparar para transição
    Graphics.freeze
    # Exibição das janelas
    @help_window.dispose
    @command_window.dispose
    @gold_window.dispose
    @dummy_window.dispose
    @buy_window.dispose
    @sell_window.dispose
    @number_window.dispose
    @status_window.dispose
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame
  #--------------------------------------------------------------------------
  
  def update
    # Atualização das janelas
    @help_window.update
    @command_window.update
    @gold_window.update
    @dummy_window.update
    @buy_window.update
    @sell_window.update
    @number_window.update
    @status_window.update
    # Se a janela de comandos estiver ativa: chamar update_command
    if @command_window.active
      update_command
      return
    end
    # Se a janela de compra estiver ativa: chamar update_buy
    if @buy_window.active
      update_buy
      return
    end
    # Se a janela de venda estiver ativa: chamar update_sell
    if @sell_window.active
      update_sell
      return
    end
    # Se janela de entrada de quantidade estiver ativa: chamar update_number
    if @number_window.active
      update_number
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Quando a janela de comandos estiver ativa)
  #--------------------------------------------------------------------------
  
  def update_command
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Alternar para a tela do Mapa
      $scene = Scene_Map.new
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Ramificação por posição na janela de comandos
      case @command_window.index
      when 0  # Comprar
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Mudar janelas para o modo de Compra
        @command_window.active = false
        @dummy_window.visible = false
        @buy_window.active = true
        @buy_window.visible = true
        @buy_window.refresh
        @status_window.visible = true
      when 1  # Vender
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Mudar janelas para o modo de Venda
        @command_window.active = false
        @dummy_window.visible = false
        @sell_window.active = true
        @sell_window.visible = true
        @sell_window.refresh
      when 2  # Sair
        # Reproduzir SE de OK
        $game_system.se_play($data_system.decision_se)
        # Alternar para a tela do Mapa
        $scene = Scene_Map.new
      end
      return
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Quando a janela de Compra estiver ativa)
  #--------------------------------------------------------------------------
  
  def update_buy
    # Definir janela de Status do Item
    @status_window.item = @buy_window.item
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Mudar janela para o modo inicial
      @command_window.active = true
      @dummy_window.visible = true
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      # Apagar texto de ajuda
      @help_window.set_text("")
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Selecionar Item
      @item = @buy_window.item
      # Se o Item for inválido, ou o preço for maior do que o dinheiro possuído
      if @item == nil or @item.price > $game_party.gold
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Selecionar contador de Itens possuídos
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
      end
      # Se já houverem 99 Itens possuídos
      if number == 99
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Aqui é calculado o número máximo de Itens que se pode comprar
      max = @item.price == 0 ? 99 : $game_party.gold / @item.price
      max = [max, 99 - number].min
      # Mudar janelas para o modo de entrada de quantidade
      @buy_window.active = false
      @buy_window.visible = false
      @number_window.set(@item, max, @item.price)
      @number_window.active = true
      @number_window.visible = true
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame (Quando a janela de Venda estiver ativa)
  #--------------------------------------------------------------------------
  
  def update_sell
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # reporduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Mudar janelas para o modo inicial
      @command_window.active = true
      @dummy_window.visible = true
      @sell_window.active = false
      @sell_window.visible = false
      @status_window.item = nil
      # Apagar texto de ajuda
      @help_window.set_text("")
      return
    end
    # Se o botão C for pressionado
    if Input.trigger?(Input::C)
      # Selecionar Item
      @item = @sell_window.item
      # Definir a janela de Status do Item
      @status_window.item = @item
      # Se o Item for inválido, ou o preço do Item for 0 (impossível vender)
      if @item == nil or @item.price == 0
        # Reproduzir SE de erro
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Reproduzir SE de OK
      $game_system.se_play($data_system.decision_se)
      # Selecionar contador de Itens possuídos
      case @item
      when RPG::Item
        number = $game_party.item_number(@item.id)
      when RPG::Weapon
        number = $game_party.weapon_number(@item.id)
      when RPG::Armor
        number = $game_party.armor_number(@item.id)
      end
      # Quantidade máxima para vender = número de Itens possuídos
      max = number
      # Mudar janelas para o modo de entrada de quantidade
      @sell_window.active = false
      @sell_window.visible = false
      @number_window.set(@item, max, @item.price / 2)
      @number_window.active = true
      @number_window.visible = true
      @status_window.visible = true
    end
  end
  
  #--------------------------------------------------------------------------
  # Atualização do Frame 
  #     (Quando a janela de entrada de quantidade estiver ativa)
  #--------------------------------------------------------------------------
  
  def update_number
    # Se o botão B for pressionado
    if Input.trigger?(Input::B)
      # Reproduzir SE de cancelamento
      $game_system.se_play($data_system.cancel_se)
      # Definir a janela de entrada de quantidade como inativa / invisível
      @number_window.active = false
      @number_window.visible = false
      # Ramificação por posição do cursor na janela de comandos
      case @command_window.index
      when 0  # Comprar
        # Mudar janelas para o modo de Compra
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # sell
        # Mudar janelas para o modo de Venda
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
    # Se o botão B for pressionado
    if Input.trigger?(Input::C)
      # Reproduzir SE de Loja
      $game_system.se_play($data_system.shop_se)
      # Definir a janela de entrada de quantidade como inativa / invisível
      @number_window.active = false
      @number_window.visible = false
      # Ramificação por posição do cursor na janela de comandos
      case @command_window.index
      when 0  # Comprar
        # Processo de compra
        $game_party.lose_gold(@number_window.number * @item.price)
        case @item
        when RPG::Item
          $game_party.gain_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.gain_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.gain_armor(@item.id, @number_window.number)
        end
        # Atualizar cada janela
        @gold_window.refresh
        @buy_window.refresh
        @status_window.refresh
        # Mudar janelas para o modo de Compra
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # Vender
        # processo de venda
        $game_party.gain_gold(@number_window.number * (@item.price / 2))
        case @item
        when RPG::Item
          $game_party.lose_item(@item.id, @number_window.number)
        when RPG::Weapon
          $game_party.lose_weapon(@item.id, @number_window.number)
        when RPG::Armor
          $game_party.lose_armor(@item.id, @number_window.number)
        end
        # Atualizar cada janela
        @gold_window.refresh
        @sell_window.refresh
        @status_window.refresh
        # Mudar janelas para o modo de Venda
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
  end
end
