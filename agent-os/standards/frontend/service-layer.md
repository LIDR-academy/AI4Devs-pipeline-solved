# Centralized Service Layer

Centralize all HTTP requests and API integrations in a dedicated service layer to simplify testing, ensure reuse, and encapsulate error handling.

## Guidelines

- **Centralized API Calls**:
  - Place all API request functions inside `src/services/` files (e.g. `candidateService.ts`, `positionService.ts`).
  - Do NOT use direct `fetch` or `axios` queries inside UI components (`useEffect` or event handlers).
- **Data Unwrapping**:
  - Service functions must unwrap and return the API payload data directly (e.g. `response.data`) to keep the components decoupled from the HTTP transfer layer format.
- **Error Propagation**:
  - Catch API errors inside the service layer, log them when appropriate, and throw clear JavaScript/TypeScript errors for the UI component to handle and display to the user.

### Code Example

**Service (`services/positionService.ts`)**:
```typescript
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3010';

export const getPositions = async (): Promise<Position[]> => {
    try {
        const response = await axios.get(`${API_BASE_URL}/positions`);
        return response.data; // Return unwrapped payload directly
    } catch (error: any) {
        throw new Error(error.response?.data?.message || 'Error fetching positions');
    }
};
```

**Component (`components/Positions.tsx`)**:
```typescript
import React, { useState, useEffect } from 'react';
import { getPositions } from '../services/positionService';

const Positions: React.FC = () => {
    const [positions, setPositions] = useState<Position[]>([]);

    useEffect(() => {
        const fetchPositions = async () => {
            try {
                const data = await getPositions(); // Call service
                setPositions(data);
            } catch (error) {
                console.error(error);
            }
        };
        fetchPositions();
    }, []);
    // ...
};
```
