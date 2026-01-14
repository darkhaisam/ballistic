-- Источники стандартов
INSERT INTO lookup (domain, code, label, description) VALUES
('source_type','GOST','ГОСТ','Государственный стандарт РФ'),
('source_type','STB','СТБ','Стандарт Беларуси'),
('source_type','TU','ТУ','Технические условия'),
('source_type','OST','ОСТ','Отраслевой стандарт'),
('source_type','SAAMI','SAAMI','Sporting Arms and Ammunition Manufacturers’ Institute'),
('source_type','CIP','CIP','Commission Internationale Permanente'),
('source_type','AB','AppliedBallistics','Applied Ballistics доплер‑данные'),
('source_type','IATG','IATG','International Ammunition Technical Guidelines'),
('source_type','Manufacturer','Manufacturer','Производитель'),
('source_type','Other','Other','Прочие источники');

-- Юрисдикции
INSERT INTO lookup (domain, code, label, description) VALUES
('jurisdiction','RU','Россия','Российская Федерация'),
('jurisdiction','BY','Беларусь','Республика Беларусь'),
('jurisdiction','EAEU','ЕАЭС','Евразийский экономический союз'),
('jurisdiction','INT','International','Международные стандарты');

-- Статусы стандартов
INSERT INTO lookup (domain, code, label, description) VALUES
('status','active','Действует','Стандарт актуален'),
('status','replaced','Заменён','Заменён новым стандартом'),
('status','withdrawn','Отменён','Более не применяется');

-- Метки соответствия
INSERT INTO lookup (domain, code, label, description) VALUES
('compliance_tag','GOST','ГОСТ','Соответствие ГОСТ'),
('compliance_tag','STB','СТБ','Соответствие СТБ'),
('compliance_tag','EAEU','ЕАЭС','Соответствие ЕАЭС'),
('compliance_tag','SAAMI','SAAMI','Соответствие SAAMI'),
('compliance_tag','CIP','CIP','Соответствие CIP'),
('compliance_tag','IATG','IATG','Соответствие IATG');

-- Уровень соответствия
INSERT INTO lookup (domain, code, label, description) VALUES
('compliance_level','declared','Заявлено','Соответствие заявлено'),
('compliance_level','assessed','Оценено','Соответствие оценено'),
('compliance_level','verified','Проверено','Соответствие подтверждено');

-- Статусы качества
INSERT INTO lookup (domain, code, label, description) VALUES
('quality_flag','draft','Черновик','Запись в черновике'),
('quality_flag','needs_review','На проверке','Запись требует проверки'),
('quality_flag','verified','Проверено','Запись проверена');

-- Уровни конфиденциальности
INSERT INTO lookup (domain, code, label, description) VALUES
('confidentiality_level','public','Публичный','Доступен всем'),
('confidentiality_level','restricted','Ограниченный','Доступ ограничен'),
('confidentiality_level','confidential','Конфиденциальный','Только для доверенных пользователей');

-- Статусы версии
INSERT INTO lookup (domain, code, label, description) VALUES
('version_status','draft','Черновик','Черновая версия'),
('version_status','needs_review','На проверке','Версия требует проверки'),
('version_status','verified','Проверено','Версия утверждена');

-- Типы оживала
INSERT INTO lookup (domain, code, label, description) VALUES
('ogive_type','tangent','Tangent','Тангенциальное оживало'),
('ogive_type','secant','Secant','Секантное оживало'),
('ogive_type','hybrid','Hybrid','Гибридное оживало');

-- Типы капсюлей
INSERT INTO lookup (domain, code, label, description) VALUES
('primer_type','boxer','Boxer','Капсюль типа Boxer'),
('primer_type','berdan','Berdan','Капсюль типа Berdan');

-- Материалы пуль
INSERT INTO lookup (domain, code, label, description) VALUES
('material','lead','Lead','Свинец'),
('material','copper','Copper','Медь'),
('material','steel','Steel','Сталь'),
('material','brass','Brass','Латунь'),
('material','composite','Composite','Композит');

-- Калибры (примерный набор)
INSERT INTO lookup (domain, code, label, description) VALUES
('caliber','9x19','9x19mm','9×19 мм Парабеллум'),
('caliber','7.62x39','7.62x39mm','7.62×39 мм'),
('caliber','7.62x54R','7.62x54R','7.62×54 мм R'),
('caliber','5.45x39','5.45x39mm','5.45×39 мм'),
('caliber','5.56x45','5.56x45mm','5.56×45 мм NATO'),
('caliber','308Win','.308 Winchester','7.62×51 мм NATO'),
('caliber','300BLK','.300 Blackout','7.62×35 мм'),
('caliber','338LM','.338 Lapua Magnum','8.6×70 мм');

-- Производители (примерный набор)
INSERT INTO lookup (domain, code, label, description) VALUES
('manufacturer','Barnaul','Barnaul','Барнаульский патронный завод'),
('manufacturer','Tula','Tula','Тульский патронный завод'),
('manufacturer','Klimovsk','Klimovsk','Климовский специализированный патронный завод'),
('manufacturer','Hornady','Hornady','Hornady Manufacturing'),
('manufacturer','Lapua','Lapua','Lapua Ammunition'),
('manufacturer','Berger','Berger','Berger Bullets'),
('manufacturer','PPU','PPU','Prvi Partizan'),
('manufacturer','Federal','Federal','Federal Premium Ammunition');

-- Типы изображений
INSERT INTO lookup (domain, code, label, description) VALUES
('image_kind','bullet','Bullet','Изображение пули'),
('image_kind','cartridge','Cartridge','Изображение патрона'),
('image_kind','reference','Reference','Справочные материалы'),
('image_kind','headstamp','Headstamp','Маркировка донца гильзы'),
('image_kind','package','Package','Упаковка');

-- Лицензии изображений
INSERT INTO lookup (domain, code, label, description) VALUES
('license','public_domain','Public Domain','Общественное достояние'),
('license','cc_by','CC-BY','Creative Commons Attribution'),
('license','cc_by_sa','CC-BY-SA','Creative Commons Attribution-ShareAlike'),
('license','restricted','Restricted','Ограниченные права использования');