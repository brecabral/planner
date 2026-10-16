import { Page } from '@playwright/test';
import { test, expect, login } from './accounts';

const card = (page: Page, title: string) => page.locator('[data-task-id]').filter({ has: page.locator('[data-task-title]', { hasText: title }) });
const titles = (page: Page, list: string) => page.locator('[data-task-list="' + list + '"] [data-task-title]');

async function create(page: Page, title: string, label?: string) {
  await page.locator('#new-task').click();
  await expect(page.locator('#task-dialog')).toBeVisible();
  await page.locator('#task_title').fill(title);
  if (label) {
    await page.locator('#task-labels summary').click();
    await page.locator('#task_new_label_names').fill(label);
  }
  await page.locator('#save-task').click();
  await expect(page.locator('#task-dialog')).toHaveCount(0);
  await expect(card(page, title)).toBeVisible();
}

async function action(page: Page, title: string, action: string) {
  const item = card(page, title);
  if (action !== 'complete') await item.locator('summary').click();
  await item.locator(action === 'delete' ? 'button[id^="delete-"]' : 'button[id^="' + action + '-button-"]').click();
  await expect(page.locator('#planning-board')).toHaveAttribute('aria-busy', 'false');
}

test.describe('daily planning', () => {
  test.use({ scenario: 'planning' });
  test('labels, three choices, rejection, return, history and account isolation', async ({ page, accounts }) => {
    await login(page, accounts[0]);
    await create(page, 'Alpha', 'Focus');
    for (const title of ['Beta', 'Gamma', 'Delta']) await create(page, title);
    for (const title of ['Alpha', 'Beta', 'Gamma']) await action(page, title, 'select');
    await expect(titles(page, 'today')).toHaveText(['Alpha', 'Beta', 'Gamma']);
    await expect(page.locator('#used-choices')).toContainText('3');
    await action(page, 'Delta', 'select');
    await expect(page.locator('#planning-error')).toBeVisible();
    await expect(titles(page, 'today')).toHaveText(['Alpha', 'Beta', 'Gamma']);
    await expect(titles(page, 'backlog')).toHaveText(['Delta']);
    await action(page, 'Gamma', 'return');
    await expect(page.locator('#used-choices')).toContainText('2');
    await action(page, 'Delta', 'select');
    await action(page, 'Alpha', 'complete');
    await expect(page.locator('#used-choices')).toContainText('3');
    await expect(page.locator('#history-toggle')).toHaveAttribute('aria-expanded', 'false');
    await page.locator('#history-toggle').click();
    await expect(page.locator('#history')).toContainText('Alpha');
    await expect(page.locator('#history [data-label]')).toHaveText(['Focus']);
    await page.reload();
    await expect(titles(page, 'today')).toHaveText(['Beta', 'Delta']);
    await expect(titles(page, 'backlog')).toHaveText(['Gamma']);
    await expect(page.locator('#used-choices')).toContainText('3');
    await page.locator('#history-toggle').click();
    await expect(page.locator('#history')).toContainText('Alpha');
    const otherContext = await page.context().browser()!.newContext({ baseURL: new URL(page.url()).origin });
    try {
      const otherPage = await otherContext.newPage();
      await login(otherPage, accounts[1]);
      await expect(otherPage.locator('[data-task-title]')).toHaveCount(0);
      await create(otherPage, 'Private second account');
      await expect(otherPage.locator('#used-choices')).toContainText('0');
      await page.reload();
      await expect(titles(page, 'today')).toHaveText(['Beta', 'Delta']);
      await expect(titles(page, 'backlog')).toHaveText(['Gamma']);
      await expect(page.getByText('Private second account', { exact: true })).toHaveCount(0);
    } finally {
      await otherContext.close();
    }
  });
});

test.describe('deletion', () => {
  test.use({ scenario: 'deletion' });
  test('cancel preserves and confirmation deletes and restores the choice', async ({ page, accounts }) => {
    await login(page, accounts[0]);
    await create(page, 'Delete me');
    await action(page, 'Delete me', 'select');
    await action(page, 'Delete me', 'delete');
    await expect(page.locator('#delete-confirmation')).toContainText('Delete me');
    await page.locator('#cancel-delete').click();
    await expect(card(page, 'Delete me')).toBeVisible();
    await expect(page.locator('#used-choices')).toContainText('1');
    await page.reload();
    await action(page, 'Delete me', 'delete');
    await page.locator('#confirm-delete-button').click();
    await expect(card(page, 'Delete me')).toHaveCount(0);
    await expect(page.locator('#used-choices')).toContainText('0');
    await page.reload();
    await expect(card(page, 'Delete me')).toHaveCount(0);
    await expect(page.locator('#used-choices')).toContainText('0');
  });
});

test.describe('ordering', () => {
  test.use({ scenario: 'ordering' });
  test('menu and real mouse drag persist order', async ({ page, accounts }) => {
    await login(page, accounts[0]);
    for (const title of ['First', 'Second', 'Third']) await create(page, title);
    await action(page, 'Second', 'move-up');
    await expect(titles(page, 'backlog')).toHaveText(['Second', 'First', 'Third']);
    await page.reload();
    await expect(titles(page, 'backlog')).toHaveText(['Second', 'First', 'Third']);
    const source = card(page, 'Third').locator('[data-drag-handle]');
    await source.scrollIntoViewIfNeeded();
    const from = (await source.boundingBox())!;
    const to = (await card(page, 'Second').boundingBox())!;
    await page.mouse.move(from.x + from.width / 2, from.y + from.height / 2);
    await page.mouse.down();
    await page.mouse.move(from.x + from.width / 2, from.y + from.height / 2 - 10, { steps: 5 });
    await expect(page.locator('#planning-board')).toHaveAttribute('data-dragging', 'true');
    await page.mouse.move(to.x + to.width / 2, to.y + 5, { steps: 25 });
    await expect(titles(page, 'backlog')).toHaveText(['Third', 'Second', 'First']);
    await page.mouse.up();
    await expect(page.locator('#planning-board')).toHaveAttribute('aria-busy', 'false');
    await page.reload();
    await expect(titles(page, 'backlog')).toHaveText(['Third', 'Second', 'First']);
  });
});

