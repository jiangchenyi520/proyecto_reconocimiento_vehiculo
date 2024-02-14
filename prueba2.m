%Coger la imagen requerida
imagen = imread('images.jpg');
subplot(2,3,1);
imshow(imagen);

%Pasar al gris, eliminar ruidos y detectar color acerca de negro y blanco
imagen_gris=rgb2gray(imagen);
imagen_filtrada=imnlmfilt(imagen_gris);
imagen_umbralizacion = (imagen_filtrada < 70) | (imagen_filtrada > 230);

%Visualizarlo
subplot(2,3,2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  1 
imshow(imagen_umbralizacion);

%Detectar borde con metodo canny con 0.2 de sensitividad,que no sea tan
%sensible a los detelles y se enfoca más al borde
mascara_bordes = edge(imagen_umbralizacion, 'canny',0.2);
subplot(2,3,3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  2
imshow(mascara_bordes);


%Detectar circulos de radio de radio entre 10 y 70
rd=[10,70];
[centers,radii]=imfindcircles(imagen,rd,'ObjectPolarity','dark','Sensitivity',0.85);
viscircles(centers,radii);

%Detectar las primeras 10 rectas más fuerte
[H, theta, rho] = hough(mascara_bordes);
peaks = houghpeaks(H, 10);
lines = houghlines(mascara_bordes, theta, rho, peaks);
umbral_distancia = 200;

%Se dibuja solo las rectas que están cerca de circulo
hold on;
for i = 1:length(lines)
    for j = 1:size(centers, 1)
        distancia = norm([lines(i).point1 - centers(j,:), lines(i).point2 - centers(j,:)]);
        if distancia < umbral_distancia
            xy = [lines(i).point1; lines(i).point2];
            plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');   
            break;
        end
    end
end
hold off;

%Distinguir y separar los objectos detectados
subplot(2,3,4);
imshow(imagen);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3

rd=[10,70];
[centers,radii]=imfindcircles(imagen,rd,'ObjectPolarity','dark','Sensitivity',0.85);
grupos = cell(size(centers, 1), 1);
umbral_distancia2 = 200; 

% Cada rueda se agrega las lineas rectas mas cercanas
hold on;
for i = 1:length(lines)
    for j = 1:size(centers, 1)
        distancia = norm([lines(i).point1 - centers(j,:), lines(i).point2 - centers(j,:)]);
        if distancia < umbral_distancia2
             grupos{j} = [grupos{j}; i];  
            break;
        end
    end
end

%Hasta este paso se supone que tenemos 3 circulos con cierta cantidad de
%lineas
disp(grupos);

% Dibujar círculos y líneas asociadas con colores diferentes para cada grupo
num_grupos=length(grupos);
colores = jet(num_grupos);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  4

imshow(imagen);
hold on;

%Un bucle que recorre todos los elementos
for i = 1:length(centers) 
        centro_actual = grupos{i};
        for j = i+1:length(centers)
            if ~isempty(grupos{j})
                %Calcular la distancia entre ellos,si estan lejos, se
                %dibuja el circulo y lineas
                distancia_x = abs(centro_actual(1) - centers(j,1));
                distancia_y = abs(centro_actual(2) - centers(j,2));
                distancia_total = sqrt(distancia_x^2 + distancia_y^2);            
                fprintf('Distancia total entre el centro %d y el centro %d: %f\n', i, j, distancia_total);                
                viscircles(centers(i,:), radii(i), 'EdgeColor', colores(i,:));
                for k = 1:length(grupos{i})     
                    idx = grupos{i}(k);
                    xy = [lines(idx).point1; lines(idx).point2];
                    plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', colores(i,:));
                end

                %Si haya otro circulo que esta cerca, se repite el color
                if(distancia_total<700)
                    viscircles(centers(j,:), radii(j), 'EdgeColor', colores(i,:));
                    for l = 1:length(grupos{j})     
                    idx = grupos{j}(l);
                    xy = [lines(idx).point1; lines(idx).point2];
                    plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', colores(i,:));
                    end  
                end
            end
        end        
end
hold off;







