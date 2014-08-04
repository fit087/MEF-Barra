clear
%Programa para c�lculo de treli�as
f = 300     %fator de escala para visualiza��o da deformada

%Identifica��o dos eixos de coordenadas
x = 0   %eixo e coordenadas na dire��o x representado por 0
y = 1   %eixo e coordenadas na dire��o y representado por 1

%Caracter�sticas da malha
noselem = 2     %n�mero de n�s por elemento
dfreedom = 2    %n�mero de graus de liberdade
nnods = 6       %n�mero de n�s da treli�a
nelem = 9       %n�mero de elementos da treli�a

%Propriedades
A = 0.00146373           %�rea da se��o em m^2
E = 205E9                %m�dulo de elasticidade em Pa

%Geometria
coordenadas = [0 0; 0 1; 0 2; 0.5 1.5; 1 1; 0.5 0.5]                     %coordenadas dos n�s
conections = [1 2; 1 6; 2 3; 2 4; 2 5; 2 6; 3 4; 4 5; 5 6]          %conectividades dos elementos

%Condi��es de Contorno
nloads = 2          %n�mero de cargas aplicadas na estrutura
nrestriction = 3    %n�mero de restri��es na estrutura
load = [3 x 10000; 6 y -10000]            %carga aplicada na treli�a
restriction = [1 x; 1 y; 5 y]     %posi��es das restri��es

%Propriedades dos elementos
for i = 1:nelem     %contador da matriz
%proje��o do elemento em x
deltax = coordenadas(conections(i,1),1) - coordenadas(conections(i,2),1)
%proje��o do elemento em y
deltay = coordenadas(conections(i,1),2) - coordenadas(conections(i,2),2)
%Angulo de inclina��o do elemento
barra(i,1) = atan2(deltay,deltax);
%Comprimento do elemento
barra(i,2) = sqrt(deltax*deltax + deltay*deltay);
end

%Matriz Rigidez e Superposi��o
for i = 1:nnods*dfreedom
        Lglobal(i) = 0      %vetor de cargas
    for j = 1:nnods*dfreedom
        Kglobal(i,j) = 0    %matriz rigidez global
    end
end
%Matriz Rigidez
for i = 1:nelem
    K(1,1) = (cos(barra(i,1)))^2*(E*A)/barra(i,2)
    K(1,2) = (cos(barra(i,1)))*(sin(barra(i,1)))*(E*A)/barra(i,2)
    K(1,3) = -(cos(barra(i,1)))^2*(E*A)/barra(i,2)
    K(1,4) = -(cos(barra(i,1)))*(sin(barra(i,1)))*(E*A)/barra(i,2)
    K(2,2) = (sin(barra(i,1)))^2*(E*A)/barra(i,2)
    K(2,3) = -(cos(barra(i,1)))*(sin(barra(i,1)))*(E*A)/barra(i,2)
    K(2,4) = -(sin(barra(i,1)))^2*(E*A)/barra(i,2)
    K(3,3) = (cos(barra(i,1)))^2*(E*A)/barra(i,2)
    K(3,4) = (cos(barra(i,1)))*(sin(barra(i,1)))*(E*A)/barra(i,2)
    K(4,4) = (sin(barra(i,1)))^2*(E*A)/barra(i,2)
    %Por simetria temos:
    K(2,1) = K(1,2) 
    K(3,1) = K(1,3)
    K(4,1) = K(1,4)
    K(3,2) = K(2,3)
    K(4,2) = K(2,4)
    K(4,3) = K(3,4)
    
    %Superposi��o
    for j = 1:noselem
        for k = 1:dfreedom
            colE = (j-1)*dfreedom + k
            for l = 1:noselem
                for m = 1:dfreedom
                    linE = (l-1)*dfreedom + m
                    colG = (conections(i,j)-1)*dfreedom + k
                    linG = (conections(i,l)-1)*dfreedom + m
                    Kglobal(linG,colG) =  Kglobal(linG,colG) + K(linE,colE)
                end
            end
        end
    end
end

%Matriz de carregamento

for i = 1:nloads
    linG = 2*load(i,1)-(1-load(i,2))
    Lglobal(linG) = Lglobal(linG) + load(i,3)
end

%Condi��es de Contorno

for i = 1:nrestriction 
    linG=2*(restriction(i,1))-(1-(restriction(i,2)))
    for j = 1:nnods*dfreedom
        if linG==j
            Kglobal(linG,j)=1
        else Kglobal(linG,j)=0
        end
        if linG == j 
            Kglobal(j,linG)=1
            else Kglobal(j,linG) = 0
        end
    end
end

%Resultados
desloc = Lglobal/Kglobal     %deslocamento dos n�s em m
deslocmm = desloc*1E3        %deslocamento dos n�s em mm

axis off 
daspect([1,1,1])
hold on;
for i = 1:nelem
   no1 = conections(i,1)
   no2 = conections(i,2)
   x(1) = coordenadas(no1,1); y(1) = coordenadas(no1,2);
   x(2) = coordenadas(no2,1); y(2) = coordenadas(no2,2);  
   plot(x,y,'LineWidth',1,'LineStyle',':','Marker','o')   
end
%coordenadas dos n�s deformados
for i = 1:nnods
        defx(i) = coordenadas(i,1)+ f*desloc(2*i-1)
        defy(i) = coordenadas(i,2)+ f*desloc(2*i)
end

for i = 1:nnods
    deformacao(i,1) = defx(i)
    deformacao(i,2) = defy(i)
end

for i = 1:nelem
   no1 = conections(i,1)
   no2 = conections(i,2)
   xdef(1) = deformacao(no1,1); ydef(1) = deformacao(no1,2);
   xdef(2) = deformacao(no2,1); ydef(2) = deformacao(no2,2);
   plot(xdef,ydef,'LineWidth',2,'Color','red','Marker','o')   
end

hold off;
            
    

        
        
    