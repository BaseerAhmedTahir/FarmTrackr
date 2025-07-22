-- Create functions to help with storage paths
CREATE OR REPLACE FUNCTION storage.filename(name text)
RETURNS text
AS $$
  SELECT split_part(name, '/', -1);
$$ LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION storage.foldername(name text)
RETURNS text[]
AS $$
  SELECT string_to_array(
    ltrim(split_part(name, storage.filename(name), 1), '/'),
    '/'
  );
$$ LANGUAGE SQL IMMUTABLE;
