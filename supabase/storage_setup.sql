-- Storage Setup Instructions
/*
These storage settings need to be configured through the Supabase Dashboard UI:

1. Create a new bucket:
   - Name: goat-photos
   - Public bucket: No

2. Add the following RLS policies for the goat-photos bucket:

Policy 1: Upload photos
- Policy name: Users can upload goat photos
- Allowed operation: INSERT
- Policy definition: true
- Target roles: authenticated

Policy 2: View photos
- Policy name: Users can access goat photos
- Allowed operation: SELECT
- Policy definition: true
- Target roles: authenticated

Policy 3: Update photos
- Policy name: Users can update goat photos
- Allowed operation: UPDATE
- Policy definition: true
- Target roles: authenticated

Policy 4: Delete photos
- Policy name: Users can delete goat photos
- Allowed operation: DELETE
- Policy definition: true
- Target roles: authenticated
*/
