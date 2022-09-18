#==============================================================================
# ** Input
#------------------------------------------------------------------------------
# Autor: Valentine
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
    :NUM_1    => 49,
    :NUM_2    => 50,
    :NUM_3    => 51,
    :NUM_4    => 52,
    :NUM_5    => 53,
    :NUM_6    => 54,
    :NUM_7    => 55,
    :NUM_8    => 56,
    :NUM_9    => 57,
    :LETTER_D => 68,
    :LETTER_S => 83 
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