test.describe('touch ordering', () => {
  test.use({ scenario: 'touch', viewport: { width: 390, height: 844 }, hasTouch: true, isMobile: true });
  test('mobile touch hold and drag persists order', async ({ page, accounts }) => {
    await login(page, accounts[0]);
    for (const title of ['First', 'Second']) await create(page, title);
    const source = card(page, 'Second').locator('[data-drag-handle]');
    await source.scrollIntoViewIfNeeded();
    const from = (await source.boundingBox())!;
    const to = (await card(page, 'First').boundingBox())!;
    const session = await page.context().newCDPSession(page);
    const point = { x: from.x + from.width / 2, y: from.y + from.height / 2 };
    await session.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [point] });
    await expect(page.locator('#planning-board')).toHaveAttribute('data-dragging', 'true');
    for (let step = 1; step <= 20; step++) {
      await session.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{
        x: point.x, y: point.y + (to.y + 5 - point.y) * step / 20,
      }] });
    }
    await expect(titles(page, 'backlog')).toHaveText(['Second', 'First']);
    await session.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await expect(page.locator('#planning-board')).toHaveAttribute('aria-busy', 'false');
    await page.reload();
    await expect(titles(page, 'backlog')).toHaveText(['Second', 'First']);
    await session.detach();
  });
});

test.describe('task dialog', () => {
  test.use({ scenario: 'dialog' });
  test('validation recovers and Escape restores focus across LiveView patches', async ({ page, accounts }) => {
    await login(page, accounts[0]);
    await page.locator('#history-toggle').click();
    await page.locator('#new-task').click();
    await expect(page.locator('#task_title')).toBeFocused();
    await page.locator('#task_title').fill('   ');
    await page.locator('#save-task').click();
    await expect(page.locator('#task_title')).toHaveAttribute('aria-invalid', 'true');
    await expect(page.locator('#task-dialog')).toBeVisible();
    await page.locator('#task_title').fill('Recovered');
    await page.locator('#save-task').click();
    await expect(card(page, 'Recovered')).toBeVisible();
    await expect(page.locator('#history-toggle')).toHaveAttribute('aria-expanded', 'true');
    await page.locator('#new-task').click();
    await page.locator('#task_title').fill('Discarded');
    await page.keyboard.press('Escape');
    await expect(page.locator('#task-dialog')).toHaveCount(0);
    await expect(page.locator('#new-task')).toBeFocused();
    await page.locator('#new-task').click();
    await expect(page.locator('#task_title')).toHaveValue('');
    await page.locator('#cancel-task').click();
    await expect(card(page, 'Discarded')).toHaveCount(0);
    await action(page, 'Recovered', 'select');
    await expect(titles(page, 'today')).toHaveText(['Recovered']);
  });
});

for (const [scenario, width] of [['desktop', 1280], ['narrow', 320]] as const) {
  test.describe(scenario + ' theme', () => {
    test.use({ scenario, viewport: { width, height: 900 } });
    test('computed theme persists and logout and another account reset it', async ({ page, accounts }) => {
      await login(page, accounts[0]);
      const colors = () => page.locator('body, header:has(> nav), .planner-section').evaluateAll(elements =>
        elements.map(element => getComputedStyle(element).backgroundColor));
      const light = await colors();
      const select = page.locator('#theme-selector');
      await expect(select).toBeVisible();
      await expect(page.locator('#log-out')).toBeVisible();
      expect(light).toHaveLength(6);
      await select.focus();
      await page.keyboard.press('Space');
      await page.keyboard.press('ArrowDown');
      await page.keyboard.press('Enter');
      await expect(select).toHaveValue('planner_dark');
      await expect(select).toBeEnabled();
      await expect.poll(async () => (await colors()).every((color, index) => color !== light[index])).toBe(true);
      const dark = await colors();
      await page.locator('#new-task').click();
      await expect(page.locator('#task-dialog')).toBeVisible();
      await expect(select).toHaveValue('planner_dark');
      await page.keyboard.press('Escape');
      await expect(page.locator('#task-dialog')).toHaveCount(0);
      await expect(page).toHaveURL('/tasks');
      await page.reload();
      await expect(select).toHaveValue('planner_dark');
      await expect.poll(colors).toEqual(dark);
      await select.focus();
      await page.keyboard.press('Space');
      await page.keyboard.press('ArrowUp');
      await page.keyboard.press('Enter');
      await expect.poll(colors).toEqual(light);
      await select.selectOption('planner_dark');
      await expect.poll(colors).toEqual(dark);
      await create(page, 'Themed task');
      await action(page, 'Themed task', 'select');
      await expect(titles(page, 'today')).toHaveText(['Themed task']);
      await expect.poll(colors).toEqual(dark);
      await page.locator('#flash-info button').click();
      await expect(page.locator('#flash-info')).not.toBeVisible();
      await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
      await page.locator('#log-out').click();
      await expect(page).toHaveURL('/users/log-in');
      await expect(page.locator('html')).toHaveAttribute('data-theme', 'planner');
      await expect(select).toHaveCount(0);
      await login(page, accounts[1]);
      await expect(select).toHaveValue('planner');
      await expect.poll(colors).toEqual(light);
    });
  });
}
