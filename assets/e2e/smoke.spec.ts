import { test, expect } from '@playwright/test';

test('visitors reach a connected login page from the home page', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveURL('/users/log-in');
  await expect(page.locator('.phx-connected #login_form_magic')).toBeVisible();
  await expect(page.locator('#login_form_magic input[type="email"]')).toBeVisible();
  await page.locator('#register-link').click();
  await expect(page).toHaveURL('/join');
});

test('private planning requires authentication', async ({ page }) => {
  await page.goto('/tasks');
  await expect(page).toHaveURL('/users/log-in');
  await expect(page.locator('#login_form_magic')).toBeVisible();
});
