# eFintech FDX Recipient Certification Evidence

Status: All evidence produced - ready for certification review

## Contract Tests Evidence
| Test Suite | File | Status |
|------------|------|--------|
| Flutter-Sentin8:BFF contract tests | `test/contract_test.dart` | ✅ Pass |
| Sentin8:BFF-Bank8:FDX/Sentin8:DB/Sentin8:Storage boundary tests | `test/contract_test.dart` | ✅ Pass |
| OpenAPI 3.1 contract specs | `openapi.yaml` | ✅ Aligned |

## Account Data Test Evidence
| Test | Description | Status |
|------|-------------|--------|
| Account list from Bank8:FDX snapshots | useFdxAccounts → Sentin8:BFF → Bank8:FDX GET /v1/recipient/accounts | ✅ Verified |
| Account detail from Bank8:FDX snapshots | Account detail screen with product terms, balances | ✅ Verified |
| Account data mapping | Bank8:FDX snapshot → EFintechAccount DTO (masked numbers, types, status) | ✅ Verified |

## Transaction Data Test Evidence
| Test | Description | Status |
|------|-------------|--------|
| Transaction history from Bank8:FDX snapshots | useFdxTransactions → Sentin8:BFF → Bank8:FDX GET /v1/recipient/accounts/{id}/transactions | ✅ Verified |
| Cursor-based pagination | nextPageKey handling for large transaction sets | ✅ Verified |
| Date range filtering | startDate/endDate query parameters | ✅ Verified |
| Transaction data mapping | Bank8:FDX snapshot → EFintechTransaction DTO (date, amount, debit/credit, category) | ✅ Verified |

## Security Test Evidence
| Test | Description | Status |
|------|-------------|--------|
| Sentin8:Auth token validation | Expired, wrong audience, wrong tenant, revoked token | ✅ Verified |
| Cross-customer data isolation | Customer A cannot see customer B's consents or accounts | ✅ Verified |
| Cross-tenant data isolation | Tenant A cannot see tenant B's provider catalog or consents | ✅ Verified |
| No direct external provider calls | CI guard detects outbound HTTP to non-Sentin8 hosts | ✅ Verified |
| No raw tokens in logs/Sentin8:DB | CI guard detects token-like strings; Sentin8:Auth stores tokens | ✅ Verified |
| Consent enforcement | Revoked consent → data access denied; expired → reauthorization | ✅ Verified |

## Operational Test Evidence
| Test | Description | Status |
|------|-------------|--------|
| Health check endpoints | Sentin8:BFF /health and /readiness | ✅ Available |
| Runtime resolver fail-closed | Unknown hostname → error page | ✅ Verified |
| DCR atomic setup | Fail closed if DCR fails | ✅ Verified |
| Consent revocation | Immediate token invalidation | ✅ Verified |
| Data refresh | Trigger → retrieval job → snapshot update → UI refetch | ✅ Verified |
| Metrics and alerting | Auth, consent, retrieval failure spikes | ✅ Verified |

## Smoke E2E Test
| Step | Description | Status |
|------|-------------|--------|
| 1 | Sign up via Sentin8:Auth hosted UI | ✅ Verified |
| 2 | Sign in via Sentin8:Auth OAuth flow (PKCE S256) | ✅ Verified |
| 3 | Browse providers (Bank8:FDX recipient catalog) | ✅ Verified |
| 4 | Select provider and start consent flow | ✅ Verified |
| 5 | Complete consent authorization at external provider | ✅ Verified |
| 6 | View consented accounts from Bank8:FDX snapshots | ✅ Verified |
| 7 | View transaction history with pagination | ✅ Verified |
| 8 | Revoke consent - data access denied | ✅ Verified |