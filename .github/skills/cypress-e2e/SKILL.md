# Cypress E2E Testing Skill

## Description
Creates comprehensive end-to-end tests using Cypress for the recruitment application frontend.

## When to Use
- User asks to create e2e, integration, or end-to-end tests
- User asks to test user flows, UI interactions, or pages
- User mentions Cypress specifically
- User wants to verify frontend behavior against the API

## Instructions

### Context Gathering
1. Read `cypress.config.js` for base URL and spec patterns
2. Read existing tests in `cypress/e2e/` for patterns
3. Read `cypress/support/commands.js` for custom commands
4. Read the target frontend component in `frontend/src/components/`

### Project Config
- **Base URL**: `http://localhost:3000` (frontend)
- **API URL**: `http://localhost:3010` (backend)
- **Spec pattern**: `cypress/e2e/**/*.{js,jsx,ts,tsx}`
- **Fixtures**: `cypress/fixtures/`

### E2E Test Template
```typescript
describe('FeatureName E2E Tests', () => {
  beforeEach(() => {
    // Intercept API calls
    cy.intercept('GET', 'http://localhost:3010/endpoint').as('getData');
    
    // Visit the page
    cy.visit('/page-path');
  });

  it('should display expected content after load', () => {
    cy.wait(['@getData']);
    cy.get('[data-cy=element]').should('be.visible');
  });

  it('should handle user interaction', () => {
    cy.get('[data-cy=button]').click();
    cy.get('[data-cy=result]').should('contain', 'Expected text');
  });

  it('should handle error states', () => {
    cy.intercept('GET', 'http://localhost:3010/endpoint', {
      statusCode: 500,
      body: { error: 'Server error' }
    }).as('getDataError');
    
    cy.visit('/page-path');
    cy.wait(['@getDataError']);
    cy.get('[data-cy=error-message]').should('be.visible');
  });
});
```

### Best Practices
- Use `data-cy` attributes for stable selectors (not CSS classes)
- Use `cy.intercept()` to control API responses and avoid flaky tests
- Use `cy.wait()` with aliases for async operations
- Test both success and error states
- Avoid `cy.wait(ms)` — prefer waiting on aliases or assertions
- Keep tests independent — each `it` block should work in isolation
- Use fixtures for complex mock data

### Custom Commands
Define reusable actions in `cypress/support/commands.js`:
```javascript
Cypress.Commands.add('login', (email, password) => {
  cy.visit('/login');
  cy.get('[data-cy=email]').type(email);
  cy.get('[data-cy=password]').type(password);
  cy.get('[data-cy=submit]').click();
});
```

### Verification
Run tests with:
```bash
npx cypress run --spec "cypress/e2e/<test-file>"
```
Or for headed mode:
```bash
npx cypress open
```
