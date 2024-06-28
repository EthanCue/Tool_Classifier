clc;
clear all;
close all;
warning off all;

% Directorio de imágenes de entrenamiento
directorio_entrenamiento = 'Imagenes';
archivos = dir(fullfile(directorio_entrenamiento, '*.bmp'));

% Inicialización de variables
num_momentos_hu = 7; % Número de momentos de Hu
imagenes_binarias_entrenamiento = cell(1, numel(archivos));
caracteristicas_entrenamiento = cell(1, numel(archivos));

% Función para calcular los momentos de Hu
function momentos = hu_moments(objeto)
    [rows, cols] = find(objeto);
    x = rows - mean(rows);
    y = cols - mean(cols);

    momento_central = @(p, q) sum((x.^p) .* (y.^q));
    n = @(p, q) ((p + q) / 2) + 1;
    phi = @(p, q) momento_central(p, q) / (momento_central(0, 0) ^ n(p, q));

    momentos = zeros(1, 7);
    momentos(1) = phi(2, 0) + phi(0, 2);
    momentos(2) = (phi(2, 0) - phi(0, 2))^2 + (4 * phi(1, 1))^2;
    momentos(3) = (phi(3, 0) - 3 * phi(1, 2))^2 + (3 * phi(2, 1) - phi(0, 3))^2;
    momentos(4) = (phi(3, 0) + phi(1, 2))^2 + (phi(2, 1) + phi(0, 3))^2;
    momentos(5) = (phi(3, 0) - 3 * phi(1, 2)) * (phi(3, 0) + phi(1, 2)) * ((phi(3, 0) + phi(1, 2))^2 - 3 * (phi(2, 1) + phi(0, 3))^2) + (3 * phi(2, 1) - phi(0, 3)) * (phi(2, 1) + phi(0, 3)) * (3 * (phi(3, 0) + phi(1, 2))^2 - (phi(2, 1) + phi(0, 3))^2);
    momentos(6) = (phi(2, 0) - phi(0, 2)) * ((phi(3, 0) + phi(1, 2))^2 - (phi(2, 1) + phi(0, 3))^2) + 4 * phi(1, 1) * (phi(3, 0) + phi(1, 2)) * (phi(2, 1) + phi(0, 3));
    momentos(7) = (3 * phi(2, 1) - phi(0, 3)) * (phi(3, 0) + phi(1, 2)) * ((phi(3, 0) + phi(1, 2))^2 - 3 * (phi(2, 1) + phi(0, 3))^2) - (phi(3, 0) - 3 * phi(1, 2)) * (phi(2, 1) + phi(0, 3)) * (3 * (phi(3, 0) + phi(1, 2))^2 - (phi(2, 1) + phi(0, 3))^2);
end

% Procesamiento de imágenes de entrenamiento
for i = 1:numel(archivos)
    nombre_archivo = fullfile(directorio_entrenamiento, archivos(i).name);
    imagen = imread(nombre_archivo);
    imagen_binaria = imbinarize(imagen);
    imagen_binaria = bwareaopen(imagen_binaria, 50); % Eliminar objetos pequeños
    imagenes_binarias_entrenamiento{i} = imagen_binaria;
    caracteristicas = regionprops(imagen_binaria, 'Area', 'Perimeter', 'Centroid', 'Image');
    for j = 1:numel(caracteristicas)
        caracteristicas(j).HuMoments = hu_moments(caracteristicas(j).Image);
    end
    caracteristicas_entrenamiento{i} = caracteristicas;
end

% Mostrar imágenes binarias
figure;
for i = 1:numel(imagenes_binarias_entrenamiento)
    subplot(1, numel(imagenes_binarias_entrenamiento), i);
    imshow(imagenes_binarias_entrenamiento{i});
    title(['Imagen binaria ', num2str(i)]);
end

% Mostrar características de los objetos
for i = 1:numel(caracteristicas_entrenamiento)
    disp(['Características de la imagen ', num2str(i)]);
    for j = 1:numel(caracteristicas_entrenamiento{i})
        disp(['  Área: ', num2str(caracteristicas_entrenamiento{i}(j).Area)]);
        disp(['  Perímetro: ', num2str(caracteristicas_entrenamiento{i}(j).Perimeter)]);
        disp(['  Centroide: ', num2str(caracteristicas_entrenamiento{i}(j).Centroid)]);
        disp(['  Hu Moments: ', num2str(caracteristicas_entrenamiento{i}(j).HuMoments)]);
    end
end

% Crear archivo de texto con las características
archivo_txt = fopen('caracteristicas.txt', 'w');
for i = 1:numel(caracteristicas_entrenamiento)
    num_objetos = numel(caracteristicas_entrenamiento{i});
    for j = 1:num_objetos
        cadena = sprintf('Imagen%d_%d: (Area: %.2f, Perimetro: %.2f, Centroide: (%.2f, %.2f), HuMoments: [%.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f])\n', ...
            i, j, ...
            caracteristicas_entrenamiento{i}(j).Area, ...
            caracteristicas_entrenamiento{i}(j).Perimeter, ...
            caracteristicas_entrenamiento{i}(j).Centroid(1), ...
            caracteristicas_entrenamiento{i}(j).Centroid(2), ...
            caracteristicas_entrenamiento{i}(j).HuMoments);
        fprintf(archivo_txt, cadena);
    end
end
fclose(archivo_txt);

% Graficar características
figure;
hold on;
grid on;
xlabel('Área');
ylabel('Perímetro');
zlabel('Coordenada Y del Centroide');

