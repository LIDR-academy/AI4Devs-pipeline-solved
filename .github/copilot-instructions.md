# Copilot Instructions

## Project Context

This is a full-stack recruitment application with:
- **Backend**: Node.js + TypeScript + Express + Prisma ORM
- **Frontend**: React + TypeScript
- **Database**: PostgreSQL via Prisma
- **Testing**: Jest (backend), Cypress (e2e)
- **CI/CD**: GitHub Actions deploying to AWS EC2
- **Infrastructure**: Terraform (tf/), Docker Compose

## Conventions
- Backend tests use Jest with `.test.ts` suffix
- Prisma schema is the source of truth for the data model
- API follows RESTful conventions defined in `backend/api-spec.yaml`
- GitHub Actions pipeline runs on PRs to main

## Agent Orchestration

When a task involves:
- **Unit testing**: Invoke the `unit-testing` agent
- **CI/CD pipelines or AWS deployment**: Invoke the `cicd-aws` agent
- **GitHub Actions workflows**: Invoke the `cicd-aws` agent

All agents must:
1. Plan before executing
2. Log received instructions to `.github/agents-log.md`
3. Verify each planned step after completion

## Prompt Logging

During active sessions, every new user request must be appended to `prompts-racc.md` with:
- Prompt number (sequential)
- Date/time
- Agent name and model used
- The prompt text (exact as written by user)
- Brief summary of what was done

This ensures traceability even if context or memory is lost.
