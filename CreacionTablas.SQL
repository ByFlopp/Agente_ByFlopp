CREATE TABLE usuarios_chile (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL, -- Regla 1: Obligatorio
    edad INT CHECK (edad BETWEEN 0 AND 120), -- Regla 2: Entre 0 y 120 años
    correo VARCHAR(150) CHECK (correo LIKE '%@%'), -- Regla 3: Debe contener @
    telefono CHAR(9) CHECK (telefono ~ '^[0-9]{9}$'), -- Regla 4: Exactamente 9 dígitos numéricos
    ciudad VARCHAR(100) NOT NULL, -- Regla 5: Obligatoria
    fecha_nacimiento DATE CHECK (fecha_nacimiento <= CURRENT_DATE) -- Regla 6: No futura
);
