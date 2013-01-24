Filtro Pseudo Inversa
=====================

Implementação do filtro da pseudo-inversa em octave

## Definições ##

Este é um script para fins educativos, para observar alguns conceitos da disciplina de processamento de imagens.

É uma demonstração do funcinoamento dos filtros de restauração sobre as observações ruidosas de uma imagem.

No processo de aquisição de uma imagem, a observação é submetida a funções de espalhamento pontual e a ruídos.

- A imagem real aqui é representada por f;
- A função de espalhamento pontual é representada por g, e neste exemplo trata-se de uma função gaussiana; 
- O ruído, representado por n neste exemplo, é uma função randômica uniformemente distribuída, cuja soma é zero, e é simplesmente somada à observação.
- A observação obtida, representada por g, é dada pela convolução de f com h mais o ruído:
<code> g = conv(f, h) + n </code>

A restauração da imagem pode ser dada pelos filtros da pseudo-inversa, de Wiener ou de Tikhonov.

A descrição do problema está detalhado no arquivo Quarta_atividade_pratica.pdf, e os detalhes da aplicação destes filtros são explicados na forma de comentários no código.

## Uso ##
O script deve ser rodado no [Octave](www.gnu.org/software/octave/).

## 
Ele executará os seguintes passos para simular a aquisição da imagem:
- Abre uma imagem preto e branco;
- Gera uma função gaussiana com as mesmas dimensões da imagem;
	* A função gaussiana é adequada, pois ao contrário de outros filtros, seus valores tendem a 0, mas nunca atingem o valor 0. Isto evita a divisão por 0 durante as operações;
- Gera um ruído;
- Realiza uma convolução entre a imagem e a gaussiana;
- Soma o ruído ao resultado da convolução;

Em seguida, executará os passos para restaurar a imagem original:
- Aplica a pseudo-inversa dada por
<code> F = G / H </code>, onde
- F é a imagem resaturada no dominio da frequencia;
- G é a imagem adquirida no domínio da frequencia;
- H é a função de transferencia, ou seja, a gaussiana no domínio da frequencia.

