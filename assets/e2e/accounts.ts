import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { test as base, expect, Page } from '@playwright/test';

type Account = { email: string; token: string };
let accounts: Record<string, Account[]>;

function identities() {
  if (accounts) return accounts;
  if (process.env.E2E_ACCOUNTS_FILE) {
    accounts = JSON.parse(readFileSync(process.env.E2E_ACCOUNTS_FILE, 'utf8'));
  } else {
    if (!process.env.E2E_CONTAINER) throw new Error('E2E_CONTAINER or E2E_ACCOUNTS_FILE is required');
    const source = readFileSync(resolve(__dirname, '../../test/support/e2e/accounts.exs')).toString('base64');
    const output = execFileSync('docker', ['exec', process.env.E2E_CONTAINER, '/app/bin/planner', 'rpc',
      `Code.eval_string(Base.decode64!("${source}"))`], { encoding: 'utf8', timeout: 30000 });
    const marker = output.split('\n').find(line => line.startsWith('E2E_ACCOUNTS='));
    if (!marker) throw new Error('Release fixture did not return its authentication manifest');
    accounts = JSON.parse(marker.slice('E2E_ACCOUNTS='.length));
  }
  return accounts;
}

export async function login(page: Page, account: Account) {
  await page.goto('/users/log-in/' + account.token);
  await expect(page.locator('.phx-connected #confirmation_form')).toBeVisible();
  await expect(page.locator('#brand')).toHaveText('Just Three');
  await expect(page).toHaveTitle('Just Three');
  await page.locator('#confirmation_form button').last().click();
  await expect(page).toHaveURL('/tasks');
  await expect(page.locator('.phx-connected #planning-board')).toBeVisible();
}

export const test = base.extend<{ scenario: string; accounts: Account[] }>({
  scenario: ['', { option: true }],
  accounts: async ({ scenario }, use) => {
    const pair = identities()[scenario];
    if (!pair || pair.length !== 2) throw new Error('Missing independent scenario identities: ' + scenario);
    await use(pair);
  },
});
export { expect };
