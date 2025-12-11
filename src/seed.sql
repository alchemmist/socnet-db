INSERT INTO users (id, username, email, name, surname, birth_date)
VALUES
  ('11111111-1111-1111-1111-111111111111','alice','alice@example.com','Alice','Smith','1990-01-01'),
  ('22222222-2222-2222-2222-222222222222','bob','bob@example.com','Bob','Johnson','1985-06-15')
ON CONFLICT (id) DO NOTHING;
