#==============================================================================
# Main
#------------------------------------------------------------------------------
# Após o final de cada definição de classe o processo principal
# do jogo é iniciado. Esta é a classe principal do jogo.
#==============================================================================

begin
  
  # É definida aqui a fonte usada nas janelas do jogo
  # Você pode usar aqui qualquer fonte disponível em seu computador
  # Porém é recomendável usar fontes padrão do Windows
  # Por exemplo: Arial, Lucida Console, Tahoma, Verdana...
  
  $defaultfonttype = $fontface = $fontname = Font.default_name = "Arial"
  
  # É definido aqui o tamanho da fonte usada nas janelas de jogo
  # O tamanho padrão é 25. Porém, você pode usar o tamanho que você
  # achar melhor para seu sistema e fonte
  
  $defaultfontsize = $fontsize = Font.default_size = 16
  
  # É preparada uma transição de tela
  
  Graphics.freeze
  
  # Aqui é chamada a tela título do jogo. O script padrão
  # de título é 'Scene_Title'. Você pode mudá-lo, mas isso não é
  # recomendável
  
  $scene = Scene_Title.new
  
  # É definida a limitação efetiva da variável $scene.
  # Se esta é nula, é chamado o método principal
  
  while $scene != nil
    $scene.main
  end
  
  # A transição de tela é executada
  
  Graphics.transition(20)
rescue Errno::ENOENT
  
  # Aqui, definimos a mensagem padrão para Errno::ENOENT
  # Quando não é possível abrir um arquivo, a mensagem é exibida
  
  filename = $!.message.sub("Arquivo não encontrado - ", "")
  print("O Arquivo #{filename} não foi encontrado.")
end
