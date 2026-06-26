# TGE Agent Contracts

These are documentary contracts for local/staging agents. They do not deploy Agents SDK runtime.

## Escribania Taxonomy Mapper

Purpose: normalize recovered Microsoft taxonomy assets into safe metadata-only fixtures.

Allowed tools:

- local file metadata read;
- deterministic classifiers;
- JSON schema validation;
- local evals.

Blocked tools:

- SharePoint import;
- TermStore import;
- tenant write;
- OpenAI API live calls;
- Agents SDK deployment.

## Tenant Boundary Guard

Purpose: verify TGE remains Escribania-only and does not use Modo ON as runtime.

Allowed tools:

- local fixture checks;
- pattern scans;
- readbacks.

Blocked tools:

- tenant switch;
- role assignment;
- app registration;
- credential persistence.

## Evidence Sanitization Reviewer

Purpose: verify that outputs contain no raw content, secrets, tenant payloads or regulated data.

Allowed tools:

- high-confidence secret scan;
- metadata-only fixture validation.

Blocked tools:

- raw auth evidence;
- token dumps;
- real data extraction.

## Runtime Cookbook Frontier Classifier

Purpose: classify OpenAI cookbook-style runtime patterns for TGE Escribania without crossing into tenant or legal authority.

Allowed tools:

- synthetic Structured Outputs checks;
- local/staging Agents SDK guard checks;
- local deterministic evals;
- sanitized SharePoint-ready evidence for human upload.

Blocked tools:

- SharePoint upload or write by agent;
- Graph/Planner write;
- Power Platform mutation;
- legal decision automation;
- tenant write;
- production deployment.

## TCU Pattern Receiver

Purpose: receive TCU patterns and translate them to Escribania without copying identity.

Boundary:

- TCU is doctrine.
- TGE is Escribania execution context.
- No TCU runtime identity is executed from this repo.
