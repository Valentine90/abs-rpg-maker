#==============================================================================
# ** Input
#------------------------------------------------------------------------------
# Este script complementa o Input padrão, sem substituí-lo, para
# verificar se as teclas de atalho da hotbar, do ataque e da
# defesa do herói foram ou estão sendo pressionadas.
#------------------------------------------------------------------------------
# Autor: Valentine
# Última atualização: 13/01/2023
#==============================================================================

module Input
  #--------------------------------------------------------------------------
  class << self
    alias diamond_abs_trigger? trigger?
    alias diamond_abs_press? press?
    alias diamond_abs_update update
  end
  #--------------------------------------------------------------------------
  # Matrizes das chaves pressionadas
  @triggered = []
  @pressed = []
  # Chaves
  KEYS = {
    :num_1    => 49,
    :num_2    => 50,
    :num_3    => 51,
    :num_4    => 52,
    :num_5    => 53,
    :num_6    => 54,
    :num_7    => 55,
    :num_8    => 56,
    :num_9    => 57,
    :letter_d => 68,
    :letter_s => 83
  }
  # Win32 API
  GET_ASYNC_KEY_STATE = Win32API.new('user32', 'GetAsyncKeyState', 'i', 'i')
  GET_KEY_STATE = Win32API.new('user32', 'GetKeyState', 'i', 'i')
  #--------------------------------------------------------------------------
  # * Verifica se as chaves foram pressionandas
  #     keys : chaves
  #--------------------------------------------------------------------------
  def self.trigger?(keys)
    if keys.is_a?(Array)
      keys.any? { |key| trigger?(key) }
    elsif KEYS.has_key?(keys)
      return @triggered.include?(KEYS[keys])
    elsif @triggered.include?(keys)
      return true
    else
      return diamond_abs_trigger?(keys)
    end
  end
  #--------------------------------------------------------------------------
  # * Verifica se as chaves estão sendo pressionandas
  #     keys : chaves
  #--------------------------------------------------------------------------
  def self.press?(keys)
    if keys.is_a?(Array)
      keys.any? { |key| press?(key) }
    elsif KEYS.has_key?(keys)
      return @pressed.include?(KEYS[keys])
    elsif @pressed.include?(keys)
      return true
    else
      return diamond_abs_press?(keys)
    end
  end
  #--------------------------------------------------------------------------
  # * Atualização do frame
  #--------------------------------------------------------------------------
  def self.update
    @triggered.clear
    @pressed.clear
    KEYS.each_value do |key|
      @triggered << key if GET_ASYNC_KEY_STATE.call(key) & 0x01 == 1
      @pressed << key if GET_KEY_STATE.call(key) > 1
    end
    diamond_abs_update
  end
end
