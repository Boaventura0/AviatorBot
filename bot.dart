import 'dart:math';

void main() {
  // Exemplo de dados passados do jogo (valores aleatórios para ilustrar)
  List<double> voosAnteriores = [1.5, 2.3, 3.1, 1.9, 2.5, 3.0, 4.2, 2.7];
  
  // Chama a função para prever o próximo voo
  double previsao = preverProximoVoo(voosAnteriores);

  // Exibe a previsão
  print("A previsão do próximo voo é: $previsao");
}

// Função para prever o próximo voo com base nos dados anteriores
double preverProximoVoo(List<double> voos) {
  // Simples algoritmo de média para prever o próximo voo
  double media = voos.reduce((a, b) => a + b) / voos.length;
  
  // Adiciona uma variação aleatória para tornar a previsão mais interessante
  Random rand = Random();
  double variacao = rand.nextDouble() * 1.5; // A variação pode ser até 1.5 vezes o valor médio
  return media + variacao;
}
