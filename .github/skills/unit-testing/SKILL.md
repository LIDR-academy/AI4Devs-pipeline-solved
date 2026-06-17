# Unit Testing Skill

## Description
Creates comprehensive unit tests for TypeScript/JavaScript code in this project using Jest.

## When to Use
- User asks to create, add, or write unit tests
- User asks to improve test coverage
- User asks to test a specific service, controller, or module
- User mentions TDD or test-driven development

## Instructions

### Context Gathering
1. Read the target file to understand its exports, dependencies, and logic
2. Read existing test files for patterns: `backend/src/application/services/candidateService.test.ts`, `backend/src/presentation/controllers/candidateController.test.ts`
3. Read `backend/jest.config.js` for test configuration
4. Read `backend/prisma/schema.prisma` for data model context

### Test Structure Template
```typescript
import { PrismaClient } from '@prisma/client';
// Import the module under test

jest.mock('@prisma/client', () => ({
  PrismaClient: jest.fn().mockImplementation(() => ({
    // mock methods
  })),
}));

describe('ModuleName', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('methodName', () => {
    it('should handle happy path', async () => {
      // Arrange
      // Act
      // Assert
    });

    it('should handle error case', async () => {
      // Arrange - setup error condition
      // Act & Assert
      await expect(method()).rejects.toThrow();
    });
  });
});
```

### Coverage Requirements
- Happy path for each public method
- Error/exception paths
- Edge cases (null, undefined, empty arrays, boundary values)
- Async behavior (resolved and rejected promises)

### Verification
After writing tests, run:
```bash
cd backend && npm test -- --coverage --testPathPattern="<test-file>"
```

Ensure all tests pass and coverage meets project standards.
