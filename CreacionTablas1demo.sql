-- ============================================================================
-- SCRIPT COMPLETO: CREACIÓN, POBLADO AUTOMÁTICO Y VALIDACIÓN DE DATOS CHILENOS
-- ============================================================================
-- Descripción: Este archivo crea una estructura de tabla automatizada bajo 6 
--              reglas de negocio estrictas y puebla 1000 registros aleatorios
--              con identidad chilena, asegurando la integridad de los datos.
-- ============================================================================

-------------------------------------------------------------------------------
-- PASO 1: LIMPIEZA DE ENTORNO (Opcional)
-------------------------------------------------------------------------------
-- Borra la tabla si ya existía para permitir una ejecución limpia desde cero.
DROP TABLE IF EXISTS usuarios_chile;

-------------------------------------------------------------------------------
-- PASO 2: CREACIÓN DE LA TABLA Y APLICACIÓN DE REGLAS DE NEGOCIO
-------------------------------------------------------------------------------
-- Aquí se define la estructura solicitada en los ejemplos y se fuerza al 
-- motor de la base de datos a rechazar cualquier registro que rompa las reglas.

CREATE TABLE usuarios_chile (
    -- Identificador único autoincremental para control interno
    id SERIAL PRIMARY KEY,
    
    -- Regla 1: El nombre es obligatorio.
    nombre VARCHAR(100) NOT NULL, 
    
    -- Regla 2: La edad debe estar entre 0 y 120 años.
    edad INT CHECK (edad BETWEEN 0 AND 120), 
    
    -- Regla 3: El correo debe contener el carácter @.
    correo VARCHAR(150) CHECK (correo LIKE '%@%'), 
    
    -- Regla 4: El teléfono debe tener exactamente 9 dígitos.
    -- Se usa una Expresión Regular (~ '^[0-9]{9}$') para asegurar que sean SOLO números.
    telefono CHAR(9) CHECK (telefono ~ '^[0-9]{9}$'), 
    
    -- Regla 5: La ciudad es obligatoria.
    ciudad VARCHAR(100) NOT NULL, 
    
    -- Regla 6: La fecha de nacimiento no puede ser futura (Menor o igual a la fecha de hoy).
    fecha_nacimiento DATE CHECK (fecha_nacimiento <= CURRENT_DATE) 
);

COMMENT ON TABLE usuarios_chile IS 'Tabla de usuarios con validaciones de negocio estrictas para el mercado chileno.';


-------------------------------------------------------------------------------
-- PASO 3: BLOQUE ANÓNIMO PL/pgSQL PARA GENERAR 1000 REGISTROS ALEATORIOS
-------------------------------------------------------------------------------
-- Explicación del proceso:
-- 1. Se definen "piscinas" (arrays) con nombres, apellidos y comunas reales de Chile.
-- 2. Un ciclo FOR se repite exactamente 1000 veces.
-- 3. En cada iteración se escoge un nombre, apellido y ciudad al azar.
-- 4. Para evitar inconsistencias, la fecha de nacimiento se calcula hacia atrás en el pasado
--    y la edad se deriva matemáticamente de esa fecha, cumpliendo las Reglas 2 y 6 de forma lógica.
-- 5. Se arma un correo electrónico válido usando el nombre y apellido procesado.
-- 6. Se genera un número celular chileno válido de 9 dígitos comenzando con el prefijo 9.

DO $$
DECLARE
    -- Arreglos de datos con fuerte identidad chilena
    nombres text[] := ARRAY['Juan', 'María', 'Pedro', 'Diego', 'Francisca', 'Javiera', 'Camila', 'Gonzalo', 'Felipe', 'Valentina', 'Matías', 'Constanza', 'Sebastián', 'Antonia', 'Nicolás', 'Sofía', 'José', 'Luis', 'Ana', 'Carlos', 'Gabriel', 'Daniela', 'Benjamín', 'Bastián', 'Ignacio', 'Claudio', 'Paulina', 'Andrés'];
    apellidos text[] := ARRAY['Pérez', 'Soto', 'González', 'Muñoz', 'Rojas', 'Díaz', 'Silva', 'Contreras', 'Olivares', 'Flores', 'Morales', 'Sanhueza', 'Vergara', 'Tapia', 'Araya', 'López', 'Rodríguez', 'Martínez', 'Sepúlveda', 'Carvajal', 'Fuentes', 'Cárcamo'];
    ciudades text[] := ARRAY['Santiago', 'Valparaíso', 'Concepción', 'La Serena', 'Antofagasta', 'Temuco', 'Rancagua', 'Talca', 'Iquique', 'Puerto Montt', 'Chillán', 'Arica', 'Copiapó', 'Quillota', 'Curicó', 'Punta Arenas', 'Calama', 'Osorno'];
    
    -- Variables temporales para construir cada registro
    i int;
    rand_fnac date;
    rand_edad int;
    rand_nom text;
    rand_ape text;
    rand_email text;
    rand_tel text;
    rand_ciu text;
