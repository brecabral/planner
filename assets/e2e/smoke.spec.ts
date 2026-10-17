import { test, expect } from '@playwright/test';

test('visitors reach a connected login page from the home page', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveURL('/users/log-in');
  await expect(page.locator('.phx-connected #login_form_magic')).toBeVisible();
  await expect(page.locator('#login_form_magic input[type="email"]')).toBeVisible();
  await expect(page.locator('#brand')).toHaveText('Just Three');
  await expect(page.locator('#brand .hero-bars-3')).toHaveCount(1);
  await expect(page).toHaveTitle('Just Three');
  await page.locator('#register-link').click();
  await expect(page).toHaveURL('/join');
  await expect(page.locator('#brand')).toHaveText('Just Three');
  await page.goto('/users/register');
  await expect(page.locator('#brand')).toHaveText('Just Three');
  await page.locator('#brand').click();
  await expect(page).toHaveURL('/users/log-in');
});

test('private planning requires authentication', async ({ page }) => {
  await page.goto('/tasks');
  await expect(page).toHaveURL('/users/log-in');
  await expect(page.locator('#login_form_magic')).toBeVisible();
});
