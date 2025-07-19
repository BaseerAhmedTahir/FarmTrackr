-- Storage policies
CREATE POLICY "Authenticated users can upload goat photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = ''goat-photos'' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view their goat photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = ''goat-photos'' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their goat photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = ''goat-photos'' AND
    (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
    bucket_id = ''goat-photos'' AND
    (storage.foldername(name))[1] = auth.uid()::text
);
