# Active Record wrappers (models wrapping Prisma client)

Encapsulate business logic and database queries inside model classes rather than writing raw database queries in services.

## Guidelines

- **Active Record wrapper**: Create a domain model class for each database model to wrap Prisma database operations (inserts, updates, queries).
- **Save and Find methods**: 
  - Provide an instance method `save()` to perform inserts (if `id` is not present) or updates (if `id` is present).
  - Provide static query methods like `findOne(id)` or `findAll()` for retrieving model instances.
- **Connection Management**:
  - Prefer using a shared/singleton PrismaClient instance instead of instantiating `new PrismaClient()` in every model file, to prevent connection exhaustion.
  
### Example

```typescript
import { prisma } from '../lib/prisma'; // Shared singleton instance

export class Candidate {
    id?: number;
    firstName: string;
    // ...

    constructor(data: any) {
        this.id = data.id;
        this.firstName = data.firstName;
    }

    async save() {
        if (this.id) {
            return await prisma.candidate.update({
                where: { id: this.id },
                data: { firstName: this.firstName }
            });
        } else {
            return await prisma.candidate.create({
                data: { firstName: this.firstName }
            });
        }
    }

    static async findOne(id: number): Promise<Candidate | null> {
        const data = await prisma.candidate.findUnique({ where: { id } });
        return data ? new Candidate(data) : null;
    }
}
```
