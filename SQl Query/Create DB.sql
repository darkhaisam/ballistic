-- 1. Таблица справочников (Lookup)
CREATE TABLE Lookup (
    lookup_id SERIAL PRIMARY KEY,
    domain TEXT NOT NULL, -- тип справочника (caliber, material, manufacturer и т.д.) [cite: 21]
    code TEXT NOT NULL,
    label TEXT NOT NULL,
    description TEXT,
    UNIQUE(domain, code)
);

-- 2. Таблица источников данных (Source)
CREATE TABLE Source (
    source_id SERIAL PRIMARY KEY,
    source_name TEXT NOT NULL,
    default_classification_id INT, -- FK на Lookup [cite: 13]
    description TEXT,
    url TEXT
);

-- 3. Таблица пороха (Powder)
CREATE TABLE Powder (
    powder_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    manufacturer_id INT, -- FK на Lookup [cite: 9, 23]
    bulk_density_g_cm3 NUMERIC,
    energy_j_g NUMERIC,
    burn_rate_index NUMERIC,
    notes TEXT
);

-- 4. Таблица пуль (Bullet)
CREATE TABLE Bullet (
    bullet_id SERIAL PRIMARY KEY,
    manufacturer_id INT, -- FK на Lookup [cite: 5, 23]
    model TEXT NOT NULL,
    caliber_id INT,      -- FK на Lookup [cite: 5, 23]
    mass_grains NUMERIC,
    length_mm NUMERIC,
    diameter_mm NUMERIC,
    ogive_type_id INT,   -- FK на Lookup [cite: 5, 23]
    boat_tail_angle_deg NUMERIC,
    material_id INT,     -- FK на Lookup [cite: 5, 23]
    bc_g1 NUMERIC,
    bc_g7 NUMERIC,
    drag_curve_id INT,   -- FK на Lookup [cite: 5, 23]
    form_factor NUMERIC,
    meplat_diameter_mm NUMERIC,
    meplat_area_mm2 NUMERIC
);

-- 5. Таблица патронов (Cartridge)
CREATE TABLE Cartridge (
    cartridge_id SERIAL PRIMARY KEY,
    bullet_id INT REFERENCES Bullet(bullet_id), [cite: 7, 23]
    powder_id INT REFERENCES Powder(powder_id), [cite: 7, 23]
    manufacturer_id INT, -- FK на Lookup [cite: 7, 23]
    case_length_mm NUMERIC,
    overall_length_mm NUMERIC,
    powder_charge_grains NUMERIC,
    primer_type_id INT,  -- FK на Lookup [cite: 7, 23]
    headstamp_text TEXT,
    muzzle_velocity NUMERIC,
    temp_velocity_coeff NUMERIC,
    notes TEXT
);

-- 6. Справочные данные (ReferenceData)
CREATE TABLE ReferenceData (
    ref_id SERIAL PRIMARY KEY,
    cartridge_id INT REFERENCES Cartridge(cartridge_id), [cite: 11, 23]
    source_id INT REFERENCES Source(source_id), [cite: 11]
    date_added DATE DEFAULT CURRENT_DATE,
    country_id INT,      -- FK на Lookup [cite: 11]
    classification_id INT, -- FK на Lookup [cite: 11]
    reference_code TEXT
);

-- 7. Метаданные пуль (BulletMetadata)
CREATE TABLE BulletMetadata (
    bullet_meta_id SERIAL PRIMARY KEY,
    bullet_id INT REFERENCES Bullet(bullet_id), [cite: 15, 23]
    data_source_id INT REFERENCES Source(source_id), [cite: 15]
    data_version TEXT,
    last_updated DATE DEFAULT CURRENT_DATE,
    quality_flag_id INT,     -- FK на Lookup [cite: 15, 26]
    owner_id INT,            -- FK на Lookup [cite: 15]
    confidentiality_level_id INT, -- FK на Lookup [cite: 15, 27]
    compliance_tag_id INT,   -- FK на Lookup [cite: 15, 27]
    audit_note TEXT [cite: 15, 26]
);

-- 8. Метаданные патронов (CartridgeMetadata)
CREATE TABLE CartridgeMetadata (
    cartridge_meta_id SERIAL PRIMARY KEY,
    cartridge_id INT REFERENCES Cartridge(cartridge_id), [cite: 17, 23]
    data_source_id INT REFERENCES Source(source_id), [cite: 17]
    data_version TEXT,
    last_updated DATE DEFAULT CURRENT_DATE,
    quality_flag_id INT,
    owner_id INT,
    confidentiality_level_id INT,
    compliance_tag_id INT,
    audit_note TEXT [cite: 17, 26]
);

-- 9. Изображения (Image)
CREATE TABLE Image (
    image_id SERIAL PRIMARY KEY,
    object_type TEXT NOT NULL, -- 'bullet', 'cartridge' или 'reference' 
    object_id INT NOT NULL,    -- ID соответствующей записи 
    image_url TEXT NOT NULL,
    image_kind_id INT,         -- FK на Lookup [cite: 19]
    captured_at DATE,
    captured_by_id INT,        -- FK на Lookup [cite: 19]
    license_id INT,            -- FK на Lookup [cite: 19]
    hash_sha256 TEXT [cite: 19]
);