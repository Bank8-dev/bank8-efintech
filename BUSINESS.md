# Bank8:eFintech — Business Requirements & Functionality

> Audience: product owners, business analysts, and anyone evaluating what
> Bank8:eFintech **does for the business**. For architecture read `README.md`;
> for wire-level detail read `DESIGN.md`.

## 1. Business Purpose

- Demonstrate the **FDX Data Recipient** side of open banking end to end: a
  fintech app that discovers external providers, obtains customer consent, and
  displays consented financial data.
- Prove that third-party data retrieval can run entirely on platform rails —
  hosted consent UI, BFF proxy, consent registry — with zero bespoke provider
  integrations in the app.

## 2. Business Scope (What the Service Provides)

| Capability | Delivered through |
|---|---|
| External provider catalog browsing + provider detail | Bank8:FDX recipient APIs |
| Consent journey initiation (hand-off to hosted authorization UI) | Bank8:FDX + Sentin8:Auth |
| Consent status tracking (bounded polling to a terminal state) | Bank8:FDX |
| Consent revocation and refresh from the fintech side | Bank8:FDX |
| Consented account listing (consent-filtered) | Bank8:FDX |
| Consented transaction history (paginated) | Bank8:FDX |
| Instance admin overview (staff) | runtime context |
| FDX recipient-side administration (staff) | Bank8:FDX |

**What eFintech does NOT own (business boundary):**

| Concern | Owning service |
|---|---|
| Identity, hosted sign-in and consent UI | Sentin8:Auth |
| Provider gateway, consent enforcement, data retrieval | Bank8:FDX |
| Financial truth at the provider bank | Bank8:Ledger / Bank8:Payments (provider side) |
| Session/token custody (incl. provider tokens) | Sentin8:BFF / Bank8:FDX |
| Structured persistence | Sentin8:DB |
| Document/object bytes | storage |

## 3. Business Capabilities

| Area | Capability | Business rule |
|---|---|---|
| Discovery | Provider catalog | The fintech sees exactly the providers registered and published on the platform. |
| Consent | Share-data initiation | A consent is always started with explicit requested scopes (basic account, detailed account, transactions) and a return redirect into this app. |
| Consent | Status transparency | The customer journey shows live consent status; terminal states (active/failed/timed-out) are always rendered, never guessed. |
| Consent | Revocation | The fintech can revoke any of its consents; revocation immediately invalidates the sharing relationship and linked tokens upstream. |
| Data | Account visibility | Only data inside a consenting relationship is retrievable; there is no "browse anyway" path. |
| Data | Transaction history | Transaction data is shown paginated, sourced from provider snapshots taken under the consent. |
| Admin | Operations oversight | Staff see the recipient-side state: providers known to the instance, consent overview, retrieval-health signals. |

## 4. Business Events (Outbound)

eFintech emits no domain events of its own (pure presentation layer).
Operations it triggers *upstream*:

| Operation in app | Upstream effect |
|---|---|
| Consent start → customer authorizes | Consent lifecycle transitions in Bank8:FDX (and provider-side notification) |
| Consent revoke | Consent-terminated event; linked recipient tokens invalidated |
| Consent refresh | Re-authorization journey; consent lifecycle restarts |

**Inbound (consumed):** none directly — consent status is tracked by bounded
polling of the recipient consents endpoint. No SSE/WebSocket channel is used
in this app today.

## 5. Business Rules & Invariants

1. All external data access follows an explicit customer consent; no consent,
   no data — for any UI path.
2. The customer's authorization journey always happens in the hosted consent
   UI (identity plane), never in the fintech app.
3. Consent status is always surfaced truthfully, including failure and
   timeout states.
4. Revoking a consent removes its data from the app on the next refresh and
   invalidates upstream access immediately.
5. Provider tokens are never held by the fintech app.
6. The app fails closed: without a verified instance identity no page loads.

## 6. Target-User Roles & Use Cases

| Persona | What they do |
|---|---|
| Fintech customer | Browses providers, starts a data-sharing consent, authorizes in the hosted UI, then reviews consented accounts and transactions; can revoke at any time. |
| Fintech operator (admin surface) | Monitors the instance and the recipient-side FDX state (providers, consents). |
| Product owner / integration tester | Validates the recipient journey as the certification-ready demo of the platform's open-banking rails. |

## 7. KPIs / Success Criteria

- **Reliability:** consent journeys reach a terminal state without silent
  hangs; polling never exceeds its bound.
- **Latency:** provider catalog and consented-data screens perceived instant
  (single proxy hop; data from platform caches on the FDX plane).
- **Security:** zero provider-token exposure; every data view traceable to an
  active consent.
- **UX quality:** the whole provider → consent → data journey completes in a
  single continuous flow with consistent loading/error frames.
- **Certification readiness:** the demo journey exercises the same consented
  retrieval path a production recipient would use.

## 8. Dependencies & Reliance on Other Services

| Dependency | Why |
|---|---|
| Sentin8:Auth | Sign-in/sign-up; hosted consent UI; consent authorization |
| Sentin8:BFF | Session custody, token attach, scope gating, proxy |
| Bank8:FDX | Provider registry, consent lifecycle, consented data retrieval |
| Sentin8:App | Instance provisioning, runtime context, listing |
| Sentin8:TLS | Hostname → instance resolution, TLS termination |
| Provider side (Bank8:eBank tenant) | Supplies the consented accounts/transactions through the provider plane |

## 9. Acceptance Criteria

1. A fintech customer can discover published external providers from inside
   the app.
2. Starting a consent hands the customer off to the hosted authorization UI
   and returns them into the app with the consent journey continued (status
   polling to a terminal state).
3. After authorization, the customer's consented accounts and transactions
   render inside the fintech app without any manual backend step.
4. The customer can revoke a consent from the fintech; the data disappears on
   the next refresh and upstream access stops immediately.
5. No page loads without verified instance context (fail closed).
6. No flow in the app performs a direct call to an external provider.
7. E2E: the full lifecycle (sign-up → consent → data display) runs through
   the browser only, like a real user.

## 10. Open Business Questions

- Should the fintech support recipient-initiated payments (FDX money
  movement writes) in the future, or remain a data-read demo?
- Should consented-data refresh become an automatic background capability
  (scheduled retrieval) instead of on-demand viewing?

---

**Design attribution:** bank8:efintech and its underlying concepts were designed by Hamid Jahanzad <Hamid@Jahanzad.com>.
