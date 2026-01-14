-- =========================================
-- 0. Инициализация
-- =========================================
-- Рекомендуемая кодировка: UTF-8
-- Рекомендуемая схема: public

-- =========================================
-- 1. Справочники и источники
-- =========================================

CREATE TABLE lookup (
  lookup_id       BIGSERIAL PRIMARY KEY,
  domain          TEXT NOT NULL,           -- например: 'manufacturer','caliber','source_type','jurisdiction','status','compliance_tag','compliance_level'
  code            TEXT NOT NULL,
  label           TEXT NOT NULL,
  description     TEXT,
  UNIQUE(domain, code)
);

CREATE INDEX idx_lookup_domain ON lookup(domain);

CREATE TABLE source (
  source_id                    BIGSERIAL PRIMARY KEY,
  source_name                  TEXT NOT NULL,
  default_classification_id    BIGINT REFERENCES lookup(lookup_id),
  description                  TEXT,
  url                          TEXT,
  -- Расширения для учёта стандартов РФ/РБ и международных
  source_type                  BIGINT REFERENCES lookup(lookup_id), -- GOST/STB/TU/OST/SAAMI/CIP/AB/IATG/Manufacturer/Other
  standard_number              TEXT,                                -- например, 'ГОСТ 12345-2015'
  standard_year                INT,
  status                       BIGINT REFERENCES lookup(lookup_id), -- active/replaced/withdrawn
  jurisdiction                 BIGINT REFERENCES lookup(lookup_id)  -- RU/BY/EAEU/INT
);

CREATE INDEX idx_source_type ON source(source_type);
CREATE INDEX idx_source_jurisdiction ON source(jurisdiction);

-- Таблица тегов соответствия (если нужен N:M)
CREATE TABLE compliance_tag (
  tag_id       BIGSERIAL PRIMARY KEY,
  tag_key      TEXT NOT NULL UNIQUE,       -- например, 'GOST','STB','EAEU','SAAMI','CIP','IATG'
  label        TEXT NOT NULL,
  description  TEXT
);

-- =========================================
-- 2. Порох (Powder) — отдельная сущность
-- =========================================

CREATE TABLE powder (
  powder_id            BIGSERIAL PRIMARY KEY,
  name                 TEXT NOT NULL,
  manufacturer_id      BIGINT REFERENCES lookup(lookup_id),
  bulk_density_g_cm3   NUMERIC(8,5) CHECK (bulk_density_g_cm3 > 0),
  energy_j_g           NUMERIC(12,4) CHECK (energy_j_g >= 0),
  burn_rate_index      NUMERIC(8,4),
  notes                TEXT,
  -- Расширения для ГОСТ/СТБ/ТУ
  designation          TEXT,               -- марка пороха (например, 'Сокол')
  lot_number           TEXT,               -- номер партии
  standard_ref         TEXT,               -- краткая ссылка на стандарт/ТУ
  UNIQUE (manufacturer_id, name)
);

CREATE INDEX idx_powder_name ON powder(name);
CREATE INDEX idx_powder_manufacturer ON powder(manufacturer_id);

-- =========================================
-- 3. Пули (Bullet)
-- =========================================

CREATE TABLE bullet (
  bullet_id            BIGSERIAL PRIMARY KEY,
  manufacturer_id      BIGINT NOT NULL REFERENCES lookup(lookup_id),
  model                TEXT NOT NULL,
  caliber_id           BIGINT NOT NULL REFERENCES lookup(lookup_id),
  mass_grains          NUMERIC(10,4) NOT NULL CHECK (mass_grains > 0),
  length_mm            NUMERIC(10,4) CHECK (length_mm > 0),
  diameter_mm          NUMERIC(10,4) CHECK (diameter_mm > 0),
  ogive_type_id        BIGINT REFERENCES lookup(lookup_id),
  boat_tail_angle_deg  NUMERIC(6,3) CHECK (boat_tail_angle_deg >= 0),
  material_id          BIGINT REFERENCES lookup(lookup_id),
  bc_g1                NUMERIC(8,6) CHECK (bc_g1 > 0),
  bc_g7                NUMERIC(8,6) CHECK (bc_g7 > 0),
  drag_curve_id        BIGINT REFERENCES lookup(lookup_id),
  form_factor          NUMERIC(8,4) CHECK (form_factor > 0),
  -- Меплат (носик) для методологии Литца
  meplat_diameter_mm   NUMERIC(8,4) CHECK (meplat_diameter_mm >= 0),
  meplat_area_mm2      NUMERIC(10,4) CHECK (meplat_area_mm2 >= 0),
  created_at           TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at           TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE (manufacturer_id, model, caliber_id)
);

