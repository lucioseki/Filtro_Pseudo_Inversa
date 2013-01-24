clear all; close all;
# aplicando ruido e removendo com a inversa
# g = conv2( h, f ) + n
## g = imagem obtida
## h = funcao de espalhamento pontual
## f = imagem original
## n = ruido aditivo
# 
# filtro de restauracao: pseudo-inversa no dominio da frequencia
# F = G / H
## F = imagem estimada no dominio da frequencia
## G = TF de g
## H = TF de h

# ------------------------------------------------------------
# Imagem original
# ------------------------------------------------------------

f = imread("relogio.jpg");
[x, y] = size(f);

# f com 0-padding para evitar convolucao circular
fpad = zeros(x * 2, y * 2);
fpad([x/2 + 1 : x/2 + x], [y/2 + 1 : y/2 + y]) = f;

figure(1), colormap(gray(256)), image(fpad), title("fpad");

# ------------------------------------------------------------
# Gaussiana
# ------------------------------------------------------------

# variancia = desvio padrao ^ 2

variancia = 1;
left = 1 / ((2 * pi * variancia)**0.5);
expdiv = 2 * variancia;

h = zeros(x, y);
for i = 1 : x
	for j = 1 : y
		h(i, j) = left * e**(-( ((i - x / 2)**2 + (j - y / 2)**2) / expdiv ));
	end
end

# Normalização para preservar o nível DC
h = h ./ sum(sum(h));
