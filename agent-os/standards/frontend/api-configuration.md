# API Endpoint Configuration

Ensure backend API base URLs are configurable and not hardcoded inside component or service source files.

## Guidelines

- **Environment Variables**:
  - Retrieve the backend API base URL from the `REACT_APP_API_URL` environment variable.
- **Fallback URL**:
  - If the environment variable is not defined, default / fallback to `http://localhost:3010` during local development.
- **No Hardcoded URLs**:
  - Never hardcode the host (`localhost`, IPs, or production domains) directly inside services or components.
  
### Code Example

**Bad**:
```javascript
const response = await axios.post('http://localhost:3010/candidates', data);
```

**Good**:
```javascript
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3010';

const response = await axios.post(`${API_BASE_URL}/candidates`, data);
```
