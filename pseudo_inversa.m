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

# 1) Considere uma das imagens de dimensão quadrada disponibilizada no moodle (lena.jpg ou relogio.jpg) com MxM pixels.
f = imread("relogio.jpg");
[x, y] = size(f);

# 1) a) Estenda a imagem escolhida f(x,y) por dois em ambas as direções considerando a abordagem de "zero-padding"
# f com 0-padding para evitar convolucao circular
fpad = zeros(x * 2, y * 2);
fpad([x/2 + 1 : x/2 + x], [y/2 + 1 : y/2 + y]) = f;

figure(1), colormap(gray(256)), image(fpad), title("fpad");

# ------------------------------------------------------------
# Gaussiana
# ------------------------------------------------------------

# 1) b) Construa uma função de espalhamento pontual h(x,y)

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

# 1) c) normalize adequadamente a nova matriz de forma que ela preserve o nível DC
# Normalização para preservar o nível DC
h = h ./ sum(sum(h));

# 1) d) Estenda a função h(x,y) com o procedimento "zero-padding"
# h com 0-padding para evitar convolucao circular
hpad = zeros(x * 2, y * 2);
hpad([x/2 + 1 : x/2 + x], [y/2 + 1 : y/2 + y]) = h;

# ------------------------------------------------------------
# Convolução
# ------------------------------------------------------------

# 1) e) Faça a convolução das imagens estendidas f(x,y) e h(x,y).
# convolução entre a imagem original e a gaussiana
gconv = conv2(fpad, hpad, "same");
figure(2), colormap(gray(256)), image(gconv), title("gconv");

# Explique por que é necessário estender as imagens com zeros para realizar este procedimento.
# A extensão por zero-padding é necessária para evitar a convolução circular, fenômeno que pegaria posições negativas da matriz, utilizando valores replicados da função. Ao extender a imagem, a operação de convolução deixa de utilizar valores negativos.

# ------------------------------------------------------------
# Ruído
# ------------------------------------------------------------

# 1) f) utilize a função rand para incorporar ruído na imagem borrada pela função de espalhamento pontual.
# ruido randomico entre 0 e 1
n = rand(x);
# para deixar uniforme, gero numeros negativos tambem
n = n .- 0.5;
# multiplico por uma constante para aumentar a magnitude
n = 20 * n;

# O objetivo dos itens acima é gerar uma imagem degradada g(x,y) modelada pela equação
# g(x,y) = f(x,y)*h(x,y)+n(x,y).
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

# 2) Após a geração da imagen g(x,y), calcule:
# 2) a) uma estimativa para f(x,y) dada pelo filtro de mínima norma sem restrições;

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
