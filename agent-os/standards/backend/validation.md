# Data Validation Pattern

Validate request payload data using lightweight, custom regular expressions and constraint checks without relying on external validation libraries.

## Guidelines

- **Centralized Validator**: Keep all validation logic inside `validator.ts` at the application layer.
- **Service-Level Trigger**: Run validation at the start of Service functions before invoking domain models or database operations, keeping validation close to the application business logic.
- **Error Propagation**: 
  - Use specific validation checks (regex, length limits, date formats).
  - Throw a standard JavaScript/TypeScript `Error` with a clear message (e.g., `throw new Error('Invalid email')`) if validation fails.
  - The controller layer catches these errors and responds with an appropriate HTTP status (typically `400 Bad Request`).

### Validation Rules

- **Names**: `NAME_REGEX = /^[a-zA-ZñÑáéíóúÁÉÍÓÚ ]+$/` (minimum 2, maximum 100 characters).
- **Email**: `EMAIL_REGEX = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/`.
- **Phone**: Spain format `PHONE_REGEX = /^(6|7|9)\d{8}$/`.
- **Dates**: `DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/`.
- **String Lengths**: Align length checks (e.g. `institution.length > 100`) directly with the Postgres/Prisma database schema limits.

### Code Example

**Validator (`application/validator.ts`)**:
```typescript
const EMAIL_REGEX = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

export const validateCandidateData = (data: any) => {
    if (!data.email || !EMAIL_REGEX.test(data.email)) {
        throw new Error('Invalid email');
    }
};
```

**Service (`application/services/candidateService.ts`)**:
```typescript
import { validateCandidateData } from '../validator';

export const addCandidate = async (candidateData: any) => {
    // Run validation first
    validateCandidateData(candidateData);
    
    // Proceed with database logic
    const candidate = new Candidate(candidateData);
    return await candidate.save();
};
```