for i = 1:numel(caracteristicas_entrenamiento)
    num_objetos = numel(caracteristicas_entrenamiento{i});
    areas = zeros(1, num_objetos);
    perimetros = zeros(1, num_objetos);
    centroides_y = zeros(1, num_objetos);
    for j = 1:num_objetos
        areas(j) = caracteristicas_entrenamiento{i}(j).Area;
        perimetros(j) = caracteristicas_entrenamiento{i}(j).Perimeter;
        centroides_y(j) = caracteristicas_entrenamiento{i}(j).Centroid(2);
    end
    scatter3(areas, perimetros, centroides_y, 'filled');
end
legend('Imagen 1', 'Imagen 2', 'Imagen 3', 'Imagen 4', 'Imagen 5', 'Imagen 6');
title('Características de los objetos en las imágenes de entrenamiento');

% Concatenar características de todas las imágenes
caracteristicas_concatenadas = [];
for i = 1:numel(caracteristicas_entrenamiento)
    for j = 1:numel(caracteristicas_entrenamiento{i})
        caracteristicas_concatenadas = [caracteristicas_concatenadas; ...
            caracteristicas_entrenamiento{i}(j).Area, ...
            caracteristicas_entrenamiento{i}(j).Perimeter, ...
            caracteristicas_entrenamiento{i}(j).Centroid(2)];
    end
end

% Aplicar k-means para clasificar en 6 clases
num_clases = 6;
[idx, centroids] = kmeans(caracteristicas_concatenadas, num_clases);

% Visualizar los resultados
figure;
scatter3(caracteristicas_concatenadas(:,1), caracteristicas_concatenadas(:,2), caracteristicas_concatenadas(:,3), 20, idx, 'filled');
hold on;
scatter3(centroids(:,1), centroids(:,2), centroids(:,3), 200, (1:num_clases)', 'filled', 'MarkerEdgeColor', 'k');
xlabel('Área');
ylabel('Perímetro');
zlabel('Centroide');
title('Agrupamiento de características utilizando k-means');
legend('Datos agrupados', 'Centroides');
hold off;

% Nombres de las clases
nombres_clases = {'Rondana', 'Rondana con solapa', 'Tornillo', 'Tornillo con cabeza hexagonal', 'Tornillo con cabeza de cruz', 'Tuerca'};

% Guardar vectores de características por clase
vectores_por_clase = cell(num_clases, 1);
for k = 1:num_clases
    vectores_k = caracteristicas_concatenadas(idx == k, :);
    vectores_por_clase{k} = vectores_k;
end

nombre_archivo = 'caracteristicas_por_clase.txt';
fid = fopen(nombre_archivo, 'w');
if fid == -1
    error('No se pudo abrir el archivo para escribir.');
end

for k = 1:num_clases
    fprintf(fid, '%s:\n', nombres_clases{k});
    vectores_k = vectores_por_clase{k};
    for i = 1:size(vectores_k, 1)
        fprintf(fid, '%d: (%.2f, %.2f, %.2f)\n', i, vectores_k(i, 1), vectores_k(i, 2), vectores_k(i, 3));
    end
    fprintf(fid, '\n');
end
fclose(fid);
disp('Vectores de características por clase guardados en el archivo caracteristicas_por_clase.txt.');

% Clasificación de nuevas imágenes
while true
    nombre_imagen = input('Ingrese el nombre de la imagen (sin extensión): ', 's');
    nombre_archivo = [nombre_imagen, '.bmp'];
    imagen = imread(fullfile('test_images', nombre_archivo));
    imagen_binaria = imbinarize(imagen);
    imagen_binaria = bwareaopen(imagen_binaria, 50); % Eliminar objetos pequeños
    caracteristicas_imagen = regionprops(imagen_binaria, 'Area', 'Perimeter', 'Centroid', 'Image');
    for j = 1:numel(caracteristicas_imagen)
        caracteristicas_imagen(j).HuMoments = hu_moments(caracteristicas_imagen(j).Image);
    end

    num_objetos = numel(caracteristicas_imagen);
    features_objetos = zeros(num_objetos, 3); % Ajustar a 3 columnas
    for i = 1:num_objetos
        features_objetos(i, :) = [caracteristicas_imagen(i).Area, caracteristicas_imagen(i).Perimeter, caracteristicas_imagen(i).Centroid(2)];
    end

    disp('Matriz de características de los objetos en la imagen:');
    disp(features_objetos);

    % Verificar que el número de objetos sea mayor que el número de clusters
    if num_objetos >= num_clases
        % Clasificación de los objetos utilizando k-means y los centroides
        idx_clases = kmeans(features_objetos, num_clases, 'Start', centroids);

        % Verificación de similitud con las clases existentes
        distancias = pdist2(features_objetos, centroids);
        [min_distancias, ~] = min(distancias, [], 2);

        % Definir un umbral de similitud (esto puede ajustarse según los datos)
        umbral_similitud = 70.0;

        disp('Clasificación de objetos en la imagen:');
        for i = 1:num_objetos
            if min_distancias(i) < umbral_similitud
                fprintf('Objeto %d: %s\n', i, nombres_clases{idx_clases(i)});
            else
                fprintf('Objeto %d: No se puede clasificar, es muy diferente a las clases de entrenamiento\n', i);
            end
        end

        % Contar la cantidad de objetos por clase
        contador_clases = zeros(1, num_clases);
        for i = 1:num_objetos
            if min_distancias(i) < umbral_similitud
                contador_clases(idx_clases(i)) = contador_clases(idx_clases(i)) + 1;
            end
        end

        disp('Cantidad de objetos por clase:');
        for k = 1:num_clases
            fprintf('%s: %d\n', nombres_clases{k}, contador_clases(k));
        end
    else
        disp('Error: El número de objetos en la imagen es menor que el número de clusters.');
    end

    respuesta = input('¿Desea clasificar otra imagen? (s/n): ', 's');
    if ~strcmpi(respuesta, 's')
        disp('Programa terminado.');
        break;
    end
end