CREATE INDEX idx_bullet_manufacturer ON bullet(manufacturer_id);
CREATE INDEX idx_bullet_caliber ON bullet(caliber_id);
CREATE INDEX idx_bullet_model ON bullet(model);

-- =========================================
-- 4. Патроны (Cartridge)
-- =========================================

CREATE TABLE cartridge (
  cartridge_id         BIGSERIAL PRIMARY KEY,
  bullet_id            BIGINT NOT NULL REFERENCES bullet(bullet_id) ON DELETE RESTRICT,
  powder_id            BIGINT REFERENCES powder(powder_id),
  manufacturer_id      BIGINT REFERENCES lookup(lookup_id),
  case_length_mm       NUMERIC(10,4) CHECK (case_length_mm > 0),
  overall_length_mm    NUMERIC(10,4) CHECK (overall_length_mm > 0),
  powder_charge_grains NUMERIC(10,4) CHECK (powder_charge_grains >= 0),
  primer_type_id       BIGINT REFERENCES lookup(lookup_id),
  headstamp_text       TEXT,
  muzzle_velocity      NUMERIC(10,4) CHECK (muzzle_velocity >= 0),
  temp_velocity_coeff  NUMERIC(10,6), -- м/с на °C (может быть положительным или отрицательным)
  -- Расширения для стандартов (давление и допуски)
  pressure_limit_mpa   NUMERIC(10,4) CHECK (pressure_limit_mpa >= 0),
  dimension_tolerance_note TEXT,
  notes                TEXT,
  created_at           TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at           TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_cartridge_bullet ON cartridge(bullet_id);
CREATE INDEX idx_cartridge_powder ON cartridge(powder_id);
CREATE INDEX idx_cartridge_headstamp ON cartridge(headstamp_text);

-- Настройка поведения FK для powder (оставляем запись патрона при удалении пороха)
ALTER TABLE cartridge
  DROP CONSTRAINT IF EXISTS cartridge_powder_id_fkey;

ALTER TABLE cartridge
  ADD CONSTRAINT cartridge_powder_id_fkey FOREIGN KEY (powder_id)
  REFERENCES powder(powder_id) ON DELETE SET NULL;

-- =========================================
-- 5. Справочные записи (ReferenceData)
-- =========================================

CREATE TABLE reference_data (
  ref_id               BIGSERIAL PRIMARY KEY,
  cartridge_id         BIGINT NOT NULL REFERENCES cartridge(cartridge_id) ON DELETE CASCADE,
  source_id            BIGINT NOT NULL REFERENCES source(source_id),
  date_added           DATE NOT NULL DEFAULT CURRENT_DATE,
  country_id           BIGINT REFERENCES lookup(lookup_id),
  classification_id    BIGINT REFERENCES lookup(lookup_id),
  reference_code       TEXT,
  notes                TEXT,
  -- Расширения для стандартов и соответствия
  standard_ref         TEXT,               -- краткая ссылка на стандарт
  compliance_level     BIGINT REFERENCES lookup(lookup_id) -- declared/assessed/verified
);

CREATE INDEX idx_ref_cartridge ON reference_data(cartridge_id);
CREATE INDEX idx_ref_source ON reference_data(source_id);

-- =========================================
-- 6. Метаданные и аудит
-- =========================================

CREATE TABLE bullet_metadata (
  bullet_meta_id           BIGSERIAL PRIMARY KEY,
  bullet_id                BIGINT NOT NULL REFERENCES bullet(bullet_id) ON DELETE CASCADE,
  data_source_id           BIGINT REFERENCES source(source_id),
  data_version             TEXT NOT NULL DEFAULT 'v1.0',
  last_updated             TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  quality_flag_id          BIGINT REFERENCES lookup(lookup_id),
  owner_id                 BIGINT REFERENCES lookup(lookup_id),
  confidentiality_level_id BIGINT REFERENCES lookup(lookup_id),
  compliance_tag_id        BIGINT REFERENCES compliance_tag(tag_id),
  audit_note               TEXT,
  -- Расширения для governance
  audit_trail              TEXT,           -- JSON/TEXT для истории изменений
  version_status           BIGINT REFERENCES lookup(lookup_id) -- draft/needs_review/verified
);

CREATE INDEX idx_bullet_meta_bullet ON bullet_metadata(bullet_id);

CREATE TABLE cartridge_metadata (
  cartridge_meta_id        BIGSERIAL PRIMARY KEY,
  cartridge_id             BIGINT NOT NULL REFERENCES cartridge(cartridge_id) ON DELETE CASCADE,
  data_source_id           BIGINT REFERENCES source(source_id),
  data_version             TEXT NOT NULL DEFAULT 'v1.0',
  last_updated             TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  quality_flag_id          BIGINT REFERENCES lookup(lookup_id),
  owner_id                 BIGINT REFERENCES lookup(lookup_id),
  confidentiality_level_id BIGINT REFERENCES lookup(lookup_id),
  compliance_tag_id        BIGINT REFERENCES compliance_tag(tag_id),
  audit_note               TEXT,
  -- Расширения для governance
  audit_trail              TEXT,
  version_status           BIGINT REFERENCES lookup(lookup_id)
);

CREATE INDEX idx_cartridge_meta_cartridge ON cartridge_metadata(cartridge_id);

-- Аудитные таблицы (рекомендуется для полной истории)
CREATE TABLE bullet_audit (
  audit_id      BIGSERIAL PRIMARY KEY,
  bullet_id     BIGINT NOT NULL,
  changed_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  changed_by    BIGINT, -- ссылка на lookup.owner или user_id в другой системе
  change_type   TEXT,   -- INSERT/UPDATE/DELETE
  change_set    JSONB
);

CREATE TABLE cartridge_audit (
  audit_id      BIGSERIAL PRIMARY KEY,
  cartridge_id  BIGINT NOT NULL,
  changed_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  changed_by    BIGINT,
  change_type   TEXT,
  change_set    JSONB
);

-- =========================================
-- 7. Изображения (полиморфная связь)
-- =========================================

CREATE TABLE image (
  image_id        BIGSERIAL PRIMARY KEY,
  object_type     TEXT NOT NULL CHECK (object_type IN ('bullet','cartridge','reference')),
  object_id       BIGINT NOT NULL,
  image_url       TEXT NOT NULL,
  image_kind_id   BIGINT REFERENCES lookup(lookup_id),
  captured_at     TIMESTAMP WITH TIME ZONE,
  captured_by_id  BIGINT REFERENCES lookup(lookup_id),
  license_id      BIGINT REFERENCES lookup(lookup_id),
  hash_sha256     CHAR(64),
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_image_object ON image(object_type, object_id);

-- Примечание: проверка корректности object_id относительно object_type реализуется на уровне приложения или триггерами.

-- =========================================
-- 8. Таблицы соответствия (N:M) для compliance
-- =========================================

CREATE TABLE bullet_compliance (
  bullet_id   BIGINT NOT NULL REFERENCES bullet(bullet_id) ON DELETE CASCADE,
  tag_id      BIGINT NOT NULL REFERENCES compliance_tag(tag_id) ON DELETE CASCADE,
  PRIMARY KEY (bullet_id, tag_id)
);

CREATE TABLE cartridge_compliance (
  cartridge_id BIGINT NOT NULL REFERENCES cartridge(cartridge_id) ON DELETE CASCADE,
  tag_id       BIGINT NOT NULL REFERENCES compliance_tag(tag_id) ON DELETE CASCADE,
  PRIMARY KEY (cartridge_id, tag_id)
);

-- =========================================
-- 9. Ограничения, индексы и триггеры удобства
-- =========================================

-- Дополнительные CHECK для BC
ALTER TABLE bullet
  ADD CONSTRAINT chk_bc_values CHECK (
    (bc_g1 IS NULL OR bc_g1 > 0) AND
    (bc_g7 IS NULL OR bc_g7 > 0)
  );

-- Триггеры обновления updated_at для bullet и cartridge
CREATE OR REPLACE FUNCTION trg_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bullet_updated_at
BEFORE UPDATE ON bullet
FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();

CREATE TRIGGER trg_cartridge_updated_at
BEFORE UPDATE ON cartridge
FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();

-- =========================================
-- 10. Резюме поведения FK
-- =========================================
-- bullet -> cartridge: ON DELETE RESTRICT (не удалять пулю, если есть патроны)
-- cartridge -> reference_data: ON DELETE CASCADE (удаление патрона удаляет справочные записи)
-- bullet -> bullet_metadata: ON DELETE CASCADE
-- cartridge -> cartridge_metadata: ON DELETE CASCADE
-- powder -> cartridge: ON DELETE SET NULL (если порох удалён, оставить запись патрона, но без ссылки)
-- image -> объект: удаление изображений при удалении объекта — на уровне приложения/триггеров

-- =========================================
-- Конец DDL
-- =========================================