# TODO: Fix AdminPanelTest failures

## Plan Steps:
- [x] Understand failing tests: create/update/delete not persisting to local `users` DB
- [x] Plan: Update UserController store/update/destroy to use local User model + Firebase sync
- [ ] Create TODO.md with checklist
- [ ] Update `backend/app/Http/Controllers/Admin/UserController.php`:
  - store(): create local User + Firebase user
  - update(): update local User + Firebase user  
  - destroy(): delete local User + Firebase user (preserve self-delete protection)
- [ ] Test: `cd backend && php artisan test --filter=AdminPanelTest`
- [ ] Verify all tests pass
- [ ] Handle any remaining issues

## Progress:
Ready to implement UserController changes.
