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

variancia = 0.5;
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
# h com 0-padding para evitar convolucao circular
hpad = zeros(x * 2, y * 2);
hpad([x/2 + 1 : x/2 + x], [y/2 + 1 : y/2 + y]) = h;

# ------------------------------------------------------------
# Convolução
# ------------------------------------------------------------

# convolução entre a imagem original e a gaussiana
gconv = conv2(fpad, hpad, "same");
figure(2), colormap(gray(256)), image(gconv), title("gconv");

# A extensão por zero-padding é necessária para evitar a convolução circular, fenômeno que pegaria posições negativas da matriz, utilizando valores replicados da função. Ao extender a imagem, a operação de convolução deixa de utilizar valores negativos.

# ------------------------------------------------------------
# Ruído
# ------------------------------------------------------------

# ruido randomico entre 0 e 1
n = rand(x);
# para deixar uniforme, gero numeros negativos tambem
n = n .- 0.5;
# multiplico por uma constante para aumentar a magnitude
n = 20 * n;

# imagem adquirida:
# convolucao da funcao de espalhamento com a imagem original
# mais o ruido aditivo uniforme sobre a imagem ruidosa
g = zeros(x * 2, y * 2);
g([x/2 + 1 : x/2 + x], [y/2 + 1 : y/2 + y]) = gconv([x/2 + 1 : x/2 + x], [y/2 + 1 : y/2 + y]) .+ n;
figure(3), colormap(gray(256)), image(g), title("g");

# ------------------------------------------------------------
# RESTAURACAO
# ------------------------------------------------------------

# operacao com as dimensoes da imagem original, para diminuir o custo computacional

# H = funcao de transferencia (TF de h)
H = fft2(hpad([x/2 + 1:x/2 + x],[y/2 + 1:y/2 + y]));

# G = TF de g
G = fft2(g([x/2 + 1:x/2 + x],[y/2 + 1:y/2 + y]));

# F_ = imagem estimada no dominio da frequencia
F_ = G ./ H;

# f_ = imagem estimada no dominio do espaco
f_ = ifft2(F_);

# normalizacao para ajustar a 256 tons de cinza
tommax = max(max(real(f_)));
tommin = min(min(real(f_)));

f_norm = 256*(real(f_) - tommin)/(tommax-tommin);
figure(4), colormap(gray(256)), image(real(f_norm)), title("inversa aplicada");

# a convolucao opera com posicoes negativas da matriz h
# por isso o resultado vem deslocado
# desloco novamente para corrigir
f_shift = fftshift(f_norm);
figure(5), colormap(gray(256)), image(real(f_shift)), title("shift sobre a inversa");

# ------------------------------------------------------------
# Multiplicando o divisor por uma constante
# ------------------------------------------------------------

constante = 128**2;
Fconst = G ./ (constante * H);
# Os valores obtidos tem magnitude muito diferente da operação sem a multiplicação com a constante
fconst = ifft2(Fconst);

tommaxconst = max(max(real(fconst)));
tomminconst = min(min(real(fconst)));
fconstnorm = 256*(real(fconst) - tomminconst)/(tommaxconst-tomminconst);

# Mas ao normalizar, os valores são iguais, pois a proporção entre os valores da imagem restaurada são os mesmos.
fconstshift = fftshift(fconstnorm);
figure(6), colormap(gray(256)), image(real(fconstshift)), title("shift sobre a inversa com constante");