BEGIN
    FOR i IN 1..1000 LOOP
        -- 1. Selección aleatoria de elementos desde los arreglos
        rand_nom := nombres[floor(random() * array_length(nombres, 1) + 1)];
        rand_ape := apellidos[floor(random() * array_length(apellidos, 1) + 1)];
        rand_ciu := ciudades[floor(random() * array_length(ciudades, 1) + 1)];
        
        -- 2. Cálculo lógico de Fecha y Edad (Reglas 2 y 6)
        -- Genera un intervalo de días al azar en el pasado (entre ~18 y ~80 años atrás)
        rand_fnac := CURRENT_DATE - (floor(random() * 22645) + 6574)::int; 
        -- Calcula la edad exacta basándose en la fecha de nacimiento generada
        rand_edad := EXTRACT(YEAR FROM AGE(CURRENT_DATE, rand_fnac));
        
        -- 3. Construcción del Email (Regla 3)
        -- Combina nombre, apellido, un número aleatorio y el dominio para asegurar el caracter '@'
        rand_email := lower(rand_nom) || '.' || lower(rand_ape) || floor(random() * 99)::text || '@gmail.com';
        
        -- 4. Generación del Teléfono Móvil Chileno (Regla 4)
        -- Los móviles en Chile tienen 9 dígitos y comienzan con 9 (Ej: 9XXXXXXXX).
        -- Generamos un número aleatorio entre 900.000.000 y 999.999.999.
        rand_tel := (900000000 + floor(random() * 100000000))::text;

        -- 5. Inserción oficial en la base de datos
        INSERT INTO usuarios_chile (nombre, edad, correo, telefono, ciudad, fecha_nacimiento)
        VALUES (rand_nom || ' ' || rand_ape, rand_edad, rand_email, rand_tel, rand_ciu, rand_fnac);
    END LOOP;
END $$;


-------------------------------------------------------------------------------
-- PASO 4: PRUEBAS DE COMPORTAMIENTO (Validación de Reglas de Negocio)
-------------------------------------------------------------------------------
-- Las siguientes consultas demuestran cómo responde la estructura ante 
-- los registros de prueba provistos en el requerimiento.

-- [REGISTRO DE PRUEBA 1]: ÉXITO SEGURO
-- Cumple absolutamente todas las condiciones exigidas. Se insertará sin problemas.
INSERT INTO usuarios_chile (nombre, edad, correo, telefono, ciudad, fecha_nacimiento)
VALUES ('Juan Pérez', 35, 'juan@gmail.com', '987654321', 'Santiago', '1990-05-10');


-- [REGISTRO DE PRUEBA 2]: ERROR ESPERADO
-- Explicación del fallo: Este INSERT fallará de inmediato y será cancelado por el motor de BD.
-- Rompe tres reglas simultáneamente: Edad negativa (-5), correo sin '@' y teléfono de 5 dígitos.
-- DESCOMENTA LA LÍNEA DE ABAJO SI DESEAS VER EL ERROR EN CONSOLA:
-- INSERT INTO usuarios_chile (nombre, edad, correo, telefono, ciudad, fecha_nacimiento) VALUES ('María Soto', -5, 'mariagmail.com', '12345', 'Valparaíso', '2030-01-01');


-- [REGISTRO DE PRUEBA 3]: ERROR ESPERADO
-- Explicación del fallo: El motor detendrá la ejecución debido a que 'nombre' y 'ciudad' 
-- tienen la restricción NOT NULL (Obligatorios) y se están enviando vacíos (NULL).
-- DESCOMENTA LA LÍNEA DE ABAJO SI DESEAS VER EL ERROR EN CONSOLA:
-- INSERT INTO usuarios_chile (nombre, edad, correo, telefono, ciudad, fecha_nacimiento) VALUES (NULL, 28, 'pedro@hotmail.com', '912345678', NULL, '1997-03-15');


-------------------------------------------------------------------------------
-- PASO 5: CONSULTA DE VERIFICACIÓN
-------------------------------------------------------------------------------
-- Muestra el total de datos guardados y una pequeña muestra para verificar el resultado.

SELECT 'Total de registros exitosos en la tabla: ' || COUNT(*) FROM usuarios_chile;

SELECT id, nombre, edad, correo, telefono, ciudad, fecha_nacimiento 
FROM usuarios_chile 
ORDER BY id ASC 
LIMIT 10;
