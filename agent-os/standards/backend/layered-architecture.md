# Layered Clean Architecture

Maintain clean separation of concerns by routing requests through structured layers, separating the HTTP framework (Express) from the core business logic.

## Guidelines

- **Architecture Layers**:
  1. **Routes (`src/routes/`)**: Define endpoint paths and bind them to Controller functions. Do NOT bypass controllers to call services directly.
  2. **Controllers (`src/presentation/controllers/`)**: Handle HTTP request validation, extract parameters (`req.params`, `req.body`), call application Services, and format the HTTP response.
  3. **Services (`src/application/services/`)**: Orchestrate business use cases, perform data validation, and coordinate domain Models. Keep services independent of HTTP-specific elements (do not reference `req` or `res`).
  4. **Models (`src/domain/models/`)**: Represent the domain models and encapsulate database schema interactions (Active Record).

### Flow Example

```
Client Request ➔ Route ➔ Controller ➔ Service ➔ Model ➔ Database
```

### Code Example

**Route (`routes/candidateRoutes.ts`)**:
```typescript
import { Router } from 'express';
import { addCandidateController } from '../presentation/controllers/candidateController';

const router = Router();
router.post('/', addCandidateController); // Always route to a controller
export default router;
```

**Controller (`presentation/controllers/candidateController.ts`)**:
```typescript
import { Request, Response } from 'express';
import { addCandidateService } from '../../application/services/candidateService';

export const addCandidateController = async (req: Request, res: Response) => {
    try {
        const candidate = await addCandidateService(req.body);
        res.status(201).json({ message: 'Success', data: candidate });
    } catch (error: any) {
        res.status(400).json({ error: error.message });
    }
};
```
