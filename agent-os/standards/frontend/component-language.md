# Frontend Language & TypeScript Standards

Ensure type safety, better developer tooling, and self-documenting code by using TypeScript for all new and refactored components and services.

## Guidelines

- **TypeScript Adoption**:
  - All new files or heavily refactored files **must** be written in TypeScript (`.ts` for services/helpers, `.tsx` for React components).
  - Legacy `.js` files may remain JavaScript until they require modifications or refactoring.
- **Explicit Typing**:
  - Define explicit `type` or `interface` declarations for all component props, states, and API return values.
  - Avoid using the `any` type; define proper custom types or use third-party type definitions where available.
- **Function Components**:
  - Declare functional components using the `React.FC` generic type (e.g. `const Positions: React.FC = () => { ... }`).
  
### Code Example

**Good (`components/CandidateCard.tsx`)**:
```typescript
import React from 'react';

type CandidateCardProps = {
    id: number;
    firstName: string;
    lastName: string;
    email: string;
    status?: string;
};

export const CandidateCard: React.FC<CandidateCardProps> = ({ id, firstName, lastName, email, status }) => {
    return (
        <div className="card shadow-sm mb-3">
            <div className="card-body">
                <h5 className="card-title">{firstName} {lastName}</h5>
                <p className="card-text">{email}</p>
                {status && <span className="badge bg-primary">{status}</span>}
            </div>
        </div>
    );
};
```
