#==============================================================================
# ** Input
#------------------------------------------------------------------------------
# Autor: Blizzard
#==============================================================================

module Input
  #----------------------------------------------------------------------------
  # * Tabela ASCII
  #----------------------------------------------------------------------------
  Key = {'A' => 65, 'B' => 66, 'C' => 67, 'D' => 68, 'E' => 69, 'F' => 70, 
         'G' => 71, 'H' => 72, 'I' => 73, 'J' => 74, 'K' => 75, 'L' => 76, 
         'M' => 77, 'N' => 78, 'O' => 79, 'P' => 80, 'Q' => 81, 'R' => 82, 
         'S' => 83, 'T' => 84, 'U' => 85, 'V' => 86, 'W' => 87, 'X' => 88, 
         'Y' => 89, 'Z' => 90, 'NumberKey 0' => 48, 'NumberKey 1' => 49,
         'NumberKey 2' => 50, 'NumberKey 3' => 51, 'NumberKey 4' => 52,
         'NumberKey 5' => 53, 'NumberKey 6' => 54, 'NumberKey 7' => 55,
         'NumberKey 8' => 56, 'NumberKey 9' => 57, 'NumberPad 0' => 96,
         'NumberPad 1' => 97, 'NumberPad 2' => 98, 'NumberPad 3' => 99,
         'NumberPad 4' => 100, 'NumberPad 5' => 101, 'NumberPad 6' => 102,
         'NumberPad 7' => 103, 'NumberPad 8' => 104, 'NumberPad 9' => 105,
         'F1' => 112, 'F2' => 113, 'F3' => 114, 'F4' => 115, 'F5' => 116,
         'F6' => 117, 'F7' => 118, 'F8' => 119, 'F9' => 120, 'F10' => 121,
         'F11' => 122, 'F12' => 123, ';' => 186, '=' => 187, ',' => 188,
         '-' => 189, '.' => 190, '/' => 220, '\\' => 191, '\'' => 222,
         '[' => 219, ']' => 221, '`' => 192, 'Backspace' => 8, 'Tab' => 9,
         'Enter' => 13, 'Shift' => 16, 'Left Shift' => 160, 'Right Shift' => 161,
         'Left Ctrl' => 162, 'Right Ctrl' => 163, 'Left Alt' => 164,
         'Right Alt' => 165, 'Ctrl' => 17, 'Alt' => 18, 'Esc' => 27,
         'Space' => 32, 'Page Up' => 33, 'Page Down' => 34, 'End' => 35,
         'Home' => 36, 'Insert' => 45, 'Delete' => 46, 'Left' => 37, 'Up' => 38,
         'Right' => 39, 'Down' => 40, 'Mouse Left' => 1, 'Mouse Right' => 2,
         'Mouse Middle' => 4, 'Mouse 4' => 5, 'Mouse 5' => 6}
  # Configuração inicial
  UP = [Key['Up']]
  LEFT = [Key['Left']]
  DOWN = [Key['Down']]
  RIGHT = [Key['Right']]
  A = [Key['Shift']]
  B = [Key['Esc']]
  C = [Key['Enter']]
  X = [Key['A']]
  Y = [Key['S']]
  Z = [Key['D']]
  L = [Key['Page Down']]
  R = [Key['Page Up']]
  F5 = [Key['F5']]
  F6 = [Key['F6']]
  F7 = [Key['F7']]
  F8 = [Key['F8']]
  F9 = [Key['F9']]
  SHIFT = [Key['Shift']]
  CTRL = [Key['Ctrl']]
  ALT = [Key['Alt']]
  # Todas as teclas
  ALL_KEYS = (0...256).to_a
  # Win32 API
  GetKeyboardState = Win32API.new('user32', 'GetKeyboardState', 'P', 'I')
  GetKeyboardLayout = Win32API.new('user32', 'GetKeyboardLayout', 'L', 'L')
  MapVirtualKeyEx = Win32API.new('user32', 'MapVirtualKeyEx', 'IIL', 'I')
  ToUnicodeEx = Win32API.new('user32', 'ToUnicodeEx', 'LLPPILL', 'L')
  # Algumas outras constantes
  DOWN_STATE_MASK = 0x80
  DEAD_KEY_MASK = 0x80000000
  # Dados
  @state = "\0" * 256
  @triggered = Array.new(256, false)
  @pressed = Array.new(256, false)
  @released = Array.new(256, false)
  @repeatedKey = -1
  @repeatedCount = 0
  #----------------------------------------------------------------------------
  # * Atualização do frame
  #----------------------------------------------------------------------------
  def self.update
    # Obter layout de idioma atual
    @language_layout = GetKeyboardLayout.call(0)
    # Obter novo estado do teclado
    GetKeyboardState.call(@state)
    # Este código especial é usado porque o Ruby 1.9.x não retorna um caractere
    # ao usar string#[], mas outra string
    key = 0
    @state.each_byte {|byte|
      # Se está pressionando
      if (byte & DOWN_STATE_MASK) == DOWN_STATE_MASK
        # Não mais liberado
        @released[key] = false
        # Se ainda não foi pressionado
        if !@pressed[key]
          # Pressionado e acionado
          @pressed[key] = true
          @triggered[key] = true
          @repeatedKey = key
          @repeatedCount = 0
        else
          # Não mais acionado
          @triggered[key] = false
        end
        # Atualizar contador de repetição
        if key == @repeatedKey
          @repeatedCount < 17 ? @repeatedCount += 1 : @repeatedCount = 15
        end
      # Se ainda não foi lançado
      elsif !@released[key]
        # Se ainda está pressionado
        if @pressed[key]
          # Não acionado, pressionado ou repetido, mas liberado
          @triggered[key] = false
          @pressed[key] = false
          @released[key] = true
          if key == @repeatedKey
            @repeatedKey = -1
            @repeatedCount = 0
          end
        end
      else
        # Não mais liberado
        @released[key] = false
      end
      key += 1
    }
  end
  #----------------------------------------------------------------------------
  # * 4 direções
  #----------------------------------------------------------------------------
  def self.dir4
    return 2 if self.press?(DOWN)
    return 4 if self.press?(LEFT)
    return 6 if self.press?(RIGHT)
    return 8 if self.press?(UP)
    return 0
  end
  #----------------------------------------------------------------------------
  # * 8 direções
  #----------------------------------------------------------------------------
  def self.dir8
    down = self.press?(DOWN)
    left = self.press?(LEFT)
    return 1 if down && left
    right = self.press?(RIGHT)
    return 3 if down && right
    up = self.press?(UP)
    return 7 if up && left
    return 9 if up && right
    return 2 if down
    return 4 if left
    return 6 if right
    return 8 if up
    return 0
  end
  #----------------------------------------------------------------------------
  # * Pressionou?
  #     keys : teclas
  #----------------------------------------------------------------------------
  def self.trigger?(keys)
    keys = [keys] if !keys.is_a?(Array)
    return keys.any? {|key| @triggered[key]}
  end
  #----------------------------------------------------------------------------
  # * Pressionando?
  #     keys : teclas
  #----------------------------------------------------------------------------
  def self.press?(keys)
    keys = [keys] if !keys.is_a?(Array)
    return keys.any? {|key| @pressed[key]}
  end
  #----------------------------------------------------------------------------
  # * Repetindo?
  #     keys : teclas
  #----------------------------------------------------------------------------
  def self.repeat?(keys)
    keys = [keys] if !keys.is_a?(Array)
    return (@repeatedKey >= 0 && keys.include?(@repeatedKey) &&
        (@repeatedCount == 1 || @repeatedCount == 16))
  end
  #----------------------------------------------------------------------------
  # * Liberado?
  #     keys : teclas
  #----------------------------------------------------------------------------
  def self.release?(keys)
    keys = [keys] if !keys.is_a?(Array)
    return keys.any? {|key| @released[key]}
  end
  #----------------------------------------------------------------------------
  # * Obter caractere
  #     vk : tecla virtual
  #     Obtém o caractere de entrada do teclado usando o identificador de localidade
  #     de entrada (anteriormente chamado de layout de teclado handles).
  #----------------------------------------------------------------------------
  def self.get_character(vk)
    # Obter caractere correspondente de tecla virtual
    c = MapVirtualKeyEx.call(vk, 2, @language_layout)
    # Retornar se o caractere não é imprimível e não é uma tecla morta
    return '' if c < 32 && (c & DEAD_KEY_MASK) != DEAD_KEY_MASK
    # Obter o código de verificação
    vsc = MapVirtualKeyEx.call(vk, 0, @language_layout)
    # Resultado da string nunca é superior a 4 bytes (Unicode)
    result = "\0" * 4
    # Obter string de entrada do Win32 API
    length = ToUnicodeEx.call(vk, vsc, @state, result, 4, 0, @language_layout)
    return (length == 0 ? '' : result)
  end
  #----------------------------------------------------------------------------
  # * Obter string de entrada
  #     Obtém a string que foi inserida usando o teclado em vez do identificador
  #     de localidade de entrada (anteriormente chamado de layout de teclado handles).
  #----------------------------------------------------------------------------
  def self.get_input_string
    result = ''
    # Verificar cada tecla
    ALL_KEYS.each {|key|
      # Se for repetido
      if self.repeat?(key)
        # Obter caractere de estado do teclado
        c = self.get_character(key)
        # Adicionar o caractere se há um caractere e desde que este não seja um acento
        result += c if c != '' and key != 219 and key != 222
      end
    }
    # Retornar vazio se o resultado está vazio
    return '' if result == ''
    # Converter string de Unicode para UTF-8
    return self.unicode_to_utf8(result)
  end
  #----------------------------------------------------------------------------
  # * Unicode para UTF-8
  #     string : string em formato Unicode
  #     Converte uma cadeia de formato Unicode para o formato UTF-8 já que o RGSS 
  #     não suporta Unicode.
  #----------------------------------------------------------------------------
  def self.unicode_to_utf8(string)
    result = ''
    # O formato L* significa um grupo de caracteres de 4 bytes
    string.unpack('L*').each {|c|
      # Caracteres abaixo de 0x80 são caracteres de 1 byte
      if c < 0x0080
        result += c.chr
      # Outros caracteres abaixo de 0x800 são caracteres de 2 bytes
      elsif c < 0x0800
        result += (0xC0 | (c >> 6)).chr
        result += (0x80 | (c & 0x3F)).chr
      # Outros caracteres abaixo de 0x10000 são caracteres de 3 bytes
      elsif c < 0x10000
        result += (0xE0 | (c >> 12)).chr
        result += (0x80 | ((c >> 6) & 0x3F)).chr
        result += (0x80 | (c & 0x3F)).chr
      # Outros caracteres abaixo de 0x200000 são caracteres de 4 bytes
      elsif c < 0x200000
        result += (0xF0 | (c >> 18)).chr
        result += (0x80 | ((c >> 12) & 0x3F)).chr
        result += (0x80 | ((c >> 6) & 0x3F)).chr
        result += (0x80 | (c & 0x3F)).chr
      # Outros caracteres abaixo de 0x4000000 são caracteres de 5 bytes
      elsif c < 0x4000000
        result += (0xF8 | (c >> 24)).chr
        result += (0x80 | ((c >> 18) & 0x3F)).chr
        result += (0x80 | ((c >> 12) & 0x3F)).chr
        result += (0x80 | ((c >> 6) & 0x3F)).chr
        result += (0x80 | (c & 0x3F)).chr
      # Outros caracteres abaixo de 0x80000000 são caracteres de 6 bytes
      elsif c < 0x80000000
        result += (0xFC | (c >> 30)).chr
        result += (0x80 | ((c >> 24) & 0x3F)).chr
        result += (0x80 | ((c >> 18) & 0x3F)).chr
        result += (0x80 | ((c >> 12) & 0x3F)).chr
        result += (0x80 | ((c >> 6) & 0x3F)).chr
        result += (0x80 | (c & 0x3F)).chr
      end
    }
    return result
  end
end
